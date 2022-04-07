//
//  JSNetworkAgent.m
//  JSNetwork
//
//  Created by jiasong on 2020/4/17.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import "JSNetworkAgent.h"
#import "JSNetworkRequestConfigProtocol.h"
#import "JSNetworkResponseProtocol.h"
#import "JSNetworkPluginProtocol.h"
#import "JSNetworkRequestProtocol.h"
#import "JSNetworkDiskCacheProtocol.h"
#import "JSNetworkInterfaceProtocol.h"
#import "JSNetworkDiskCacheMetadataProtocol.h"
#import "JSNetworkUtil.h"
#import "JSNetworkConfig.h"
#import <os/lock.h>

@interface JSNetworkAgent () {
    os_unfair_lock _lock;
}

@property (nonatomic, strong) NSOperationQueue *requestQueue;
@property (nonatomic, strong) NSMutableDictionary<NSString *, id<JSNetworkInterfaceProtocol>> *interfaceRecord;

@end

@implementation JSNetworkAgent

+ (instancetype)defaultAgent {
    static dispatch_once_t onceToken;
    static JSNetworkAgent *instance = nil;
    dispatch_once(&onceToken,^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        _interfaceRecord = [NSMutableDictionary dictionary];
        _lock = OS_UNFAIR_LOCK_INIT;
        _requestQueue = [[NSOperationQueue alloc] init];
        _requestQueue.name = @"com.jsnetwork.agent.operationqueue";
    }
    return self;
}

#pragma mark - Pubilc

- (void)performRequestForInterface:(id<JSNetworkInterfaceProtocol>)interface {
    NSParameterAssert(interface);
    /// 首先需要添加interface
    [self performInterface:interface forTaskIdentifier:interface.taskIdentifier];
    /// 处理请求
    [self toggleWillStartWithInterface:interface];
    if (interface.processedConfig.cachePolicy == JSRequestCachePolicyUseCacheDataElseLoad) {
        [self processingDiskCacheForInterface:interface];
    } else {
        [self processingRequestForInterface:interface];
    }
    [self toggleDidStartWithInterface:interface];
}

- (void)cancelRequestForInterface:(id<JSNetworkInterfaceProtocol>)interface {
    if (interface.request.requestTask) {
        [interface.request cancel];
    }
}

- (void)cancelRequestForTaskIdentifier:(NSString *)taskIdentifier {
    id<JSNetworkInterfaceProtocol> interface = [self interfaceForTaskIdentifier:taskIdentifier];
    if (interface) {
        [self cancelRequestForInterface:interface];
    } else {
        JSNetworkLog(@"检查 interface 是否已被释放");
    }
}

/// 获得一个接口
- (nullable id<JSNetworkInterfaceProtocol>)interfaceForTaskIdentifier:(NSString *)taskIdentifier {
    NSParameterAssert(taskIdentifier);
    [self addLock];
    id<JSNetworkInterfaceProtocol> interface = [_interfaceRecord objectForKey:taskIdentifier];
    [self unLock];
    return interface;
}

#pragma mark - Private

/// 处理请求
- (void)processingRequestForInterface:(id<JSNetworkInterfaceProtocol>)interface {
    NSParameterAssert(interface);
    __weak typeof(self) weakSelf = self;
    __weak typeof(interface) weakInterface = interface;
    [interface.request buildTaskWithConfig:interface.processedConfig
                         multipartFormData:^(id formData) {
        if ([weakInterface.processedConfig respondsToSelector:@selector(constructingMultipartFormData:)]) {
            [weakInterface.processedConfig constructingMultipartFormData:formData];
        }
    } uploadProgress:^(NSProgress *uploadProgress) {
        if (weakInterface.uploadProgress) {
            weakInterface.uploadProgress(uploadProgress);
        }
    } downloadProgress:^(NSProgress *downloadProgress) {
        if (weakInterface.downloadProgress) {
            weakInterface.downloadProgress(downloadProgress);
        }
    } didCreateURLRequest:^(__kindof NSURLRequest *urlRequest) {
        if ([urlRequest isKindOfClass:NSMutableURLRequest.class]) {
            /// 二进制的数据
            if (weakInterface.processedConfig.requestSerializerType == JSRequestSerializerTypeBinaryData) {
                id body = weakInterface.processedConfig.requestBody;
                if ([body isKindOfClass:NSData.class]) {
                    [urlRequest setHTTPBody:body];
                } else {
                    NSAssert(NO, @"必须为 NSData类型");
                }
            }
            if ([weakInterface.processedConfig respondsToSelector:@selector(constructingMultipartURLRequest:)]) {
                [weakInterface.processedConfig constructingMultipartURLRequest:urlRequest];
            }
        }
    } didCreateTask:^(__kindof NSURLSessionTask *task) {
        [weakSelf performRequestOperation:weakInterface.request];
    } didCompleted:^(id responseObject, NSError *error) {
        @autoreleasepool {
            [weakSelf processingResponseForInterface:weakInterface
                                  withResponseObject:responseObject
                                setCacheDataIfNeeded:YES
                                               error:error];
        }
    }];
}

/// 处理缓存
- (void)processingDiskCacheForInterface:(id<JSNetworkInterfaceProtocol>)interface {
    id<JSNetworkRequestConfigProtocol> processedConfig = interface.processedConfig;
    NSParameterAssert(processedConfig.cacheTimeInSeconds > 0 || processedConfig.cacheVersion > 0);
    __weak typeof(self) weakSelf = self;
    __weak typeof(interface) weakInterface = interface;
    /// 缓存处理
    [interface.diskCache buildTaskWithConfig:processedConfig
                                didCompleted:^(id<JSNetworkDiskCacheMetadataProtocol> metadata) {
        @autoreleasepool {
            if (metadata) {
                /// 存在缓存时
                [weakSelf processingResponseForInterface:weakInterface
                                      withResponseObject:metadata.cacheData
                                    setCacheDataIfNeeded:NO
                                                   error:nil];
            } else {
                /// 处理网络请求
                [weakSelf processingRequestForInterface:weakInterface];
            }
        }
    }];
}

/// 处理响应
- (void)processingResponseForInterface:(id<JSNetworkInterfaceProtocol>)interface
                    withResponseObject:(nullable id)responseObject
                  setCacheDataIfNeeded:(BOOL)setCacheDataIfNeeded
                                 error:(nullable NSError *)error {
    NSParameterAssert(interface);
    __weak typeof(self) weakSelf = self;
    __weak typeof(interface) weakInterface = interface;
    dispatch_queue_t processingQueue = JSNetworkConfig.sharedConfig.processingQueue;
    dispatch_queue_t completionQueue = JSNetworkConfig.sharedConfig.completionQueue;
    dispatch_async(processingQueue, ^{
        /// 处理响应
        @autoreleasepool {
            [weakInterface.response processingTask:weakInterface.request.requestTask
                                    responseObject:responseObject
                                             error:error];
        }
        void(^completionBlock)(void) = ^(void) {
            dispatch_async(completionQueue, ^{
                @autoreleasepool {
                    [weakSelf toggleWillStopWithInterface:weakInterface];
                    for (JSNetworkRequestCompletedBlock block in weakInterface.completionBlocks) {
                        block(weakInterface);
                    }
                    [weakInterface clearAllCallBack];
                    [weakSelf toggleDidStopWithInterface:weakInterface];
                    if (weakInterface.request.requestTask) {
                        [weakSelf removeRequestOperation:weakInterface.request];
                    }
                    [weakSelf removeInterfaceForTaskIdentifier:weakInterface.taskIdentifier];
                }
            });
        };
        id<JSNetworkRequestConfigProtocol> processedConfig = weakInterface.processedConfig;
        BOOL isSaveCache = NO;
        if (setCacheDataIfNeeded && processedConfig.cachePolicy == JSRequestCachePolicyUseCacheDataElseLoad && !error) {
            isSaveCache = [processedConfig cacheIsSavedWithResponse:weakInterface.response];
        }
        if (isSaveCache) {
            /// 设置缓存
            [weakInterface.diskCache setCacheData:responseObject
                                 forRequestConfig:processedConfig
                                        completed:^(id<JSNetworkDiskCacheMetadataProtocol> metadata) {
                completionBlock();
            }];
        } else {
            completionBlock();
        }
    });
}

/// 添加请求
- (void)performRequestOperation:(__kindof NSOperation<JSNetworkRequestProtocol> *)request {
    NSParameterAssert(request.requestTask);
    [self addLock];
    /// 设置下最大并发数
    NSInteger maxConcurrentCount = JSNetworkConfig.sharedConfig.requestMaxConcurrentCount;
    if (self.requestQueue.maxConcurrentOperationCount != maxConcurrentCount) {
        self.requestQueue.maxConcurrentOperationCount = maxConcurrentCount;
    }
    [self.requestQueue addOperation:request];
    [self postExecutingAndFinishedKVOWithRequest:request];
    [self unLock];
}

/// 移除请求
- (void)removeRequestOperation:(__kindof NSOperation<JSNetworkRequestProtocol> *)request {
    NSParameterAssert(request.requestTask);
    [self addLock];
    [self postExecutingAndFinishedKVOWithRequest:request];
    [self unLock];
}

- (void)postExecutingAndFinishedKVOWithRequest:(__kindof NSOperation<JSNetworkRequestProtocol> *)request {
    [request willChangeValueForKey:@"isExecuting"];
    [request didChangeValueForKey:@"isExecuting"];
    [request willChangeValueForKey:@"isFinished"];
    [request didChangeValueForKey:@"isFinished"];
}

/// 添加接口
- (void)performInterface:(id<JSNetworkInterfaceProtocol>)interface forTaskIdentifier:(NSString *)taskIdentifier {
    NSParameterAssert(interface && taskIdentifier);
    [self addLock];
    if ([_interfaceRecord objectForKey:taskIdentifier]) {
        JSNetworkLog(@"警告 - interface即将被覆盖, 请检查是否添加了相同的taskIdentifier!!!");
    }
    [_interfaceRecord setObject:interface forKey:taskIdentifier];
    [self unLock];
}

/// 移除接口
- (void)removeInterfaceForTaskIdentifier:(NSString *)taskIdentifier {
    NSParameterAssert(taskIdentifier);
    [self addLock];
    [_interfaceRecord removeObjectForKey:taskIdentifier];
    [self unLock];
}

#pragma mark - 锁

- (void)addLock {
    os_unfair_lock_lock(&_lock);
}

- (void)unLock {
    os_unfair_lock_unlock(&_lock);
}

@end

@implementation JSNetworkAgent (Plugin)

- (void)toggleWillStartWithInterface:(id<JSNetworkInterfaceProtocol>)interface {
    NSParameterAssert(interface);
    id<JSNetworkRequestConfigProtocol> processedConfig = interface.processedConfig;
    for (id<JSNetworkPluginProtocol> plugin in processedConfig.requestPlugins) {
        if ([plugin respondsToSelector:@selector(requestWillStart:)]) {
            [plugin requestWillStart:interface];
        }
    }
}

- (void)toggleDidStartWithInterface:(id<JSNetworkInterfaceProtocol>)interface {
    NSParameterAssert(interface);
    id<JSNetworkRequestConfigProtocol> processedConfig = interface.processedConfig;
    for (id<JSNetworkPluginProtocol> plugin in processedConfig.requestPlugins) {
        if ([plugin respondsToSelector:@selector(requestDidStart:)]) {
            [plugin requestDidStart:interface];
        }
    }
}

- (void)toggleWillStopWithInterface:(id<JSNetworkInterfaceProtocol>)interface {
    NSParameterAssert(interface);
    id<JSNetworkRequestConfigProtocol> processedConfig = interface.processedConfig;
    for (id<JSNetworkPluginProtocol> plugin in processedConfig.requestPlugins) {
        if ([plugin respondsToSelector:@selector(requestWillStop:)]) {
            [plugin requestWillStop:interface];
        }
    }
}

- (void)toggleDidStopWithInterface:(id<JSNetworkInterfaceProtocol>)interface {
    NSParameterAssert(interface);
    id<JSNetworkRequestConfigProtocol> processedConfig = interface.processedConfig;
    for (id<JSNetworkPluginProtocol> plugin in processedConfig.requestPlugins) {
        if ([plugin respondsToSelector:@selector(requestDidStop:)]) {
            [plugin requestDidStop:interface];
        }
    }
}

@end
