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
#import <AFNetworking.h>

@interface JSNetworkRequest () {
    NSURLSessionTask *_requestTask;
    JSNetworkInterface *_requestInterface;
}

@property (nonatomic, strong) NSMutableArray<JSNetworkRequestCompletedFilter> *completedBlcoks;
@property (nonatomic, copy) JSNetworkProgressBlock downloadProgress;
@property (nonatomic, copy) JSNetworkProgressBlock uploadProgress;

@end

@implementation JSNetworkRequest

- (instancetype)init {
    if (self = [super init]) {
        _completedBlcoks = [NSMutableArray array];
    }
    return self;
}

- (void)buildTaskWithInterface:(id<JSNetworkInterfaceProtocol>)interface taskCompleted:(void(^)(NSURLSessionDataTask *task, id _Nullable responseObject, NSError *_Nullable error))taskCompleted {
    NSParameterAssert(interface);
    NSParameterAssert(taskCompleted);
    _requestInterface = interface;
    /// 采用一个Manger的方式，否则可能会出现内存泄漏
    static AFHTTPSessionManager *manger = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manger = [AFHTTPSessionManager manager];
    });
    BOOL useFormData = false;
    AFHTTPRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    if ([interface.originalConfig respondsToSelector:@selector(requestSerializerType)]) {
        switch (interface.originalConfig.requestSerializerType) {
            case JSRequestSerializerTypeFormData:
                useFormData = true;
                requestSerializer = [AFHTTPRequestSerializer serializer];
                break;
            default:
                break;
        }
    }
    AFHTTPResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializer];
    if ([interface.originalConfig respondsToSelector:@selector(responseSerializerType)]) {
        switch (interface.originalConfig.responseSerializerType) {
            case JSResponseSerializerTypeHTTP:
                responseSerializer = [AFHTTPResponseSerializer serializer];
                break;
            case JSResponseSerializerTypeXMLParser:
                responseSerializer = [AFXMLParserResponseSerializer serializer];
                break;
            default:
                break;
        }
    }
    for (NSString *headerField in interface.HTTPHeaderFields.keyEnumerator) {
        [requestSerializer setValue:interface.HTTPHeaderFields[headerField] forHTTPHeaderField:headerField];
    }
    requestSerializer.timeoutInterval = interface.timeoutInterval;
    manger.requestSerializer = requestSerializer;
    manger.responseSerializer = responseSerializer;
    manger.completionQueue = interface.processingQueue;
    if (useFormData) {
        _requestTask = [manger POST:interface.finalURL
                         parameters:interface.finalHTTPBody
                            headers:nil
          constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            
        } progress:^(NSProgress * _Nonnull uploadProgress) {
            if (self.uploadProgress) {
                self.uploadProgress(uploadProgress);
            }
        } success:^(NSURLSessionDataTask *task, id responseObject) {
            taskCompleted(task, responseObject, nil);
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            taskCompleted(task, nil, error);
        }];
    } else {
        _requestTask = [manger
                        dataTaskWithHTTPMethod:interface.HTTPMethod
                        URLString:interface.finalURL
                        parameters:interface.finalHTTPBody
                        headers:nil
                        uploadProgress:^(NSProgress *uploadProgress) {
            if (self.uploadProgress) {
                self.uploadProgress(uploadProgress);
            }
        } downloadProgress:^(NSProgress *downloadProgress) {
            if (self.downloadProgress) {
                self.downloadProgress(downloadProgress);
            }
        } success:^(NSURLSessionDataTask *task, id responseObject) {
            taskCompleted(task, responseObject, nil);
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            taskCompleted(task, nil, error);
        }];
    }
}

- (void)requestUploadProgress:(nullable JSNetworkProgressBlock)uploadProgress {
    if (uploadProgress) {
        self.uploadProgress = uploadProgress;
    }
}

- (void)requestDownloadProgress:(nullable JSNetworkProgressBlock)downloadProgress {
    if (downloadProgress) {
        self.downloadProgress = downloadProgress;
    }
}

- (void)requestCompletedFilter:(nullable JSNetworkRequestCompletedFilter)completionBlock {
    if (completionBlock) {
        [_completedBlcoks addObject:completionBlock];
    }
}

- (NSArray<JSNetworkRequestCompletedFilter> *)completedFilters {
    return _completedBlcoks.copy;
}

- (void)clearAllCallBack {
    [_completedBlcoks removeAllObjects];
    self.uploadProgress = nil;
    self.downloadProgress = nil;
}

- (id<JSNetworkInterfaceProtocol>)requestInterface {
    return _requestInterface;
}

- (id<JSNetworkResponseProtocol>)response {
    return self.requestInterface.response;
}

- (NSURLSessionTask *)requestTask {
    return _requestTask;
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

#pragma mark - description

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p> { URL: %@ } { method: %@ } { arguments: %@ } { body: %@ } { response: %@ }", NSStringFromClass([self class]), self, self.requestTask.currentRequest.URL, self.requestTask.currentRequest.HTTPMethod, self.requestInterface.finalArguments, self.requestInterface.finalHTTPBody, self.response];
}

- (void)dealloc {
    NSLog(@"JSNetworkRequest - 已经释放");
}

@end
