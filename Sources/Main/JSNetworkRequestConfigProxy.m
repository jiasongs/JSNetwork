//
//  JSNetworkRequestConfigProxy.m
//  JSNetwork
//
//  Created by jiasong on 2020/5/16.
//

#import "JSNetworkRequestConfigProxy.h"
#import "JSNetworkRequestConfigProtocol.h"
#import "NSDictionary+JSURL.h"
#import "NSString+JSURL.h"
#import "JSNetworkConfig.h"
#import "JSNetworkUtil.h"

@interface _JSNetworkRequestConfigPrivate : NSObject <JSNetworkRequestConfigProtocol>

@property (nonatomic, copy) NSString *finalURL;
@property (nonatomic, copy) NSDictionary<NSString *, NSString *> *finalParameters;
@property (nonatomic, copy) NSDictionary<NSString *, NSString *> *finalHTTPHeaderFields;
@property (nonatomic, copy) NSArray<id<JSNetworkPluginProtocol>> *finalPlugins;
@property (nonatomic, copy) NSString *finalCacheFileName;

@end

@implementation _JSNetworkRequestConfigPrivate

- (instancetype)initWithConfig:(id<JSNetworkRequestConfigProtocol>)config {
    if (self = [super init]) {
        /// URL拼接参数
        NSDictionary<NSString *, id> *URLParameters = JSNetworkConfig.sharedConfig.URLParameters ? : @{};
        NSMutableDictionary<NSString *, id> *parameters = [NSMutableDictionary dictionaryWithDictionary:URLParameters];
        if ([config respondsToSelector:@selector(requestParameters)]) {
            [parameters addEntriesFromDictionary:config.requestParameters ? : @{}];
        }
        if ([config respondsToSelector:@selector(requestCompositeParametersWithParameters:)]) {
            [parameters setDictionary:[config requestCompositeParametersWithParameters:parameters]];
        }
        _finalParameters = parameters;
        
        NSString *baseUrl = [config respondsToSelector:@selector(baseURLString)] ? config.baseURLString : self.baseURLString;
        NSString *url = [NSString stringWithFormat:@"%@%@", baseUrl, config.requestURLString];
        NSArray<NSString *> *paths = @[];
        if ([config respondsToSelector:@selector(requestPaths)]) {
            paths = config.requestPaths ? : @[];
        }
        NSString *finalURL = [url js_URLStringByAppendingPaths:paths parameters:parameters];
        if ([config respondsToSelector:@selector(requestCompositeURLStringWithURLString:)]) {
            finalURL = [config requestCompositeURLStringWithURLString:finalURL];
        }
        _finalURL = finalURL;

        /// 拼接请求头
        NSDictionary<NSString *, NSString *> *HTTPHeaderFields = JSNetworkConfig.sharedConfig.HTTPHeaderFields ? : @{};
        NSMutableDictionary<NSString *, NSString *> *headers = [NSMutableDictionary dictionaryWithDictionary:HTTPHeaderFields];
        if ([config respondsToSelector:@selector(requestHeaderFieldValueDictionary)]) {
            [headers addEntriesFromDictionary:config.requestHeaderFieldValueDictionary ? : @{}];
        }
        _finalHTTPHeaderFields = headers;
        
        /// 全部的插件
        NSMutableArray *plugins = [NSMutableArray arrayWithArray:JSNetworkConfig.sharedConfig.plugins];
        if ([config respondsToSelector:@selector(requestPlugins)]) {
            [plugins addObjectsFromArray:config.requestPlugins];
        }
        _finalPlugins = plugins;
        
        if ([config respondsToSelector:@selector(cachePolicy)] && config.cachePolicy == JSRequestCachePolicyUseCacheDataElseLoad) {
            /// 缓存的文件名
            if ([config respondsToSelector:@selector(cacheFileName)]) {
                _finalCacheFileName = config.cacheFileName;
            } else {
                NSString *requestInfo = [NSString stringWithFormat:@"Url:%@ Method:%@", _finalURL, @(self.requestMethod)];
                _finalCacheFileName = [JSNetworkUtil md5StringFromString:requestInfo];
            }
        }
    }
    return self;
}

#pragma mark - JSNetworkRequestConfigProtocol

- (NSString *)requestURLString {
    return _finalURL;
}

- (NSString *)baseURLString {
    return JSNetworkConfig.sharedConfig.baseURLString;
}

- (nullable NSArray<NSString *> *)requestPaths {
    return nil;
}

- (nullable NSDictionary<NSString *, id> *)requestParameters {
    return _finalParameters;
}

- (nullable id)requestBody {
    return nil;
}

- (JSRequestMethod)requestMethod {
    return JSRequestMethodGET;
}

- (JSRequestSerializerType)requestSerializerType {
    return JSRequestSerializerTypeJSON;
}

- (JSResponseSerializerType)responseSerializerType {
    return JSResponseSerializerTypeJSON;
}

- (NSTimeInterval)requestTimeoutInterval {
    return JSNetworkConfig.sharedConfig.timeoutInterval;
}

- (nullable NSDictionary<NSString *, NSString *> *)requestHeaderFieldValueDictionary {
    return _finalHTTPHeaderFields;
}

- (nullable NSSet<NSString *> *)responseAcceptableContentTypes {
    return nil;
}

- (void)requestConstructingMultipartFormData:(id)multipartFormData {
    
}

- (NSIndexSet *)responseAcceptableStatusCodes {
    return [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(100, 500)];
}

- (NSArray<id<JSNetworkPluginProtocol>> *)requestPlugins {
    return _finalPlugins;
}

- (JSRequestCachePolicy)cachePolicy {
    return JSRequestCachePolicyIgnoringCacheData;
}

- (long long)cacheVersion {
    return -1;
}

- (NSInteger)cacheTimeInSeconds {
    return -1;
}

- (BOOL)cacheIsSavedWithResponse:(id<JSNetworkResponseProtocol>)response {
    return YES;
}

- (NSString *)cacheFileName {
    return _finalCacheFileName;
}

- (NSString *)cacheDirectoryPath {
    return JSNetworkConfig.sharedConfig.cacheDirectoryPath;
}

@end

@interface JSNetworkRequestConfigProxy ()

@property (nonatomic, strong) _JSNetworkRequestConfigPrivate *privateConfig;

@end

@implementation JSNetworkRequestConfigProxy

- (instancetype)initWithTarget:(id<JSNetworkRequestConfigProtocol>)target {
    self = [super initWithTarget:target];
    if (self) {
        _privateConfig = [[_JSNetworkRequestConfigPrivate alloc] initWithConfig:target];
    }
    return self;
}

#pragma mark - NSProxy

- (id)forwardingTargetForSelector:(SEL)aSelector {
    if ([self __needForwardingPrivateConfigForSelector:aSelector]) {
        return _privateConfig;
    }
    if ([self.target respondsToSelector:aSelector]) {
        return self.target;
    }
    return _privateConfig;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    if ([self __needForwardingPrivateConfigForSelector:aSelector]) {
        return [_privateConfig respondsToSelector:aSelector];
    }
    if ([self.target respondsToSelector:aSelector]) {
        return YES;
    }
    return [_privateConfig respondsToSelector:aSelector];
}

- (BOOL)__needForwardingPrivateConfigForSelector:(SEL)aSelector {
    static NSArray *ignoreSelectors = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ignoreSelectors = @[NSStringFromSelector(@selector(requestURLString)),
                            NSStringFromSelector(@selector(requestParameters)),
                            NSStringFromSelector(@selector(requestHeaderFieldValueDictionary)),
                            NSStringFromSelector(@selector(requestPlugins)),
                            NSStringFromSelector(@selector(cacheFileName))];
    });
    return [ignoreSelectors containsObject:NSStringFromSelector(aSelector)];
}

- (NSString *)description {
#ifdef DEBUG
    JSRequestCachePolicy cachePolicy = (JSRequestCachePolicy)[self performSelector:@selector(cachePolicy)];
    NSDictionary *value = @{
        @"url": [self performSelector:@selector(requestURLString)] ? : @"",
        @"header": [self performSelector:@selector(requestHeaderFieldValueDictionary)] ? : @"",
        @"parameters": [self performSelector:@selector(requestParameters)] ? : @"",
        @"body": [self performSelector:@selector(requestBody)] ? : @"",
        @"method": @((JSRequestMethod)[self performSelector:@selector(requestMethod)]),
        @"cacheFilePath": cachePolicy == JSRequestCachePolicyUseCacheDataElseLoad ? [NSString stringWithFormat:@"%@/%@.metadata", [self performSelector:@selector(cacheDirectoryPath)], [self performSelector:@selector(cacheFileName)]] : @""
    };
    NSDictionary *result = [NSDictionary dictionaryWithObject:value forKey:[super description]];
    NSData *resultData = [NSJSONSerialization dataWithJSONObject:result options:NSJSONWritingPrettyPrinted error:nil];
    NSString *resultString = [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
    resultString = [resultString stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
    return resultString;
#else
    return [super description];
#endif
}

@end
