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

- (void)buildTaskWithInterface:(id<JSNetworkInterfaceProtocol>)interface taskCompleted:(void (^)(id _Nullable, NSError * _Nullable))taskCompleted {
    [super buildTaskWithInterface:interface taskCompleted:taskCompleted];
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
    manger.completionQueue = JSNetworkConfig.sharedConfig.processingQueue;
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
            taskCompleted(responseObject, nil);
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            taskCompleted(nil, error);
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
