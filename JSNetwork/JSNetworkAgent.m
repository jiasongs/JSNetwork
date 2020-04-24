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

@interface JSNetworkAgent ()

@property (nonatomic, strong) NSOperationQueue *requestQueue;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, id<JSNetworkInterfaceProtocol>> *requestsRecord;
@property (nonatomic, strong) dispatch_semaphore_t lock;

@end

@implementation JSNetworkAgent

+ (instancetype)sharedAgent {
    static dispatch_once_t onceToken;
    static JSNetworkAgent *instance = nil;
    dispatch_once(&onceToken,^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return [self sharedAgent];
}

- (instancetype)init {
    if (self = [super init]) {
        _requestsRecord = [NSMutableDictionary dictionary];
        _lock = dispatch_semaphore_create(1);
        _requestQueue = [[NSOperationQueue alloc] init];
        _requestQueue.name = @"com.jsnetwork.agent";
    }
    return self;;
}

- (void)processingInterface:(id<JSNetworkInterfaceProtocol>)interface {
    NSParameterAssert(interface);
    NSParameterAssert(interface.request);
    [self toggleWillStartWithInterface:interface];
    id<JSNetworkRequestConfigProtocol> processedConfig = interface.processedConfig;
    if (!processedConfig.cacheIgnore) {
        NSParameterAssert(processedConfig.cacheTimeInSeconds > 0 || processedConfig.cacheVersion > 0);
        __weak typeof(self) weakSelf = self;
        /// 缓存处理
        [interface.diskCache validCacheForRequestConfig:processedConfig completed:^(id<JSNetworkDiskCacheMetadataProtocol> metadata) {
            if (metadata) {
                /// 存在缓存时
                @autoreleasepool {
                    [weakSelf processingResponseWithInterface:interface
                                               responseObject:metadata.cacheData
                                             needSetCacheData:false
                                                        error:nil];
                }
            } else {
                /// 不存在缓存，按照请求处理顺序执行
                [weakSelf processingRequestWithInterface:interface];
            }
        }];
        [self toggleDidStartWithInterface:interface];
    } else {
        [self processingRequestWithInterface:interface];
        [self toggleDidStartWithInterface:interface];
    }
}

- (void)processingRequestWithInterface:(id<JSNetworkInterfaceProtocol>)interface {
    __weak typeof(self) weakSelf = self;
    __weak typeof(interface) weakInterface = interface;
    id<JSNetworkRequestConfigProtocol> processedConfig = interface.processedConfig;
    [interface.request buildTaskWithRequestConfig:processedConfig taskCompleted:^(id responseObject, NSError *error) {
        [weakSelf processingResponseWithInterface:weakInterface
                                   responseObject:responseObject
                                 needSetCacheData:true
                                            error:error];
    }];
    [self addOperationWithInterface:interface];
}

- (void)processingResponseWithInterface:(id<JSNetworkInterfaceProtocol>)interface
                         responseObject:(nullable id)responseObject
                       needSetCacheData:(BOOL)needSetCacheData
                                  error:(nullable NSError *)error {
    NSParameterAssert(interface);
    dispatch_queue_t processingQueue = JSNetworkConfig.sharedConfig.processingQueue;
    dispatch_queue_t completionQueue = JSNetworkConfig.sharedConfig.completionQueue;
    dispatch_async(processingQueue, ^{
        /// 处理响应
        [interface.response processingTask:interface.request.requestTask responseObject:responseObject error:error];
        void(^completionBlock)(void) = ^(void) {
            dispatch_async(completionQueue, ^{
                [self toggleWillStopWithInterface:interface];
                @autoreleasepool {
                    for (JSNetworkRequestCompletedFilter block in interface.request.completedFilters) {
                        block(interface);
                    }
                }
                [interface.request clearAllCallBack];
                [self toggleDidStopWithInterface:interface];
                [self removeOperationWithInterface:interface];
            });
        };
        id<JSNetworkRequestConfigProtocol> processedConfig = interface.processedConfig;
        BOOL isSaveCache = false;
        if (needSetCacheData && !processedConfig.cacheIgnore && !error) {
            isSaveCache = [processedConfig cacheIsSavedWithResponse:interface.response];
        }
        if (isSaveCache) {
            /// 设置缓存
            [interface.diskCache setCacheData:responseObject
                             forRequestConfig:processedConfig
                                    completed:^(id<JSNetworkDiskCacheMetadataProtocol> metadata) {
                completionBlock();
            }];
        } else {
            completionBlock();
        }
    });
}

- (void)addOperationWithInterface:(id<JSNetworkInterfaceProtocol>)interface {
    NSParameterAssert(interface);
    if (!interface.request.requestTask) {
        return;
    }
    NSParameterAssert([interface.request isKindOfClass:NSOperation.class]);
    [self addInterfaceToRecord:interface];
    [self.requestQueue addOperation:interface.request];
    [self postExecutingAndFinishedKVOWithRequest:interface.request];
}

- (void)removeOperationWithInterface:(id<JSNetworkInterfaceProtocol>)interface {
    NSParameterAssert(interface);
    if (!interface.request.requestTask) {
        return;
    }
    if (interface.request.isExecuting) {
        [interface.request cancel];
    } else {
        [self postExecutingAndFinishedKVOWithRequest:interface.request];
        [self removeInterfaceFromRecord:interface];
    }
}

- (void)addInterfaceToRecord:(id<JSNetworkInterfaceProtocol>)interface {
    [self addLock];
    if ([_requestsRecord objectForKey:@(interface.request.requestTask.taskIdentifier)]) {
        JSNetworkLog(@"interface即将被覆盖, 请检查是否添加了相同的taskIdentifier, 多发生在多个AFNManager的情况");
    }
    [_requestsRecord setObject:interface forKey:@(interface.request.requestTask.taskIdentifier)];
    [self unLock];
}

- (void)removeInterfaceFromRecord:(id<JSNetworkInterfaceProtocol>)interface {
    [self addLock];
    [_requestsRecord removeObjectForKey:@(interface.request.requestTask.taskIdentifier)];
    [self unLock];
}

- (void)postExecutingAndFinishedKVOWithRequest:(__kindof NSOperation<JSNetworkRequestProtocol> *)request {
    NSParameterAssert(request);
    [request willChangeValueForKey:@"isExecuting"];
    [request didChangeValueForKey:@"isExecuting"];
    [request willChangeValueForKey:@"isFinished"];
    [request didChangeValueForKey:@"isFinished"];
}

- (void)addLock {
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
}

- (void)unLock {
    dispatch_semaphore_signal(_lock);
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
