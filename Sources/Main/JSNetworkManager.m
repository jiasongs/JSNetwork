//
//  JSNetworkManager.m
//  JSNetwork
//
//  Created by jiasong on 2020/4/17.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import "JSNetworkManager.h"
#import "JSNetworkRequestConfigProxy.h"
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

@interface JSNetworkManager () {
    os_unfair_lock _lock;
}

@property (nonatomic, strong) NSOperationQueue *requestQueue;
@property (nonatomic, strong) NSMutableDictionary<NSString *, id<JSNetworkInterfaceProtocol>> *interfaceRecord;

@end

@implementation JSNetworkManager

+ (instancetype)defaultManager {
    static dispatch_once_t onceToken;
    static JSNetworkManager *instance = nil;
    dispatch_once(&onceToken,^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        _lock = OS_UNFAIR_LOCK_INIT;
        
        self.interfaceRecord = [NSMutableDictionary dictionary];
        self.requestQueue = [[NSOperationQueue alloc] init];
        self.requestQueue.name = @"com.jsnetwork.manager.operationqueue";
    }
    return self;
}

#pragma mark - Pubilc

- (void)performRequestForInterface:(id<JSNetworkInterfaceProtocol>)interface {
    if (![self validateInterface:interface]) {
        return;
    }
    
    if (!interface.config.isProxy) {
        interface.config = [JSNetworkRequestConfigProxy proxyWithTarget:interface.config];
    }
    
    /// 首先需要添加interface
    [self performInterface:interface forTaskIdentifier:interface.taskIdentifier];
    /// 处理请求
    [self toggleWillStartWithInterface:interface];
    if (interface.config.cachePolicy == JSRequestCachePolicyUseCacheDataElseLoad) {
        [self processingDiskCacheForInterface:interface];
    } else {
        [self processingRequestForInterface:interface];
    }
    [self toggleDidStartWithInterface:interface];
}

- (void)cancelRequestForInterface:(id<JSNetworkInterfaceProtocol>)interface {
    if (![self validateInterface:interface]) {
        return;
    }
    
    if (interface.request.requestTask) {
        [interface.request cancel];
    }
}

- (void)cancelRequestForTaskIdentifier:(NSString *)taskIdentifier {
    id<JSNetworkInterfaceProtocol> interface = [self interfaceForTaskIdentifier:taskIdentifier];
    if (interface) {
        [self cancelRequestForInterface:interface];
    } else {
        JSNetworkLog(@"interface已经被释放");
    }
}

/// 获得一个接口
- (nullable id<JSNetworkInterfaceProtocol>)interfaceForTaskIdentifier:(NSString *)taskIdentifier {
    NSParameterAssert(taskIdentifier);
    
    [self addLock];
    id<JSNetworkInterfaceProtocol> interface = [self.interfaceRecord objectForKey:taskIdentifier];
    [self unLock];
    return interface;
}

#pragma mark - Private

/// 处理请求
- (void)processingRequestForInterface:(id<JSNetworkInterfaceProtocol>)interface {
    if (![self validateInterface:interface]) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    NSString *taskIdentifier = interface.taskIdentifier;
    [interface.request buildTaskWithConfig:interface.config
                            uploadProgress:^(NSProgress *uploadProgress) {
        id<JSNetworkInterfaceProtocol> taskInterface = [weakSelf interfaceForTaskIdentifier:taskIdentifier];
        if (taskInterface.uploadProgress) {
            taskInterface.uploadProgress(uploadProgress);
        }
    } downloadProgress:^(NSProgress *downloadProgress) {
        id<JSNetworkInterfaceProtocol> taskInterface = [weakSelf interfaceForTaskIdentifier:taskIdentifier];
        if (taskInterface.downloadProgress) {
            taskInterface.downloadProgress(downloadProgress);
        }
    } constructingFormData:^(id formData) {
        id<JSNetworkInterfaceProtocol> taskInterface = [weakSelf interfaceForTaskIdentifier:taskIdentifier];
        if ([taskInterface.config respondsToSelector:@selector(requestConstructingMultipartFormData:)]) {
            [taskInterface.config requestConstructingMultipartFormData:formData];
        }
    } didCreateURLRequest:^NSURLRequest *(NSURLRequest *urlRequest) {
        NSMutableURLRequest *mutableURLRequest = [urlRequest isKindOfClass:NSMutableURLRequest.class] ? urlRequest : [urlRequest mutableCopy];
        id<JSNetworkInterfaceProtocol> taskInterface = [weakSelf interfaceForTaskIdentifier:taskIdentifier];
        /// 二进制的数据
        if (taskInterface && taskInterface.config.requestSerializerType == JSRequestSerializerTypeBinaryData) {
            id body = taskInterface.config.requestBody;
            if ([body isKindOfClass:NSData.class]) {
                [mutableURLRequest setHTTPBody:body];
            } else {
                NSAssert(NO, @"body必须为NSData类型");
            }
        }
        NSURLRequest *finallyURLRequest = mutableURLRequest;
        if ([taskInterface.config respondsToSelector:@selector(requestCompositeURLRequestWithURLRequest:)]) {
            finallyURLRequest = [taskInterface.config requestCompositeURLRequestWithURLRequest:finallyURLRequest];
        }
        return finallyURLRequest;
    } didCreateTask:^(NSURLSessionTask *task) {
        id<JSNetworkInterfaceProtocol> taskInterface = [weakSelf interfaceForTaskIdentifier:taskIdentifier];
        [weakSelf performRequestOperation:taskInterface.request];
    } didCompleted:^(id _Nullable responseObject, NSError * _Nullable error) {
        id<JSNetworkInterfaceProtocol> taskInterface = [weakSelf interfaceForTaskIdentifier:taskIdentifier];
        [weakSelf processingResponseForInterface:taskInterface
                              withResponseObject:responseObject
                            setCacheDataIfNeeded:YES
                                           error:error];
    }];
}

/// 处理缓存
- (void)processingDiskCacheForInterface:(id<JSNetworkInterfaceProtocol>)interface {
    id<JSNetworkRequestConfigProtocol> config = interface.config;
    NSParameterAssert(config.cacheTimeInSeconds > 0 || config.cacheVersion > 0);
    
    __weak typeof(self) weakSelf = self;
    NSString *taskIdentifier = interface.taskIdentifier;
    /// 缓存处理
    [interface.diskCache buildTaskWithConfig:config
                                didCompleted:^(id<JSNetworkDiskCacheMetadataProtocol> metadata) {
        id<JSNetworkInterfaceProtocol> taskInterface = [weakSelf interfaceForTaskIdentifier:taskIdentifier];
        if (metadata) {
            /// 存在缓存时
            [weakSelf processingResponseForInterface:taskInterface
                                  withResponseObject:metadata.cacheData
                                setCacheDataIfNeeded:NO
                                               error:nil];
        } else {
            /// 处理网络请求
            [weakSelf processingRequestForInterface:taskInterface];
        }
    }];
}

/// 处理响应
- (void)processingResponseForInterface:(id<JSNetworkInterfaceProtocol>)interface
                    withResponseObject:(nullable id)responseObject
                  setCacheDataIfNeeded:(BOOL)setCacheDataIfNeeded
                                 error:(nullable NSError *)error {
    if (![self validateInterface:interface]) {
        return;
    }
    
    dispatch_queue_t processingQueue = JSNetworkConfig.sharedConfig.processingQueue;
    dispatch_queue_t completionQueue = JSNetworkConfig.sharedConfig.completionQueue;
    dispatch_async(processingQueue, ^{
        /// 处理响应
        [interface.response processingTask:interface.request.requestTask
                            responseObject:responseObject
                                     error:error];
        __weak typeof(self) weakSelf = self;
        void(^completionBlock)(void) = ^(void) {
            dispatch_async(completionQueue, ^{
                [weakSelf toggleWillStopWithInterface:interface];
                interface.completionHandler(interface);
                interface.completionHandler = nil;
                interface.uploadProgress = nil;
                interface.downloadProgress = nil;
                [weakSelf toggleDidStopWithInterface:interface];
                if (interface.request.requestTask) {
                    [weakSelf removeRequestOperation:interface.request];
                }
                [weakSelf removeInterfaceForTaskIdentifier:interface.taskIdentifier];
            });
        };
        id<JSNetworkRequestConfigProtocol> config = interface.config;
        BOOL isSaveCache = NO;
        if (setCacheDataIfNeeded && config.cachePolicy == JSRequestCachePolicyUseCacheDataElseLoad && !error) {
            isSaveCache = [config cacheIsSavedWithResponse:interface.response];
        }
        if (isSaveCache) {
            /// 设置缓存
            [interface.diskCache setCacheData:responseObject
                             forRequestConfig:config
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
    if (!request.requestTask) {
        NSAssert(NO, @"requestTask无效，请按照堆栈检查此问题出现的原因");
        return;
    }
    
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
    [self addLock];
#ifdef DEBUG
    if ([self.interfaceRecord.allKeys containsObject:taskIdentifier]) {
        NSAssert(NO, @"警告 - interface即将被覆盖, 请检查是否添加了相同的taskIdentifier!!!");
    }
#endif
    [self.interfaceRecord setObject:interface forKey:taskIdentifier];
    [self unLock];
}

/// 移除接口
- (void)removeInterfaceForTaskIdentifier:(NSString *)taskIdentifier {
    NSParameterAssert(taskIdentifier);
    [self addLock];
    [self.interfaceRecord removeObjectForKey:taskIdentifier];
    [self unLock];
}

/// 检查interface
- (BOOL)validateInterface:(id<JSNetworkInterfaceProtocol>)interface {
    if (!interface || !interface.taskIdentifier || !interface.config || !interface.request || !interface.response) {
        NSAssert(NO, @"interface无效，请按照堆栈检查此问题出现的原因");
        return NO;
    } else {
        return YES;
    }
}

#pragma mark - 锁

- (void)addLock {
    os_unfair_lock_lock(&_lock);
}

- (void)unLock {
    os_unfair_lock_unlock(&_lock);
}

@end

@implementation JSNetworkManager (Plugin)

- (void)toggleWillStartWithInterface:(id<JSNetworkInterfaceProtocol>)interface {
    NSParameterAssert(interface);
    id<JSNetworkRequestConfigProtocol> config = interface.config;
    for (id<JSNetworkPluginProtocol> plugin in config.requestPlugins) {
        if ([plugin respondsToSelector:@selector(requestWillStart:)]) {
            [plugin requestWillStart:interface];
        }
    }
}

- (void)toggleDidStartWithInterface:(id<JSNetworkInterfaceProtocol>)interface {
    NSParameterAssert(interface);
    id<JSNetworkRequestConfigProtocol> config = interface.config;
    for (id<JSNetworkPluginProtocol> plugin in config.requestPlugins) {
        if ([plugin respondsToSelector:@selector(requestDidStart:)]) {
            [plugin requestDidStart:interface];
        }
    }
}

- (void)toggleWillStopWithInterface:(id<JSNetworkInterfaceProtocol>)interface {
    NSParameterAssert(interface);
    id<JSNetworkRequestConfigProtocol> config = interface.config;
    for (id<JSNetworkPluginProtocol> plugin in config.requestPlugins) {
        if ([plugin respondsToSelector:@selector(requestWillStop:)]) {
            [plugin requestWillStop:interface];
        }
    }
}

- (void)toggleDidStopWithInterface:(id<JSNetworkInterfaceProtocol>)interface {
    NSParameterAssert(interface);
    id<JSNetworkRequestConfigProtocol> config = interface.config;
    for (id<JSNetworkPluginProtocol> plugin in config.requestPlugins) {
        if ([plugin respondsToSelector:@selector(requestDidStop:)]) {
            [plugin requestDidStop:interface];
        }
    }
}

@end
