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

@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;

@end

@implementation JSNetworkAFRequest

- (void)buildTaskWithConfig:(id<JSNetworkRequestConfigProtocol>)config
          multipartFormData:(void(^)(id formData))multipartFormDataBlock
             uploadProgress:(void(^)(NSProgress *uploadProgress))uploadProgressBlock
           downloadProgress:(void(^)(NSProgress *downloadProgress))downloadProgressBlock
        didCreateURLRequest:(void(^)(__kindof NSURLRequest *urlRequest))didCreateURLRequestBlock
              didCreateTask:(void(^)(__kindof NSURLSessionTask *task))didCreateTaskBlock
               didCompleted:(void(^)(id _Nullable responseObject, NSError *_Nullable error))didCompletedBlock {
    self.sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:nil sessionConfiguration:nil];
    BOOL useFormData = NO;
    AFHTTPRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    switch (config.requestSerializerType) {
        case JSRequestSerializerTypeHTTP:
        case JSRequestSerializerTypeBinaryData:
            requestSerializer = [AFHTTPRequestSerializer serializer];
            break;
        case JSRequestSerializerTypeFormData:
            useFormData = YES;
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
    self.sessionManager.completionQueue = JSNetworkConfig.sharedConfig.processingQueue;
    self.sessionManager.requestSerializer = requestSerializer;
    self.sessionManager.responseSerializer = responseSerializer;
    self.sessionManager.responseSerializer.acceptableStatusCodes = config.responseAcceptableStatusCodes;
    if (config.responseAcceptableContentTypes) {
        NSMutableSet *contentTypes = [NSMutableSet setWithSet:self.sessionManager.responseSerializer.acceptableContentTypes];
        [contentTypes unionSet:config.responseAcceptableContentTypes];
        self.sessionManager.responseSerializer.acceptableContentTypes = contentTypes.copy;
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
    NSMutableURLRequest *request = nil;
    if (useFormData) {
        request = [self.sessionManager.requestSerializer multipartFormRequestWithMethod:method
                                                                              URLString:[[NSURL URLWithString:config.requestUrl relativeToURL:self.sessionManager.baseURL] absoluteString]
                                                                             parameters:requestBody
                                                              constructingBodyWithBlock:multipartFormDataBlock
                                                                                  error:nil];
    } else {
        request = [self.sessionManager.requestSerializer requestWithMethod:method
                                                                 URLString:[[NSURL URLWithString:config.requestUrl relativeToURL:self.sessionManager.baseURL] absoluteString]
                                                                parameters:requestBody
                                                                     error:nil];
    }
    /// 创建完成时需要调用
    didCreateURLRequestBlock(request);
    __weak typeof(self) weakSelf = self;
    void (^completed)(id, NSError *) = ^(id responseObject, NSError *error) {
        didCompletedBlock(responseObject, error);
        [weakSelf.sessionManager invalidateSessionCancelingTasks:NO resetSession:YES];
        weakSelf.sessionManager = nil;
    };
    if (config.requestSerializerType == JSRequestSerializerTypeFormData) {
        _requestTask = [self.sessionManager uploadTaskWithStreamedRequest:request
                                                                 progress:uploadProgressBlock
                                                        completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            completed(responseObject, error);
        }];
    } else {
        _requestTask = [self.sessionManager dataTaskWithRequest:request
                                                 uploadProgress:uploadProgressBlock
                                               downloadProgress:downloadProgressBlock
                                              completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            completed(responseObject, error);
        }];
    }
    /// 创建完成时需要调用
    didCreateTaskBlock(_requestTask);
}

- (NSURLSessionTask *)requestTask {
    return _requestTask;
}

- (void)cancel {
    [self.sessionManager invalidateSessionCancelingTasks:YES resetSession:NO];
}

- (void)dealloc {
    if (self.sessionManager) {
        [self.sessionManager invalidateSessionCancelingTasks:YES resetSession:YES];
        self.sessionManager = nil;
    }
}

@end
