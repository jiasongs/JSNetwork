//
//  JSNetworkRequest.m
//  JSNetwork
//
//  Created by jiasong on 2020/4/17.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import "JSNetworkRequest.h"
#import "JSNetworkInterface.h"
#import "JSNetworkRequestProtocol.h"
#import "JSNetworkRequestConfigProtocol.h"

@interface JSNetworkRequest ()

@property (nonatomic, strong) NSMutableArray<JSNetworkRequestCompletedFilter> *completedBlcoks;
@property (nonatomic, copy) JSNetworkProgressBlock uploadProgressBlock;
@property (nonatomic, copy) JSNetworkProgressBlock downloadProgressBlock;

@end

@implementation JSNetworkRequest

- (instancetype)init {
    if (self = [super init]) {
        _completedBlcoks = [NSMutableArray array];
    }
    return self;
}

- (void)buildTaskWithRequestConfig:(id<JSNetworkRequestConfigProtocol>)config taskCompleted:(void(^)(id _Nullable responseObject, NSError *_Nullable error))taskCompleted {
    NSParameterAssert(config);
    NSParameterAssert(taskCompleted);
}

- (void)requestUploadProgress:(nullable JSNetworkProgressBlock)uploadProgress {
    if (uploadProgress) {
        self.uploadProgressBlock = uploadProgress;
    }
}

- (void)requestDownloadProgress:(nullable JSNetworkProgressBlock)downloadProgress {
    if (downloadProgress) {
        self.downloadProgressBlock = downloadProgress;
    }
}

- (void)requestCompletedFilter:(nullable JSNetworkRequestCompletedFilter)completionBlock {
    if (completionBlock) {
        [_completedBlcoks addObject:completionBlock];
    }
}

- (nullable JSNetworkProgressBlock)uploadProgress {
    return self.uploadProgressBlock;
}

- (nullable JSNetworkProgressBlock)downloadProgress {
    return self.downloadProgressBlock;
}

- (NSArray<JSNetworkRequestCompletedFilter> *)completedFilters {
    return _completedBlcoks.copy;
}

- (void)clearAllCallBack {
    [_completedBlcoks removeAllObjects];
    self.uploadProgressBlock = nil;
    self.downloadProgressBlock = nil;
}

- (NSURLSessionTask *)requestTask {
    return nil;
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
    if (!self.requestTask) return false;
    return self.requestTask.state == NSURLSessionTaskStateCanceling;
}

- (BOOL)isExecuting {
    if (!self.requestTask) return false;
    return self.requestTask.state == NSURLSessionTaskStateRunning;
}

- (BOOL)isFinished {
    if (!self.requestTask) return true;
    return self.requestTask.state == NSURLSessionTaskStateCompleted || self.requestTask.state == NSURLSessionTaskStateCanceling;
}

- (BOOL)isAsynchronous {
    return true;
}

//- (NSString *)description {
//    return [NSString stringWithFormat:@"{ }"];
//}

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"JSNetworkRequest - 已经释放");
#endif
}

@end
