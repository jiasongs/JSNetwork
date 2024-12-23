//
//  JSNetworkAFRequest.m
//  JSNetwork
//
//  Created by jiasong on 2021/1/6.
//

#import "JSNetworkAFRequest.h"
#import "JSNetworkRequestProtocol.h"
#import "JSNetworkRequestConfigProtocol.h"
#import "JSNetworkConfig.h"
#import "AFNetworking.h"

@interface JSNetworkAFRequest () {
    NSURLSessionTask *_requestTask;
}

@property (nullable, nonatomic, strong) AFHTTPSessionManager *sessionManager;

@end

@implementation JSNetworkAFRequest

- (void)buildTaskWithConfig:(id<JSNetworkRequestConfigProtocol>)config
          multipartFormData:(void(^)(id formData))multipartFormDataBlock
             uploadProgress:(void(^)(NSProgress *uploadProgress))uploadProgressBlock
           downloadProgress:(void(^)(NSProgress *downloadProgress))downloadProgressBlock
        didCreateURLRequest:(void(^)(NSMutableURLRequest *urlRequest))didCreateURLRequestBlock
              didCreateTask:(void(^)(__kindof NSURLSessionTask *task))didCreateTaskBlock
               didCompleted:(void(^)(id _Nullable responseObject, NSError *_Nullable error))didCompletedBlock {
    AFHTTPSessionManager *(^createSessionManager)(void) = ^AFHTTPSessionManager *{
        AFHTTPSessionManager *temporaryManager = [[AFHTTPSessionManager alloc] initWithBaseURL:nil sessionConfiguration:nil];
        temporaryManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        return temporaryManager;
    };
    if (self.isUseUniqueSessionManager) {
        static AFHTTPSessionManager *uniqueSessionManager = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            uniqueSessionManager = createSessionManager();
        });
        self.sessionManager = uniqueSessionManager;
    } else {
        self.sessionManager = createSessionManager();
    }
    /// AFNetworking的处理线程
    self.sessionManager.completionQueue = JSNetworkConfig.sharedConfig.processingQueue;
    
    /// 构建request
    BOOL useFormData = NO;
    __kindof AFHTTPRequestSerializer *requestSerializer = nil;
    switch (config.requestSerializerType) {
        case JSRequestSerializerTypeJSON:
            requestSerializer = [AFJSONRequestSerializer serializer];
            break;
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
    requestSerializer.timeoutInterval = config.requestTimeoutInterval;
    NSDictionary *headers = config.requestHeaderFieldValueDictionary;
    for (NSString *headerField in headers.keyEnumerator) {
        [requestSerializer setValue:headers[headerField] forHTTPHeaderField:headerField];
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
        request = [requestSerializer multipartFormRequestWithMethod:method
                                                          URLString:[[NSURL URLWithString:config.requestURLString] absoluteString]
                                                         parameters:requestBody
                                          constructingBodyWithBlock:multipartFormDataBlock
                                                              error:nil];
    } else {
        request = [requestSerializer requestWithMethod:method
                                             URLString:[[NSURL URLWithString:config.requestURLString] absoluteString]
                                            parameters:requestBody
                                                 error:nil];
    }
    if (!request) {
        request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:config.requestURLString]
                                          cachePolicy:NSURLRequestUseProtocolCachePolicy
                                      timeoutInterval:config.requestTimeoutInterval];
    }
    /// URLRequest创建完成时需要调用
    didCreateURLRequestBlock(request);
    
    __kindof AFHTTPResponseSerializer *responseSerializer = nil;
    switch (config.responseSerializerType) {
        case JSResponseSerializerTypeJSON:
            responseSerializer = [AFJSONResponseSerializer serializer];
            break;
        case JSResponseSerializerTypeHTTP:
            responseSerializer = [AFHTTPResponseSerializer serializer];
            break;
        case JSResponseSerializerTypeXMLParser:
            responseSerializer = [AFXMLParserResponseSerializer serializer];
            break;
        default:
            break;
    }
    NSIndexSet *responseAcceptableStatusCodes = config.responseAcceptableStatusCodes;
    if (responseAcceptableStatusCodes) {
        NSMutableIndexSet *acceptableStatusCodes = [[NSMutableIndexSet alloc] initWithIndexSet:responseSerializer.acceptableStatusCodes ? : NSIndexSet.indexSet];
        [acceptableStatusCodes addIndexes:responseAcceptableStatusCodes];
        responseSerializer.acceptableStatusCodes = acceptableStatusCodes.copy;
    }
    NSSet<NSString *> *responseAcceptableContentTypes = config.responseAcceptableContentTypes;
    if (responseAcceptableContentTypes) {
        NSMutableSet *acceptableContentTypes = [NSMutableSet setWithSet:responseSerializer.acceptableContentTypes ? : NSSet.set];
        [acceptableContentTypes unionSet:responseAcceptableContentTypes];
        responseSerializer.acceptableContentTypes = acceptableContentTypes.copy;
    }

    /// 构建task
    if (config.requestSerializerType == JSRequestSerializerTypeFormData) {
        _requestTask = [self.sessionManager uploadTaskWithStreamedRequest:request
                                                                 progress:uploadProgressBlock
                                                        completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            [self handleResultWithSerializer:responseSerializer
                                 URLResponse:response
                              responseObject:responseObject
                                       error:error
                                didCompleted:didCompletedBlock];
        }];
    } else {
        _requestTask = [self.sessionManager dataTaskWithRequest:request
                                                 uploadProgress:uploadProgressBlock
                                               downloadProgress:downloadProgressBlock
                                              completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            [self handleResultWithSerializer:responseSerializer
                                 URLResponse:response
                              responseObject:responseObject
                                       error:error
                                didCompleted:didCompletedBlock];
        }];
    }
    /// Task创建完成时需要调用
    didCreateTaskBlock(_requestTask);
}

- (NSURLSessionTask *)requestTask {
    return _requestTask;
}

#pragma mark - Handle Response

- (void)handleResultWithSerializer:(__kindof AFHTTPResponseSerializer *)responseSerializer
                       URLResponse:(NSURLResponse *)URLResponse
                    responseObject:(id)responseObject
                             error:(NSError *)error
                      didCompleted:(void(^)(id _Nullable responseObject, NSError *_Nullable error))didCompletedBlock {
    id resultObject = nil;
    NSError *resultError = nil;
    NSError *serializationError = nil;
    resultObject = [responseSerializer responseObjectForResponse:URLResponse data:responseObject error:&serializationError];
    if (error) {
        resultError = error;
    } else if (serializationError) {
        resultError = serializationError;
    }
    didCompletedBlock(resultObject, resultError);
    
    if (!self.isUseUniqueSessionManager) {
        if (self.sessionManager.tasks.count == 0) {
            [self.sessionManager invalidateSessionCancelingTasks:NO resetSession:YES];
        } else {
            NSAssert(NO, @"同一个session下有多个任务不得重置session, 请按照堆栈检查代码");
        }
    }
    self.sessionManager = nil;
}

@end
