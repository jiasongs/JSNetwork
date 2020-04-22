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
    if (!interface.ignoreCache) {
        NSParameterAssert(interface.cacheTimeInSeconds > 0 || interface.cacheVersion > 0);
        __weak typeof(self) weakSelf = self;
        /// 缓存处理
        [interface.diskCache validCacheForInterface:interface completed:^(id<JSNetworkDiskCacheMetadataProtocol> metadata) {
            if (metadata) {
                /// 存在缓存时
                @autoreleasepool {
                    [weakSelf toggleDidStartWithInterface:interface];
                    [weakSelf processingResponseWithInterface:interface responseObject:metadata.cacheData error:nil];
                }
            } else {
                /// 不存在缓存，按照请求处理顺序执行
                [weakSelf processingRequestWithInterface:interface];
            }
        }];
    } else {
        [self processingRequestWithInterface:interface];
    }
}

- (void)processingRequestWithInterface:(id<JSNetworkInterfaceProtocol>)interface {
    __weak typeof(self) weakSelf = self;
    __weak typeof(interface) weakInterface = interface;
    [interface.request buildTaskWithInterface:weakInterface taskCompleted:^(id responseObject, NSError *error) {
        if (!weakInterface.ignoreCache) {
            /// 设置缓存
            [weakInterface.diskCache setCacheData:responseObject
                                     forInterface:weakInterface
                                        completed:^(id<JSNetworkDiskCacheMetadataProtocol> metadata) {
                [weakSelf processingResponseWithInterface:weakInterface responseObject:responseObject error:error];
            }];
        } else {
            [weakSelf processingResponseWithInterface:weakInterface responseObject:responseObject error:error];
        }
    }];
    [self addOperationWithInterface:weakInterface];
    [self toggleDidStartWithInterface:weakInterface];
}

- (void)processingResponseWithInterface:(id<JSNetworkInterfaceProtocol>)interface
                         responseObject:(nullable id)responseObject
                                  error:(nullable NSError *)error {
    NSParameterAssert(interface);
    dispatch_queue_t processingQueue = JSNetworkConfig.sharedConfig.processingQueue;
    dispatch_queue_t completionQueue = JSNetworkConfig.sharedConfig.completionQueue;
    dispatch_async(processingQueue, ^{
        /// 处理响应
        [interface.response processingTaskWithInterface:interface responseObject:responseObject error:error];
        dispatch_async(completionQueue, ^{
            [self toggleWillStopWithInterface:interface];
            @autoreleasepool {
                for (JSNetworkRequestCompletedFilter block in interface.request.completedFilters) {
                    block(interface);
                }
            }
            [interface.request clearAllCallBack];
            [self toggleDidStopWithInterface:interface];
            if (interface.request.requestTask) {
                [self removeOperationWithInterface:interface];
            }
        });
    });
}

- (void)addOperationWithInterface:(id<JSNetworkInterfaceProtocol>)interface {
    NSParameterAssert(interface.request && [interface.request isKindOfClass:NSOperation.class]);
    [self addInterfaceToRecord:interface];
    [self.requestQueue addOperation:interface.request];
    [self postExecutingAndFinishedKVOWithRequest:interface.request];
}

- (void)removeOperationWithInterface:(id<JSNetworkInterfaceProtocol>)interface {
    NSParameterAssert(interface);
    if (interface.request.isExecuting) {
        [interface.request cancel];
    } else {
        [self postExecutingAndFinishedKVOWithRequest:interface.request];
        [self removeInterfaceFromRecord:interface];
    }
}

- (void)addInterfaceToRecord:(id<JSNetworkInterfaceProtocol>)interface {
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    if ([_requestsRecord objectForKey:@(interface.request.requestTask.taskIdentifier)]) {
        JSNetworkLog(@"interface即将被覆盖, 请检查是否添加了相同的taskIdentifier, 多发生在多个AFNManager的情况");
    }
    [_requestsRecord setObject:interface forKey:@(interface.request.requestTask.taskIdentifier)];
    dispatch_semaphore_signal(_lock);
}

- (void)removeInterfaceFromRecord:(id<JSNetworkInterfaceProtocol>)interface {
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    [_requestsRecord removeObjectForKey:@(interface.request.requestTask.taskIdentifier)];
    dispatch_semaphore_signal(_lock);
}

- (void)postExecutingAndFinishedKVOWithRequest:(__kindof NSOperation<JSNetworkRequestProtocol> *)request {
    [request willChangeValueForKey:@"isExecuting"];
    [request didChangeValueForKey:@"isExecuting"];
    [request willChangeValueForKey:@"isFinished"];
    [request didChangeValueForKey:@"isFinished"];
}

@end

@implementation JSNetworkAgent (Plugin)

- (void)toggleWillStartWithInterface:(id<JSNetworkInterfaceProtocol>)interface {
    NSParameterAssert(interface);
    for (id<JSNetworkPluginProtocol> plugin in interface.allPlugins) {
        if ([plugin respondsToSelector:@selector(requestWillStart:)]) {
            [plugin requestWillStart:interface];
        }
    }
}

- (void)toggleDidStartWithInterface:(id<JSNetworkInterfaceProtocol>)interface {
    NSParameterAssert(interface);
    for (id<JSNetworkPluginProtocol> plugin in interface.allPlugins) {
        if ([plugin respondsToSelector:@selector(requestDidStart:)]) {
            [plugin requestDidStart:interface];
        }
    }
}

- (void)toggleWillStopWithInterface:(id<JSNetworkInterfaceProtocol>)interface {
    NSParameterAssert(interface);
    for (id<JSNetworkPluginProtocol> plugin in interface.allPlugins) {
        if ([plugin respondsToSelector:@selector(requestWillStop:)]) {
            [plugin requestWillStop:interface];
        }
    }
}

- (void)toggleDidStopWithInterface:(id<JSNetworkInterfaceProtocol>)interface {
    NSParameterAssert(interface);
    for (id<JSNetworkPluginProtocol> plugin in interface.allPlugins) {
        if ([plugin respondsToSelector:@selector(requestDidStop:)]) {
            [plugin requestDidStop:interface];
        }
    }
}

@end
