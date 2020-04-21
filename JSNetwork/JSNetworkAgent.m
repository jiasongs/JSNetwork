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
#import "JSNetworkInterface.h"
#import "JSNetworkUtil.h"

@interface JSNetworkAgent ()

@property (nonatomic, strong, readwrite) NSOperationQueue *requestQueue;
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
    __weak __typeof(self) weakSelf = self;
    [interface.request buildTaskWithInterface:interface taskCompleted:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
        /// 处理响应和回调之后移除
        [weakSelf processingResponseWithTask:task responseObject:responseObject error:error];
    }];
    [self addInterface:interface];
    [self toggleDidStartWithInterface:interface];
}

- (void)processingResponseWithTask:(NSURLSessionTask *)task
                    responseObject:(nullable id)responseObject
                             error:(nullable NSError *)error {
    NSParameterAssert(task);
    id<JSNetworkInterfaceProtocol> interface = [self getInterfaceWithTask:task];
    if (!interface) JSNetworkLog(@"interface为nil, 请检查调用顺序是否正确, 请求是否被覆盖, 正常情况下不可能为nil");
    NSParameterAssert(interface);
    dispatch_async(interface.processingQueue, ^{
        /// 处理响应
        [interface.response processingTask:task responseObject:responseObject error:error];
        dispatch_async(interface.completionQueue, ^{
            [self toggleWillStopWithInterface:interface];
            @autoreleasepool {
                for (JSNetworkRequestCompletedFilter block in interface.request.completedFilters) {
                    block(interface);
                }
            }
            [self toggleDidStopWithInterface:interface];
            [self removeInterface:interface];
        });
    });
}

- (void)addInterface:(id<JSNetworkInterfaceProtocol>)interface {
    NSParameterAssert(interface);
    NSParameterAssert(interface.request);
    NSParameterAssert([interface.request isKindOfClass:NSOperation.class]);
    [self addInterfaceToRecord:interface];
    [self.requestQueue addOperation:interface.request];
    [self postExecutingAndFinishedKVOWithRequest:interface.request];
}

- (void)removeInterface:(id<JSNetworkInterfaceProtocol>)interface {
    NSParameterAssert(interface);
    NSParameterAssert(interface.request);
    if (interface.request.isExecuting) {
        [interface.request cancel];
    } else {
        [interface.request clearAllCallBack];
        [self postExecutingAndFinishedKVOWithRequest:interface.request];
        [self removeInterfaceFromRecord:interface];
    }
}

- (id<JSNetworkInterfaceProtocol>)getInterfaceWithTask:(NSURLSessionTask *)task {
    NSParameterAssert(task);
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    id<JSNetworkInterfaceProtocol> interface = [_requestsRecord objectForKey:@(task.taskIdentifier)];
    dispatch_semaphore_signal(_lock);
    return interface;
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
    if (![_requestsRecord objectForKey:@(interface.request.requestTask.taskIdentifier)]) {
        JSNetworkLog(@"interface不存在, 请检查interface是否被覆盖, 多发生在多个AFNManager的情况");
    }
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
