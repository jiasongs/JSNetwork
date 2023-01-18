//
//  JSNetworkRequest.m
//  JSNetwork
//
//  Created by jiasong on 2020/4/17.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import "JSNetworkRequest.h"
#import "JSNetworkRequestProtocol.h"
#import "JSNetworkRequestConfigProtocol.h"
#import "JSNetworkUtil.h"

@interface JSNetworkRequest ()

@end

@implementation JSNetworkRequest

#pragma mark - JSNetworkRequestProtocol

- (void)buildTaskWithConfig:(id<JSNetworkRequestConfigProtocol>)config
             uploadProgress:(void(^)(NSProgress *uploadProgress))uploadProgress
           downloadProgress:(void(^)(NSProgress *downloadProgress))downloadProgress
       constructingFormData:(void(^)(id formData))constructingFormData
        didCreateURLRequest:(NSURLRequest *(^)(NSURLRequest *urlRequest))didCreateURLRequest
              didCreateTask:(void(^)(NSURLSessionTask *task))didCreateTask
               didCompleted:(void(^)(id _Nullable responseObject, NSError *_Nullable error))didCompleted {
    NSAssert(NO, @"需子类继承使用, 此方法不作任何事情");
}

- (NSURLSessionTask *)requestTask {
    return nil;
}

#pragma mark - NSOperation, 以下必须实现

- (void)start {
    NSParameterAssert(self.requestTask);
    if (self.requestTask.state == NSURLSessionTaskStateSuspended) {
        [self.requestTask resume];
    } else {
        JSNetworkLog(@"警告: requestTask已经在运行中!");
    }
}

- (void)cancel {
    NSParameterAssert(self.requestTask);
    // Resume to ensure metrics are gathered.
    if (self.requestTask.state == NSURLSessionTaskStateSuspended) {
        [self.requestTask resume];
    }
    if (self.requestTask.state == NSURLSessionTaskStateRunning) {
        [self.requestTask cancel];
    } else {
        JSNetworkLog(@"警告: requestTask未在运行中, 不能取消!");
    }
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

- (void)dealloc {
    JSNetworkLog(@"%@ - 已经释放", NSStringFromClass([self class]));
}

@end
