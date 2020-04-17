//
//  JSNetworkAgent.m
//  JSNetwork
//
//  Created by jiasong on 2020/4/17.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import "JSNetworkAgent.h"

@interface JSNetworkAgent ()

@property (nonatomic, strong) NSMutableDictionary<NSNumber *, id<JSRequestProtocol>> *requestsRecord;
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

- (void)addRequest:(id<JSRequestProtocol>)request {
    [request.requestTask resume];
    [self addRequestToRecord:request];
}

- (void)cancelRequest:(id<JSRequestProtocol>)request {
    [request.requestTask cancel];
    [self removeRequestFromRecord:request];
}

- (void)cancelAllRequests {
    
}

- (void)addRequestToRecord:(id<JSRequestProtocol>)request {
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    _requestsRecord[@(request.requestTask.taskIdentifier)] = request;
    dispatch_semaphore_signal(_lock);
}

- (void)removeRequestFromRecord:(id<JSRequestProtocol>)request {
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    [_requestsRecord removeObjectForKey:@(request.requestTask.taskIdentifier)];
    dispatch_semaphore_signal(_lock);
}


@end
