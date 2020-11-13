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
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    BOOL useFormData = false;
    AFHTTPRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    switch (config.requestSerializerType) {
        case JSRequestSerializerTypeHTTP:
        case JSRequestSerializerTypeBinaryData:
            requestSerializer = [AFHTTPRequestSerializer serializer];
            break;
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
    manager.completionQueue = JSNetworkConfig.sharedConfig.processingQueue;
    manager.requestSerializer = requestSerializer;
    manager.responseSerializer = responseSerializer;
    manager.responseSerializer.acceptableStatusCodes = config.responseAcceptableStatusCodes;
    if (config.responseAcceptableContentTypes) {
        NSMutableSet *contentTypes = [NSMutableSet setWithSet:manager.responseSerializer.acceptableContentTypes];
        [contentTypes unionSet:config.responseAcceptableContentTypes];
        manager.responseSerializer.acceptableContentTypes = contentTypes.copy;
    }
    __weak __typeof(manager) weakManager = manager;
    void (^completed)(id, NSError *) = ^(id responseObject, NSError *error) {
        taskCompleted(responseObject, error);
        [weakManager invalidateSessionCancelingTasks:false resetSession:false];
    };
    if (useFormData) {
        _requestTask = [manager
                        POST:config.requestUrl
                        parameters:config.requestBody
                        headers:nil
                        constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
            if ([config respondsToSelector:@selector(constructingMultipartFormData:)]) {
                [config constructingMultipartFormData:formData];
            }
        } progress:^(NSProgress * _Nonnull uploadProgress) {
            if (self.interfaceProxy.uploadProgress) {
                self.interfaceProxy.uploadProgress(uploadProgress);
            }
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            completed(responseObject, nil);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            completed(nil, error);
        }];
    } else {
        NSString *method = @"";
        switch (config.requestMethod) {
            case JSRequestMethodGET:
                method = @"GET";
                break;
            case JSRequestMethodPOST:
                method = @"POST";
                break;
            default:
                break;
        }
        id requestBody = config.requestBody;
        BOOL isBinaryBody = config.requestSerializerType == JSRequestSerializerTypeBinaryData && [requestBody isKindOfClass:NSData.class];
        NSError *serializationError = nil;
        NSMutableURLRequest *request = [manager.requestSerializer requestWithMethod:method
                                                                          URLString:[[NSURL URLWithString:config.requestUrl relativeToURL:manager.baseURL] absoluteString]
                                                                         parameters:isBinaryBody ? nil : requestBody
                                                                              error:&serializationError];
        if (serializationError) {
            completed(nil, serializationError);
        } else {
            if (isBinaryBody) {
                [request setHTTPBody:requestBody];
            }
            _requestTask = [manager dataTaskWithRequest:request
                                         uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
                if (self.interfaceProxy.uploadProgress) {
                    self.interfaceProxy.uploadProgress(uploadProgress);
                }
            } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
                if (self.interfaceProxy.downloadProgress) {
                    self.interfaceProxy.downloadProgress(downloadProgress);
                }
            } completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
                completed(responseObject, error);
            }];
            [_requestTask resume];
        }
    }
}

- (NSURLSessionTask *)requestTask {
    return _requestTask;
}

@end
