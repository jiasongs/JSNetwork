//
//  JSNetworkAgent.m
//  JSNetwork
//
//  Created by jiasong on 2020/4/17.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import "JSNetworkAgent.h"

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
    NSArray<id<JSNetworkPluginProtocol>> *plugins = [request.requestConfig requestPlugins];
    for (id<JSNetworkPluginProtocol> plugin in plugins) {
        [plugin requestWillStart:request.requestConfig];
    }
    [request start];
    for (id<JSNetworkPluginProtocol> plugin in plugins) {
        [plugin requestDidStart:request.requestConfig];
    }
    [request requestCompleteFilter:^{
        for (id<JSNetworkPluginProtocol> plugin in plugins) {
            [plugin requestWillStop:request.requestConfig];
        }
        /// 移除
        for (id<JSNetworkPluginProtocol> plugin in plugins) {
            [plugin requestDidStop:request.requestConfig];
        }
    }];
    [request requestFailedFilter:^{
        for (id<JSNetworkPluginProtocol> plugin in plugins) {
            [plugin requestWillStop:request.requestConfig];
        }
        /// 移除
        for (id<JSNetworkPluginProtocol> plugin in plugins) {
            [plugin requestDidStop:request.requestConfig];
        }
    }];
    [self addRequestToRecord:request];
}

- (void)removeRequest:(id<JSNetworkRequestProtocol>)request {
    [request cancel];
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

@end

@implementation JSNetworkAgent (RequestPlugin)

- (void)toggleWillStartWithPlugins:(id<JSNetworkRequestProtocol>)request {
    
}

- (void)toggleDidStartWithPlugins:(NSArray<id<JSNetworkPluginProtocol>> *)plugins {
    
}

- (void)toggleWillStopWithPlugins:(NSArray<id<JSNetworkPluginProtocol>> *)plugins {
   
}

- (void)toggleDidStopWithPlugins:(NSArray<id<JSNetworkPluginProtocol>> *)plugins {
    
}

@end
