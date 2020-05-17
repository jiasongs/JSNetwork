//
//  NetworkRequest.m
//  JSNetworkExample
//
//  Created by jiasong on 2020/4/21.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import "NetworkRequest.h"
#import "JSNetworkInterface.h"
#import "JSNetworkRequestProtocol.h"
#import "JSNetworkRequestConfigProtocol.h"
#import <JSNetworkConfig.h>
#import <AFNetworking.h>

@interface NetworkRequest () {
    NSURLSessionTask *_requestTask;
}

@end

@implementation NetworkRequest

- (void)buildTaskWithRequestConfig:(id<JSNetworkRequestConfigProtocol>)config taskCompleted:(void (^)(id _Nullable, NSError * _Nullable))taskCompleted {
    [super buildTaskWithRequestConfig:config taskCompleted:taskCompleted];
    /// 采用一个Manger的方式，否则可能会出现内存泄漏
    static AFHTTPSessionManager *manger = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manger = [AFHTTPSessionManager manager];
    });
    BOOL useFormData = false;
    AFHTTPRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    switch (config.requestSerializerType) {
        case JSRequestSerializerTypeFormData:
            useFormData = true;
            requestSerializer = [AFHTTPRequestSerializer serializer];
            break;
        default:
            break;
    }
    AFHTTPResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializer];
    switch (config.responseSerializerType) {
        case JSResponseSerializerTypeHTTP:
            responseSerializer = [AFHTTPResponseSerializer serializer];
            break;
        case JSResponseSerializerTypeXMLParser:
            responseSerializer = [AFXMLParserResponseSerializer serializer];
            break;
        default:
            break;
    }
    NSDictionary *headers = config.requestHeaderFieldValueDictionary;
    for (NSString *headerField in headers.keyEnumerator) {
        [requestSerializer setValue:headers[headerField] forHTTPHeaderField:headerField];
    }
    requestSerializer.timeoutInterval = config.requestTimeoutInterval;
    manger.completionQueue = JSNetworkConfig.sharedConfig.processingQueue;
    manger.requestSerializer = requestSerializer;
    manger.responseSerializer = responseSerializer;
    manger.responseSerializer.acceptableStatusCodes = config.acceptableStatusCodes;
    if (config.acceptableContentTypes) {
        NSMutableSet *contentTypes = [NSMutableSet setWithSet:manger.responseSerializer.acceptableContentTypes];
        [contentTypes unionSet:config.acceptableContentTypes];
        manger.responseSerializer.acceptableContentTypes = contentTypes.copy;
    }
    if (useFormData) {
        _requestTask = [manger POST:config.requestUrl
                         parameters:config.requestBody
                            headers:nil
          constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            if ([config respondsToSelector:@selector(constructingMultipartFormData:)]) {
                [config constructingMultipartFormData:formData];
            }
        } progress:^(NSProgress * _Nonnull uploadProgress) {
            if (self.uploadProgress) {
                self.uploadProgress(uploadProgress);
            }
        } success:^(NSURLSessionDataTask *task, id responseObject) {
            taskCompleted(responseObject, nil);
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            taskCompleted(nil, error);
        }];
    } else {
        NSString *HTTPMethod = config.requestMethod == JSRequestMethodGET ? @"GET" : @"POST";
        _requestTask = [manger dataTaskWithHTTPMethod:HTTPMethod
                                            URLString:config.requestUrl
                                           parameters:config.requestBody
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
            taskCompleted(responseObject, nil);
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            taskCompleted(nil, error);
        }];
    }
}

- (NSURLSessionTask *)requestTask {
    return _requestTask;
}

@end
