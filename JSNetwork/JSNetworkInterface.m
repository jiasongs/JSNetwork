
//
//  JSNetworkInterface.m
//  JSNetwork
//
//  Created by jiasong on 2020/4/18.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import "JSNetworkInterface.h"
#import "JSNetworkRequestConfigProtocol.h"
#import "JSNetworkResponseProtocol.h"
#import "JSNetworkConfig.h"
#import "JSNetworkUtil.h"
#import "NSDictionary+JSURL.h"

@implementation JSNetworkInterface

@synthesize allPlugins = _allPlugins;
@synthesize finalHTTPBody = _finalHTTPBody;
@synthesize finalArguments = _finalArguments;
@synthesize finalURL = _finalURL;
@synthesize HTTPMethod = _HTTPMethod;
@synthesize originalConfig = _originalConfig;
@synthesize response = _response;
@synthesize timeoutInterval = _timeoutInterval;
@synthesize HTTPHeaderFields = _HTTPHeaderFields;
@synthesize request = _request;
@synthesize cacheDirectoryPath = _cacheDirectoryPath;
@synthesize cacheVersion = _cacheVersion;
@synthesize cacheIgnore = _cacheIgnore;
@synthesize cacheTimeInSeconds = _cacheTimeInSeconds;
@synthesize diskCache = _diskCache;

- (instancetype)initWithRequestConfig:(id<JSNetworkRequestConfigProtocol>)config {
    NSParameterAssert(config);
    if (self = [super init]) {
        _originalConfig = config;
        NSString *url = config.requestUrl;
        if ([config respondsToSelector:@selector(baseUrl)]) {
            url = [NSString stringWithFormat:@"%@%@", config.baseUrl, url];
        }
        NSString *HTTPMethod = @"GET";
        NSDictionary *parameters = JSNetworkConfig.sharedConfig.urlFilterArguments;
        NSDictionary *headers = JSNetworkConfig.sharedConfig.HTTPHeaderFields;
        NSTimeInterval timeoutInterval = JSNetworkConfig.sharedConfig.timeoutInterval;
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
            NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:parameters];
            [dictionary addEntriesFromDictionary:config.requestArgument ? : @{}];
            parameters = dictionary.copy;
        }
        url = [JSNetworkUtil filterURL:url withParameter:parameters];
        if ([config respondsToSelector:@selector(requestUrlFilterWithURL:)]) {
            url = [config requestUrlFilterWithURL:_finalURL];
        }
        if ([config respondsToSelector:@selector(requestHeaderFieldValueDictionary)]) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:headers];
            [dic addEntriesFromDictionary:config.requestHeaderFieldValueDictionary];
            headers = dic.copy;
        }
        if ([config respondsToSelector:@selector(requestBody)]) {
            body = config.requestBody;
        }
        if ([config respondsToSelector:@selector(requestTimeoutInterval)]) {
            timeoutInterval = config.requestTimeoutInterval;
        }
        _finalURL = url;
        _HTTPMethod = HTTPMethod;
        _HTTPHeaderFields = headers;
        _finalArguments = [NSDictionary js_dictionaryWithURLQuery:_finalURL];
        _finalHTTPBody = body;
        _timeoutInterval = timeoutInterval;
        Class RequestClass = JSNetworkConfig.sharedConfig.requestClass;
        if ([config respondsToSelector:@selector(requestClass)]) {
            RequestClass = config.requestClass;
        }
        _request = [[RequestClass alloc] init];
        Class ResponseClass = JSNetworkConfig.sharedConfig.responseClass;
        if ([config respondsToSelector:@selector(responseClass)]) {
            ResponseClass = config.responseClass;
        }
        _response = [[ResponseClass alloc] init];
        NSMutableArray *plugins = [NSMutableArray arrayWithArray:JSNetworkConfig.sharedConfig.plugins];
        if ([config respondsToSelector:@selector(requestPlugins)]) {
            [plugins addObjectsFromArray:config.requestPlugins];
        }
        _allPlugins = plugins.copy;
        _cacheIgnore = true;
        if ([config respondsToSelector:@selector(cacheIgnore)]) {
            _cacheIgnore = config.cacheIgnore;
        }
        _cacheVersion = -1;
        if ([config respondsToSelector:@selector(cacheVersion)]) {
            _cacheVersion = config.cacheVersion;
        }
        _cacheTimeInSeconds = -1;
        if ([config respondsToSelector:@selector(cacheTimeInSeconds)]) {
            _cacheTimeInSeconds = config.cacheTimeInSeconds;
        }
        _cacheDirectoryPath = JSNetworkConfig.sharedConfig.cacheDirectoryPath;
        if ([config respondsToSelector:@selector(cacheDirectoryPath)]) {
            _cacheDirectoryPath = config.cacheDirectoryPath;
        }
        if (!_cacheIgnore) {
            Class DiskCacheClass = JSNetworkConfig.sharedConfig.diskCache;
            _diskCache = [[DiskCacheClass alloc] init];
        }
    }
    return self;
}

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"JSNetworkInterface - 已经释放");
#endif
}

@end
