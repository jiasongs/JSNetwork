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

@interface JSNetworkAgent ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, id<JSNetworkRequestProtocol>> *requestsRecord;
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
    }
    return self;;
}

- (nullable id<JSNetworkRequestProtocol>)getRequestWithTask:(NSURLSessionTask *)task {
    NSParameterAssert(task);
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    id<JSNetworkRequestProtocol> request = [_requestsRecord objectForKey:@(task.taskIdentifier).stringValue];
    dispatch_semaphore_signal(_lock);
    return request;
}

- (void)addRequest:(id<JSNetworkRequestProtocol>)request {
    NSParameterAssert(request);
    [self addRequestToRecord:request];
    [request start];
}

- (void)removeRequest:(id<JSNetworkRequestProtocol>)request {
    NSParameterAssert(request);
    if ([request isExecuting]) {
        [request cancel];
    }
    [request clearAllCallBack];
    [self removeRequestFromRecord:request];
}

- (void)handleRequest:(id<JSNetworkRequestProtocol>)request {
    NSParameterAssert(request);
//    dispatch_async(request.requestInterface.processingQueue, ^{
//        
//    });
    NSArray *plugins = request.requestInterface.allPlugins;
    [self toggleWillStartWithPlugins:plugins request:request];
    [self addRequest:request];
    [self toggleDidStartWithPlugins:plugins request:request];
}

- (void)handleResponseWithTask:(NSURLSessionTask *)task
                responseObject:(nullable id)responseObject
                         error:(nullable NSError *)error {
    NSParameterAssert(task);
    id<JSNetworkRequestProtocol> request = [self getRequestWithTask:task];
    NSParameterAssert(request);
    if (!request) return;
//    dispatch_async(request.requestInterface.processingQueue, ^{
//
//    });
    /// 处理响应
    [request.response handleRequestResult:request.requestTask responseObject:responseObject error:error];
    NSArray *plugins = request.requestInterface.allPlugins;
    [self toggleWillStopWithPlugins:plugins request:request];
    @autoreleasepool {
        for (JSNetworkRequestCompletedFilter block in request.completedFilters) {
            block(request);
        }
    }
    [self toggleDidStopWithPlugins:plugins request:request];
    [self removeRequest:request];
//    dispatch_async(request.requestInterface.completionQueue, ^{
//
//    });
}

- (void)addRequestToRecord:(id<JSNetworkRequestProtocol>)request {
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    [_requestsRecord setValue:request forKey:request.taskIdentifier];
    dispatch_semaphore_signal(_lock);
}

- (void)removeRequestFromRecord:(id<JSNetworkRequestProtocol>)request {
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    [_requestsRecord removeObjectForKey:request.taskIdentifier];
    dispatch_semaphore_signal(_lock);
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
