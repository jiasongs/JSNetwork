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
#import "JSNetworkConfig.h"

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

- (void)addRequest:(id<JSNetworkRequestProtocol>)request {
    NSParameterAssert(request);
    [self addRequestToRecord:request];
    NSMutableArray *plugins = [NSMutableArray arrayWithArray:JSNetworkConfig.sharedInstance.plugins];
    if ([request.requestInterface.config respondsToSelector:@selector(requestPlugins)]) {
        [plugins addObjectsFromArray:request.requestInterface.config.requestPlugins];
    }
    [self toggleWillStartWithPlugins:plugins request:request];
    __weak typeof(self) weakSelf = self;
    [request requestCompletePreprocessor:^(id<JSNetworkRequestProtocol> aRequest, id responseObject, NSError *error) {
        __strong typeof(weakSelf) self = weakSelf;
        [self toggleWillStopWithPlugins:plugins request:aRequest];
        [aRequest.response handleRequestResult:aRequest.requestTask responseObject:responseObject error:error];
    }];
    [request requestCompletedFilter:^(id<JSNetworkRequestProtocol> aRequest) {
        __strong typeof(weakSelf) self = weakSelf;
        [self toggleDidStopWithPlugins:plugins request:aRequest];
    }];
    [request start];
    [self toggleDidStartWithPlugins:plugins request:request];
}

- (void)removeRequest:(id<JSNetworkRequestProtocol>)request {
    if (request.isExecuting) {
        [request cancel];
    }
    [self removeRequestFromRecord:request];
}

- (void)cancelAllRequests {
    [_requestsRecord removeAllObjects];
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

- (void)toggleWillStartWithPlugins:(NSArray *)plugins request:(id<JSNetworkRequestProtocol>)request {
    for (id<JSNetworkPluginProtocol> plugin in plugins) {
        if ([plugin respondsToSelector:@selector(requestWillStart:)]) {
            [plugin requestWillStart:request];
        }
    }
}

- (void)toggleDidStartWithPlugins:(NSArray *)plugins request:(id<JSNetworkRequestProtocol>)request {
    for (id<JSNetworkPluginProtocol> plugin in plugins) {
        if ([plugin respondsToSelector:@selector(requestDidStart:)]) {
            [plugin requestDidStart:request];
        }
    }
}

- (void)toggleWillStopWithPlugins:(NSArray *)plugins request:(id<JSNetworkRequestProtocol>)request {
    for (id<JSNetworkPluginProtocol> plugin in plugins) {
        if ([plugin respondsToSelector:@selector(requestWillStop:)]) {
            [plugin requestWillStop:request];
        }
    }
}

- (void)toggleDidStopWithPlugins:(NSArray *)plugins request:(id<JSNetworkRequestProtocol>)request {
    for (id<JSNetworkPluginProtocol> plugin in plugins) {
        if ([plugin respondsToSelector:@selector(requestDidStop:)]) {
            [plugin requestDidStop:request];
        }
    }
}

@end
