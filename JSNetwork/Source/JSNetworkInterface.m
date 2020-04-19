
//
//  JSNetworkInterface.m
//  JSNetwork
//
//  Created by jiasong on 2020/4/18.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import "JSNetworkInterface.h"
#import "JSNetworkRequestConfigProtocol.h"
#import "NSDictionary+JSURL.h"
#import "NSString+JSURLCode.h"
#import "JSNetworkConfig.h"

@implementation JSNetworkInterface

- (instancetype)initWithRequestConfig:(id<JSNetworkRequestConfigProtocol>)config {
    if (self = [super init]) {
        _config = config;
        NSString *url = [NSString stringWithFormat:@"%@%@", config.baseUrl, config.requestUrl];
        NSString *HTTPMethod = @"GET";
        NSDictionary *parameters = nil;
        NSDictionary *headers = JSNetworkConfig.sharedInstance.HTTPHeaderFields;
        id body = nil;
        if ([config respondsToSelector:@selector(requestMethod)]) {
            switch (config.requestMethod) {
                case JSRequestMethodGET:
                    HTTPMethod = @"GET";
                    break;
                case JSRequestMethodPOST:
                    HTTPMethod = @"POST";
                    break;
                default:
                    HTTPMethod = @"GET";
                    break;
            }
        }
        if ([config respondsToSelector:@selector(requestArgument)]) {
            parameters = config.requestArgument;
        }
        if ([config respondsToSelector:@selector(requestHeaderFieldValueDictionary)]) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:headers];
            [dic addEntriesFromDictionary:config.requestHeaderFieldValueDictionary];
            headers = dic.copy;
        }
        if ([config respondsToSelector:@selector(requestBody)]) {
            body = config.requestBody;
        }
        url = [self filterURL:url withParameter:parameters];
        if ([config respondsToSelector:@selector(urlFilterWithURL:)]) {
          url = [config urlFilterWithURL:_finalURL];
        }
        _finalURL = url;
        _HTTPMethod = HTTPMethod;
        _HTTPHeaderFields = headers;
        _finalArguments = [NSDictionary js_dictionaryWithURLQuery:_finalURL];
        _finalBody = body;
    }
    return self;
}

- (NSString *)filterURL:(NSString *)URL withParameter:(NSDictionary<NSString *, id> *)parameter {
    NSString *finalUrl = URL.js_urlDecode;
    NSDictionary *finalParameters = @{};
    @autoreleasepool {
        NSString *newUrl = URL;
        NSString *newQuery = @"";
        if ([URL containsString:@"?"]) {
            NSArray *array = [URL componentsSeparatedByString:@"?"];
            newUrl = array.firstObject;
            newQuery = array.lastObject;
        }
        NSMutableDictionary *newParameters = [NSMutableDictionary dictionaryWithDictionary:JSNetworkConfig.sharedInstance.urlFilterArguments];
        [newParameters addEntriesFromDictionary:parameter];
        [newParameters addEntriesFromDictionary:[NSDictionary js_dictionaryWithURLQuery:newQuery]];
        finalParameters = newParameters.copy;
        finalUrl = newUrl;
    }
    if (finalParameters.count > 0) {
        finalUrl = [finalUrl stringByAppendingFormat:@"?%@", finalParameters.js_URLQueryString];
    }
    return finalUrl;
}

@end
