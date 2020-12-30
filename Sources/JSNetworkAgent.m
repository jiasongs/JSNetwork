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
        _interfaceRecord = [NSMutableDictionary dictionary];
        _lock = OS_UNFAIR_LOCK_INIT;
        _requestQueue = [[NSOperationQueue alloc] init];
        _requestQueue.name = @"com.jsnetwork.agent.queue";
    }
    return self;
}

#pragma mark - Pubilc

- (void)addRequestForInterface:(id<JSNetworkInterfaceProtocol>)interface {
    NSParameterAssert(interface);
    [self toggleWillStartWithInterface:interface];
    if (interface.processedConfig.cacheIgnore) {
        [self processingRequestForInterface:interface];
    } else {
        [self processingDiskCacheForInterface:interface];
    }
    [self toggleDidStartWithInterface:interface];
}

- (void)cancelRequestForInterface:(id<JSNetworkInterfaceProtocol>)interface {
    if (interface.request.requestTask) {
        /// 正在运行时才可以取消
        if (interface.request.isExecuting) {
            [interface.request cancel];
        }
    }
}

- (void)cancelRequestForTaskIdentifier:(NSString *)taskIdentifier {
    id<JSNetworkInterfaceProtocol> interface = [self interfaceForTaskIdentifier:taskIdentifier];
    if (interface) {
        [self cancelRequestForInterface:interface];
    }
}

#pragma mark - Private

/// 处理请求
- (void)processingRequestForInterface:(id<JSNetworkInterfaceProtocol>)interface {
    NSParameterAssert(interface && interface.request.interfaceProxy);
    __weak typeof(self) weakSelf = self;
    __weak typeof(interface) weakInterface = interface;
    id<JSNetworkRequestConfigProtocol> processedConfig = interface.processedConfig;
    [interface.request buildTaskWithRequestConfig:processedConfig
                                    taskCompleted:^(id responseObject, NSError *error) {
        @autoreleasepool {
            [weakSelf processingResponseForInterface:weakInterface
                                  withResponseObject:responseObject
                                    needSetCacheData:YES
                                               error:error];
        }
    }];
    [self addInterface:interface forTaskIdentifier:interface.request.taskIdentifier];
    [self addRequestOperation:interface.request];
}

/// 处理缓存
- (void)processingDiskCacheForInterface:(id<JSNetworkInterfaceProtocol>)interface {
    id<JSNetworkRequestConfigProtocol> processedConfig = interface.processedConfig;
    NSParameterAssert(processedConfig.cacheTimeInSeconds > 0 || processedConfig.cacheVersion > 0);
    __weak typeof(self) weakSelf = self;
    __weak typeof(interface) weakInterface = interface;
    /// 缓存处理
    [interface.diskCache buildTaskWithRequestConfig:processedConfig taskCompleted:^(id<JSNetworkDiskCacheMetadataProtocol> metadata) {
        @autoreleasepool {
            if (metadata) {
                /// 存在缓存时
                [weakSelf processingResponseForInterface:weakInterface
                                      withResponseObject:metadata.cacheData
                                        needSetCacheData:NO
                                                   error:nil];
            } else {
                /// 处理网络请求
                [weakSelf processingRequestForInterface:weakInterface];
                /// 不存在缓存时，需要清除缓存任务
                [weakSelf removeInterfaceForTaskIdentifier:weakInterface.diskCache.taskIdentifier];
            }
        }
    }];
    [self addInterface:interface forTaskIdentifier:interface.diskCache.taskIdentifier];
}

/// 处理响应
- (void)processingResponseForInterface:(id<JSNetworkInterfaceProtocol>)interface
                    withResponseObject:(nullable id)responseObject
                      needSetCacheData:(BOOL)needSetCacheData
                                 error:(nullable NSError *)error {
    NSParameterAssert(interface);
    dispatch_queue_t processingQueue = JSNetworkConfig.sharedConfig.processingQueue;
    dispatch_queue_t completionQueue = JSNetworkConfig.sharedConfig.completionQueue;
    dispatch_async(processingQueue, ^{
        /// 处理响应
        @autoreleasepool {
            [interface.response processingTask:interface.request.requestTask
                                responseObject:responseObject
                                         error:error];
        }
        __weak typeof(self) weakSelf = self;
        __weak typeof(interface) weakInterface = interface;
        void(^completionBlock)(void) = ^(void) {
            dispatch_async(completionQueue, ^{
                @autoreleasepool {
                    [weakSelf toggleWillStopWithInterface:weakInterface];
                    for (JSNetworkRequestCompletedFilter block in weakInterface.completionBlocks) {
                        block(weakInterface);
                    }
                    [weakInterface clearAllCallBack];
                    [weakSelf toggleDidStopWithInterface:weakInterface];
                    if (weakInterface.request.requestTask) {
                        [weakSelf removeRequestOperation:weakInterface.request];
                        [weakSelf removeInterfaceForTaskIdentifier:weakInterface.request.taskIdentifier];
                    } else {
                        [weakSelf removeInterfaceForTaskIdentifier:weakInterface.diskCache.taskIdentifier];
                    }
                }
            });
        };
        id<JSNetworkRequestConfigProtocol> processedConfig = interface.processedConfig;
        BOOL isSaveCache = NO;
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

/// 添加请求
- (void)addRequestOperation:(__kindof NSOperation<JSNetworkRequestProtocol> *)request {
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
- (void)addInterface:(id<JSNetworkInterfaceProtocol>)interface forTaskIdentifier:(NSString *)taskIdentifier {
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

/// 获得一个接口
- (nullable id<JSNetworkInterfaceProtocol>)interfaceForTaskIdentifier:(NSString *)taskIdentifier {
    NSParameterAssert(taskIdentifier);
    [self addLock];
    id<JSNetworkInterfaceProtocol> interface = [_interfaceRecord objectForKey:taskIdentifier];
    [self unLock];
    return interface;
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
