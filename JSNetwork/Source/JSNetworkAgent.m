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
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, __kindof NSOperation<JSNetworkRequestProtocol> *> *requestsRecord;
@property (nonatomic, strong) dispatch_semaphore_t lock;

@end

@implementation JSNetworkAgent

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static JSNetworkAgent *instance = nil;
    dispatch_once(&onceToken,^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return [self sharedInstance];
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

- (void)processingRequest:(__kindof NSOperation<JSNetworkRequestProtocol> *)request {
    NSParameterAssert(request);
    NSArray *plugins = request.requestInterface.allPlugins;
    [self toggleWillStartWithPlugins:plugins request:request];
    [self addRequest:request];
    [self toggleDidStartWithPlugins:plugins request:request];
}

- (void)processingResponseWithTask:(NSURLSessionTask *)task
                    responseObject:(nullable id)responseObject
                             error:(nullable NSError *)error {
    NSParameterAssert(task);
    __kindof NSOperation<JSNetworkRequestProtocol> *request = [self getRequestWithTask:task];
    if (!request) JSNetworkLog(@"request为nil, 请检查调用顺序是否正确, 请求是否被覆盖, 正常情况下不可能为nil");
    NSParameterAssert(request);
    dispatch_async(request.requestInterface.processingQueue, ^{
        /// 处理响应
        [request.response processingTask:task responseObject:responseObject error:error];
        dispatch_async(request.requestInterface.completionQueue, ^{
            NSArray *plugins = request.requestInterface.allPlugins;
            [self toggleWillStopWithPlugins:plugins request:request];
            @autoreleasepool {
                for (JSNetworkRequestCompletedFilter block in request.completedFilters) {
                    block(request);
                }
            }
            [self toggleDidStopWithPlugins:plugins request:request];
            [self removeRequest:request];
        });
    });
}

- (nullable __kindof NSOperation<JSNetworkRequestProtocol> *)getRequestWithTask:(NSURLSessionTask *)task {
    NSParameterAssert(task);
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    id<JSNetworkRequestProtocol> request = [_requestsRecord objectForKey:@(task.taskIdentifier)];
    dispatch_semaphore_signal(_lock);
    return request;
}

- (void)addRequest:(__kindof NSOperation<JSNetworkRequestProtocol> *)request {
    NSParameterAssert(request);
    [self addRequestToRecord:request];
    [self.requestQueue addOperation:request];
    [self postExecuteAndFinishNotificationWithRequest:request];
}

- (void)removeRequest:(__kindof NSOperation<JSNetworkRequestProtocol> *)request {
    NSParameterAssert(request);
    if (request.isExecuting) {
        [request cancel];
    } else {
        [request clearAllCallBack];
        [self postExecuteAndFinishNotificationWithRequest:request];
        [self removeRequestFromRecord:request];
    }
}

- (void)addRequestToRecord:(__kindof NSOperation<JSNetworkRequestProtocol> *)request {
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    if ([_requestsRecord objectForKey:@(request.requestTask.taskIdentifier)]) {
        JSNetworkLog(@"request即将被覆盖, 请检查是否相同的taskIdentifier被添加, 多发生在多个AFNManager的情况");
    }
    [_requestsRecord setValue:request forKey:@(request.requestTask.taskIdentifier)];
    dispatch_semaphore_signal(_lock);
}

- (void)removeRequestFromRecord:(__kindof NSOperation<JSNetworkRequestProtocol> *)request {
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    if (![_requestsRecord objectForKey:@(request.requestTask.taskIdentifier)]) {
        JSNetworkLog(@"request不存在, 请检查request是否被覆盖, 多发生在多个AFNManager的情况");
    }
    [_requestsRecord removeObjectForKey:@(request.requestTask.taskIdentifier)];
    dispatch_semaphore_signal(_lock);
}

- (void)postExecuteAndFinishNotificationWithRequest:(__kindof NSOperation<JSNetworkRequestProtocol> *)request {
    [request willChangeValueForKey:@"isExecuting"];
    [request didChangeValueForKey:@"isExecuting"];
    [request willChangeValueForKey:@"isFinished"];
    [request didChangeValueForKey:@"isFinished"];
}

@end

@implementation JSNetworkAgent (Plugin)

- (void)toggleWillStartWithPlugins:(NSArray *)plugins request:(id<JSNetworkRequestProtocol>)request {
    NSParameterAssert(request);
    for (id<JSNetworkPluginProtocol> plugin in plugins) {
        if ([plugin respondsToSelector:@selector(requestWillStart:)]) {
            [plugin requestWillStart:request];
        }
    }
}

- (void)toggleDidStartWithPlugins:(NSArray *)plugins request:(id<JSNetworkRequestProtocol>)request {
    NSParameterAssert(request);
    for (id<JSNetworkPluginProtocol> plugin in plugins) {
        if ([plugin respondsToSelector:@selector(requestDidStart:)]) {
            [plugin requestDidStart:request];
        }
    }
}

- (void)toggleWillStopWithPlugins:(NSArray *)plugins request:(id<JSNetworkRequestProtocol>)request {
    NSParameterAssert(request);
    for (id<JSNetworkPluginProtocol> plugin in plugins) {
        if ([plugin respondsToSelector:@selector(requestWillStop:)]) {
            [plugin requestWillStop:request];
        }
    }
}

- (void)toggleDidStopWithPlugins:(NSArray *)plugins request:(id<JSNetworkRequestProtocol>)request {
    NSParameterAssert(request);
    for (id<JSNetworkPluginProtocol> plugin in plugins) {
        if ([plugin respondsToSelector:@selector(requestDidStop:)]) {
            [plugin requestDidStop:request];
        }
    }
}

@end
