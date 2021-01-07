//
//  JSNetworkAFRequest.m
//  JSNetwork
//
//  Created by jiasong on 2021/1/6.
//

#import "JSNetworkAFRequest.h"
#import "JSNetworkInterface.h"
#import "JSNetworkRequestProtocol.h"
#import "JSNetworkRequestConfigProtocol.h"
#import "JSNetworkConfig.h"
#import "AFNetworking.h"

@interface JSNetworkAFRequest () {
    NSURLSessionTask *_requestTask;
}

@end

@implementation JSNetworkAFRequest

- (void)buildTaskWithRequestConfig:(id<JSNetworkRequestConfigProtocol>)config
            constructingURLRequest:(void(^)(NSMutableURLRequest *urlRequest))constructingURLRequest
         constructingFormDataBlock:(void(^)(id formData))constructingFormDataBlock
                    uploadProgress:(void(^)(NSProgress *uploadProgress))uploadProgressBlock
                  downloadProgress:(void(^)(NSProgress *downloadProgress))downloadProgressBlock
                     taskCompleted:(void(^)(id _Nullable responseObject, NSError *_Nullable error))taskCompleted {
    [super buildTaskWithRequestConfig:config
               constructingURLRequest:constructingURLRequest
            constructingFormDataBlock:constructingFormDataBlock
                       uploadProgress:uploadProgressBlock
                     downloadProgress:downloadProgressBlock
                        taskCompleted:taskCompleted];
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
    NSString *method = @"";
    switch (config.requestMethod) {
        case JSRequestMethodGET:
            method = @"GET";
            break;
        case JSRequestMethodPOST:
            method = @"POST";
            break;
        case JSRequestMethodHEAD:
            method = @"HEAD";
            break;
        case JSRequestMethodPUT:
            method = @"PUT";
            break;
        case JSRequestMethodDELETE:
            method = @"DELETE";
            break;
        case JSRequestMethodPATCH:
            method = @"PATCH";
            break;
        default:
            break;
    }
    id requestBody = config.requestBody;
    NSError *serializationError = nil;
    NSMutableURLRequest *request = nil;
    __weak __typeof(manager) weakManager = manager;
    void (^completed)(id, NSError *) = ^(id responseObject, NSError *error) {
        taskCompleted(responseObject, error);
        [weakManager invalidateSessionCancelingTasks:false resetSession:false];
    };
    if (useFormData) {
        request = [manager.requestSerializer multipartFormRequestWithMethod:method
                                                                  URLString:[[NSURL URLWithString:config.requestUrl relativeToURL:manager.baseURL] absoluteString]
                                                                 parameters:requestBody
                                                  constructingBodyWithBlock:constructingFormDataBlock
                                                                      error:&serializationError];
    } else {
        request = [manager.requestSerializer requestWithMethod:method
                                                     URLString:[[NSURL URLWithString:config.requestUrl relativeToURL:manager.baseURL] absoluteString]
                                                    parameters:requestBody
                                                         error:&serializationError];
    }
    if (serializationError) {
        completed(nil, serializationError);
    } else {
        constructingURLRequest(request);
        if (useFormData) {
            _requestTask = [manager uploadTaskWithStreamedRequest:request
                                                         progress:uploadProgressBlock
                                                completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
                completed(responseObject, error);
            }];
        } else {
            _requestTask = [manager dataTaskWithRequest:request
                                         uploadProgress:uploadProgressBlock
                                       downloadProgress:downloadProgressBlock
                                      completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
                completed(responseObject, error);
            }];
        }
    }
}

- (NSURLSessionTask *)requestTask {
    return _requestTask;
}

@end
