//
//  JSNetworkRequest.m
//  JSNetwork
//
//  Created by jiasong on 2020/4/17.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import "JSNetworkRequest.h"
#import "JSNetworkInterfaceProtocol.h"
#import "JSNetworkRequestProtocol.h"
#import "JSNetworkRequestConfigProtocol.h"
#import "JSNetworkUtil.h"

@interface JSNetworkRequest ()

@property (nonatomic, weak) id<JSNetworkInterfaceProtocol> privateInterfaceProxy;
@property (nonatomic, strong) NSString *taskIdentifier;

@end

@implementation JSNetworkRequest

#pragma mark - JSNetworkRequestProtocol

static NSUInteger JSNetworkRequestTaskIdentifier = 0;
- (void)buildTaskWithRequestConfig:(id<JSNetworkRequestConfigProtocol>)config
                     taskCompleted:(void(^)(id responseObject, NSError *error))taskCompleted {
    NSParameterAssert(config);
    NSParameterAssert(taskCompleted);
    @synchronized (self) {
        JSNetworkRequestTaskIdentifier = JSNetworkRequestTaskIdentifier + 1;
        _taskIdentifier = [@"request_task" stringByAppendingFormat:@"%@", @(JSNetworkRequestTaskIdentifier)];
    }
}

- (void)addInterfaceProxy:(id<JSNetworkInterfaceProtocol>)interfaceProxy {
    _privateInterfaceProxy = interfaceProxy;
}

- (id<JSNetworkInterfaceProtocol>)interfaceProxy {
    return _privateInterfaceProxy;
}

- (NSURLSessionTask *)requestTask {
    return nil;
}

- (NSString *)taskIdentifier {
    @synchronized (self) {
        return _taskIdentifier;
    }
}

#pragma mark - NSOperation, 以下必须实现

- (void)start {
    NSParameterAssert(self.requestTask);
    [self.requestTask resume];
}

- (void)cancel {
    NSParameterAssert(self.requestTask);
    [self.requestTask cancel];
}

- (BOOL)isCancelled {
    if (!self.requestTask) return NO;
    return self.requestTask.state == NSURLSessionTaskStateCanceling;
}

- (BOOL)isExecuting {
    if (!self.requestTask) return NO;
    return self.requestTask.state == NSURLSessionTaskStateRunning;
}

- (BOOL)isFinished {
    if (!self.requestTask) return YES;
    return self.requestTask.state == NSURLSessionTaskStateCompleted || self.requestTask.state == NSURLSessionTaskStateCanceling;
}

- (BOOL)isAsynchronous {
    return YES;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@: <%p>", NSStringFromClass(self.class), self];
}

- (void)dealloc {
    JSNetworkLog(@"%@ - 已经释放", NSStringFromClass([self class]));
}

@end
