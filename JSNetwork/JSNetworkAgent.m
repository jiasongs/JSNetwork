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
@property (nonatomic, strong) NSMutableDictionary<NSString *, id<JSNetworkInterfaceProtocol>> *requestsRecord;
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
        __weak typeof(interface) weakInterface = interface;
        /// 缓存处理
        /// 思考: 怎么才能持有interface, taskID哪里来,
        /// interface持有diskCache, diskCache可能会持有completed, completed不能持有interface
        /// 否则会造成循环引用, 这样的话只能Agent类去持有, 但是taskID哪里来呢, 头疼
        /// 先构建缓存任务
        [interface.diskCache buildTaskWithRequestConfig:processedConfig];
        [interface.diskCache validCacheForRequestConfig:processedConfig
                                              completed:^(id<JSNetworkDiskCacheMetadataProtocol> metadata) {
            if (metadata) {
                /// 存在缓存时
                @autoreleasepool {
                    [weakSelf processingResponseWithInterface:weakInterface
                                               responseObject:metadata.cacheData
                                             needSetCacheData:false
                                                        error:nil];
                }
            } else {
                /// 执行网络请求
                [weakSelf processingRequestWithInterface:weakInterface];
                /// 不存在缓存时，需要清除缓存任务
                [self removeInterfaceForTaskIdentifier:weakInterface.diskCache.taskIdentifier];
            }
        }];
        [self addInterface:interface forTaskIdentifier:weakInterface.diskCache.taskIdentifier];
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
    [interface.request buildTaskWithRequestConfig:processedConfig
                                    taskCompleted:^(id responseObject, NSError *error) {
        [weakSelf processingResponseWithInterface:weakInterface
                                   responseObject:responseObject
                                 needSetCacheData:true
                                            error:error];
    }];
    [self addInterface:interface forTaskIdentifier:interface.request.taskIdentifier];
    [self addRequestOperation:interface.request];
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
        [interface.response processingTask:interface.request.requestTask
                            responseObject:responseObject
                                     error:error];
        __weak typeof(interface) weakInterface = interface;
        void(^completionBlock)(void) = ^(void) {
            dispatch_async(completionQueue, ^{
                [self toggleWillStopWithInterface:weakInterface];
                @autoreleasepool {
                    for (JSNetworkRequestCompletedFilter block in weakInterface.request.completedFilters) {
                        block(weakInterface);
                    }
                }
                [weakInterface.request clearAllCallBack];
                [self toggleDidStopWithInterface:weakInterface];
                if (weakInterface.request.requestTask) {
                    [self removeRequestOperation:weakInterface.request];
                    [self removeInterfaceForTaskIdentifier:weakInterface.request.taskIdentifier];
                } else {
                    [self removeInterfaceForTaskIdentifier:weakInterface.diskCache.taskIdentifier];
                }
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

- (void)addRequestOperation:(__kindof NSOperation<JSNetworkRequestProtocol> *)request {
    NSParameterAssert(request && request.requestTask);
    [self.requestQueue addOperation:request];
    [self postExecutingAndFinishedKVOWithRequest:request];
}

- (void)removeRequestOperation:(__kindof NSOperation<JSNetworkRequestProtocol> *)request {
    NSParameterAssert(request && request.requestTask);
    if (request.isExecuting) {
        [request cancel];
    } else {
        [self postExecutingAndFinishedKVOWithRequest:request];
    }
}

- (void)addInterface:(id<JSNetworkInterfaceProtocol>)interface forTaskIdentifier:(NSString *)taskIdentifier {
    NSParameterAssert(interface && taskIdentifier);
    [self addLock];
    if ([_requestsRecord objectForKey:taskIdentifier]) {
        JSNetworkLog(@"interface即将被覆盖, 请检查是否添加了相同的taskIdentifier, 多发生在多个AFNManager的情况");
    }
    [_requestsRecord setObject:interface forKey:taskIdentifier];
    [self unLock];
}

- (void)removeInterfaceForTaskIdentifier:(NSString *)taskIdentifier {
    NSParameterAssert(taskIdentifier);
    [self addLock];
    [_requestsRecord removeObjectForKey:taskIdentifier];
    [self unLock];
}

- (void)postExecutingAndFinishedKVOWithRequest:(__kindof NSOperation<JSNetworkRequestProtocol> *)request {
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
