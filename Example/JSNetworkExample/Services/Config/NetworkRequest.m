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

@property (nonatomic, copy) id taskCompleted;
@property (nonatomic, strong) id config;

@end

@implementation NetworkRequest

- (void)buildTaskWithRequestConfig:(id<JSNetworkRequestConfigProtocol>)config taskCompleted:(void (^)(id _Nullable, NSError * _Nullable))taskCompleted {
    [super buildTaskWithRequestConfig:config taskCompleted:taskCompleted];
    _taskCompleted = taskCompleted;
    _config = config;
    AFHTTPSessionManager *manger = [AFHTTPSessionManager manager];
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
    manger.responseSerializer.acceptableStatusCodes = config.responseAcceptableStatusCodes;
    if (config.responseAcceptableContentTypes) {
        NSMutableSet *contentTypes = [NSMutableSet setWithSet:manger.responseSerializer.acceptableContentTypes];
        [contentTypes unionSet:config.responseAcceptableContentTypes];
        manger.responseSerializer.acceptableContentTypes = contentTypes.copy;
    }
    __weak __typeof(manger) weakManger = manger;
    void (^completed)(id, NSError *) = ^(id responseObject, NSError *error) {
        taskCompleted(responseObject, error);
        [weakManger invalidateSessionCancelingTasks:false resetSession:false];
    };
    if (useFormData) {
        _requestTask = [manger POST:config.requestUrl
                         parameters:config.requestBody
                            headers:nil
          constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            if ([config respondsToSelector:@selector(constructingMultipartFormData:)]) {
                [config constructingMultipartFormData:formData];
            }
        } progress:^(NSProgress * _Nonnull uploadProgress) {
            if (self.interfaceProxy.uploadProgress) {
                self.interfaceProxy.uploadProgress(uploadProgress);
            }
        } success:^(NSURLSessionDataTask *task, id responseObject) {
            completed(responseObject, nil);
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            completed(nil, error);
        }];
    } else {
        NSString *HTTPMethod = config.requestMethod == JSRequestMethodGET ? @"GET" : @"POST";
        _requestTask = [manger dataTaskWithHTTPMethod:HTTPMethod
                                            URLString:config.requestUrl
                                           parameters:config.requestBody
                                              headers:nil
                                       uploadProgress:^(NSProgress *uploadProgress) {
            if (self.interfaceProxy.uploadProgress) {
                self.interfaceProxy.uploadProgress(uploadProgress);
            }
        } downloadProgress:^(NSProgress *downloadProgress) {
            if (self.interfaceProxy.downloadProgress) {
                self.interfaceProxy.downloadProgress(downloadProgress);
            }
        } success:^(NSURLSessionDataTask *task, id responseObject) {
            completed(responseObject, nil);
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            completed(nil, error);
        }];
    }
}

- (NSURLSessionTask *)requestTask {
    return _requestTask;
}

@end
