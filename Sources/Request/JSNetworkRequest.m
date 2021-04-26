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
#import "JSNetworkSpinLock.h"

@interface JSNetworkRequest ()

@property (nonatomic, weak) id<JSNetworkInterfaceProtocol> privateInterfaceProxy;
@property (nonatomic, strong) NSString *taskIdentifier;

@end

@implementation JSNetworkRequest

#pragma mark - JSNetworkRequestProtocol

- (void)buildTaskWithConfig:(id<JSNetworkRequestConfigProtocol>)config
          multipartFormData:(void(^)(id formData))multipartFormDataBlock
             uploadProgress:(void(^)(NSProgress *uploadProgress))uploadProgressBlock
           downloadProgress:(void(^)(NSProgress *downloadProgress))downloadProgressBlock
        didCreateURLRequest:(void(^)(__kindof NSURLRequest *urlRequest))didCreateURLRequestBlock
              didCreateTask:(void(^)(__kindof NSURLSessionTask *task))didCreateTaskBlock
               didCompleted:(void(^)(id _Nullable responseObject, NSError *_Nullable error))didCompletedBlock {
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

- (NSString *)description {
    return [NSString stringWithFormat:@"%@: <%p>", NSStringFromClass(self.class), self];
}

- (void)dealloc {
    JSNetworkLog(@"%@ - 已经释放", NSStringFromClass([self class]));
}

@end
