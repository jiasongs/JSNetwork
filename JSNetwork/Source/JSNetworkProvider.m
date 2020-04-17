//
//  JSNetworkProvider.m
//  JSNetwork
//
//  Created by jiasong on 2020/4/17.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import "JSNetworkProvider.h"
#import "JSNetworkAgent.h"

@implementation JSNetworkProvider

+ (void)request:(id<JSRequestProtocol>)request complete:(JSRequestCompletionBlock)complete {
    AFHTTPSessionManager *manger = [AFHTTPSessionManager manager];
    manger.requestSerializer = [self requestSerializerForRequest:request];
    manger.responseSerializer = [self responseSerializerForRequest:request];
    NSString *HTTPMethod = @"";
    switch ([request requestMethod]) {
        case JSRequestMethodGET:
            HTTPMethod = @"GET";
            break;
            case JSRequestMethodPOST:
            HTTPMethod = @"POST";
            break;
        default:
            break;
    }
    NSString *url = [self buildRequestUrl:request];
    id param = request.requestArgument;
    NSURLSessionDataTask *dataTask = [manger dataTaskWithHTTPMethod:HTTPMethod URLString:url parameters:param headers:@{} uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
        
    } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        complete();
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        complete();
    }];
    
    [JSNetworkAgent.sharedInstance addRequest:request];
}

+ (AFHTTPRequestSerializer *)requestSerializerForRequest:(id<JSRequestProtocol>)request {
    AFHTTPRequestSerializer *requestSerializer = nil;
    if (request.requestSerializerType == JSRequestSerializerTypeHTTP) {
        requestSerializer = [AFHTTPRequestSerializer serializer];
    } else if (request.requestSerializerType == JSRequestSerializerTypeJSON) {
        requestSerializer = [AFJSONRequestSerializer serializer];
    }
    requestSerializer.timeoutInterval = [request requestTimeoutInterval];
    return requestSerializer;
}

+ (AFHTTPResponseSerializer *)responseSerializerForRequest:(id<JSRequestProtocol>)request {
   AFHTTPResponseSerializer *responseSerializer = nil;
    if (request.responseSerializerType == JSResponseSerializerTypeHTTP) {
         responseSerializer = [AFHTTPResponseSerializer serializer];
    } else if (request.responseSerializerType == JSResponseSerializerTypeJSON){
        responseSerializer = [AFJSONResponseSerializer serializer];
    } else if (request.responseSerializerType == JSResponseSerializerTypeXMLParser){
        responseSerializer = [AFXMLParserResponseSerializer serializer];
    }
    return responseSerializer;
}

+ (NSString *)buildRequestUrl:(id<JSRequestProtocol>)request {
    NSString *detailUrl = [request requestUrl];
    return detailUrl;;
}

@end
