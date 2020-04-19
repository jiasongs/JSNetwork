//
//  JSNetworkRequest.m
//  JSNetwork
//
//  Created by jiasong on 2020/4/17.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import "JSNetworkRequest.h"
#import <AFNetworking.h>
#import "JSNetworkResponse.h"
#import "JSNetworkRequestConfigProtocol.h"
#import "JSNetworkInterface.h"
#import "JSNetworkRequestProtocol.h"

@interface JSNetworkRequest () {
    NSURLSessionTask *_requestTask;
    JSNetworkInterface *_requestInterface;
}

@property (nonatomic, strong) NSMutableArray<JSNetworkRequestCompletePreprocessor> *completePreprocessorBlocks;
@property (nonatomic, strong) NSMutableArray<JSNetworkRequestCompletedFilter> *completedBlcoks;
@property (nonatomic, copy) JSNetworkProgressBlock downloadProgress;
@property (nonatomic, copy) JSNetworkProgressBlock uploadProgress;

@end

@implementation JSNetworkRequest

@synthesize response = _response;

- (instancetype)init {
    if (self = [super init]) {
        _response = JSNetworkResponse.new;
        _completePreprocessorBlocks = [NSMutableArray array];
        _completedBlcoks = [NSMutableArray array];
    }
    return self;
}

- (void)buildTaskWithInterface:(JSNetworkInterface *)interface taskCompleted:(void(^)(id<JSNetworkRequestProtocol> aRequest))taskCompleted {
    _requestInterface = interface;
    void(^executeCompleted)(id _Nullable responseObject, NSError *_Nullable error) = ^(id responseObject, NSError *error) {
        for (JSNetworkRequestCompletePreprocessor completePreprocessor in self->_completePreprocessorBlocks) {
            completePreprocessor(self, responseObject, error);
        }
        for (JSNetworkRequestCompletedFilter completedFilter in self->_completedBlcoks) {
            completedFilter(self);
        }
        [self->_completePreprocessorBlocks removeAllObjects];
        [self->_completedBlcoks removeAllObjects];
        /// 任务完成时调用
        taskCompleted(self);
    };
    AFHTTPSessionManager *manger = [AFHTTPSessionManager manager];
    /// 
    _requestTask = [manger
                    dataTaskWithHTTPMethod:interface.HTTPMethod
                    URLString:interface.finalURL
                    parameters:interface.finalBody
                    headers:interface.HTTPHeaderFields
                    uploadProgress:^(NSProgress *uploadProgress) {
        if (self.uploadProgress) {
            self.uploadProgress(uploadProgress);
        }
    } downloadProgress:^(NSProgress *downloadProgress) {
        if (self.downloadProgress) {
            self.downloadProgress(downloadProgress);
        }
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        executeCompleted(responseObject, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        executeCompleted(nil, error);
    }];
}

- (void)start {
    NSParameterAssert(self.requestTask);
    [self.requestTask resume];
}

- (void)cancel {
    NSParameterAssert(self.requestTask);
    [self.requestTask cancel];
}

- (void)requestUploadProgress:(JSNetworkProgressBlock)uploadProgress {
    self.uploadProgress = uploadProgress;
}

- (void)requestDownloadProgress:(JSNetworkProgressBlock)downloadProgress {
    self.downloadProgress = downloadProgress;
}

/// 请求完成之前，还未构造Response
- (void)requestCompletePreprocessor:(JSNetworkRequestCompletePreprocessor)completionBlock {
    [_completePreprocessorBlocks addObject:completionBlock];
}

/// 构造Response完成
- (void)requestCompletedFilter:(JSNetworkRequestCompletedFilter)completionBlock {
    [_completedBlcoks addObject:completionBlock];
}

- (NSString *)taskIdentifier {
    return @(self.requestTask.taskIdentifier).stringValue;
}

- (id<JSNetworkResponseProtocol>)response {
    if (!_response) {
        _response = JSNetworkResponse.new;
    }
    return _response;
}

- (JSNetworkInterface *)requestInterface {
    return _requestInterface;
}

#pragma mark -

- (NSURLSessionTask *)requestTask {
    return _requestTask;
}

- (NSURLRequest *)currentURLRequest {
    return self.requestTask.currentRequest;
}

- (NSURLRequest *)originalURLRequest {
    return self.requestTask.originalRequest;
}

- (BOOL)isCancelled {
    if (!self.requestTask) {
        return NO;
    }
    return self.requestTask.state == NSURLSessionTaskStateCanceling;
}

- (BOOL)isExecuting {
    if (!self.requestTask) {
        return NO;
    }
    return self.requestTask.state == NSURLSessionTaskStateRunning;
}

- (void)dealloc {
    NSLog(@"JSNetworkRequest - 已经释放");
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p> { URL: %@ } { method: %@ } { arguments: %@ } { body: %@ } { response: %@ }", NSStringFromClass([self class]), self, self.currentURLRequest.URL, self.currentURLRequest.HTTPMethod, self.requestInterface.finalArguments, self.requestInterface.finalBody, self.response];
}

@end
