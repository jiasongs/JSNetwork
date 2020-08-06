//
//  JSNetworkRequestConfigProxy.m
//  JSNetwork
//
//  Created by jiasong on 2020/5/16.
//

#import "JSNetworkRequestConfigProxy.h"
#import "NSDictionary+JSURL.h"
#import "NSString+JSURL.h"
#import "JSNetworkConfig.h"
#import "JSNetworkUtil.h"

@interface _JSNetworkRequestConfigPrivate : NSObject <JSNetworkRequestConfigProtocol>

@property (nonatomic, strong) NSString *finalURL;
@property (nonatomic, strong) NSDictionary *finalArguments;
@property (nonatomic, strong) NSDictionary *finalHTTPHeaderFields;
@property (nonatomic, strong) NSArray *finalPlugins;
@property (nonatomic, strong) NSString *finalCacheFileName;

@end

@implementation _JSNetworkRequestConfigPrivate

- (instancetype)initWithConfig:(id<JSNetworkRequestConfigProtocol>)config {
    if (self = [super init]) {
        /// URL拼接参数
        NSDictionary *parameters = JSNetworkConfig.sharedConfig.urlFilterArguments;
        if ([config respondsToSelector:@selector(requestArgument)]) {
            NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:parameters];
            [dictionary addEntriesFromDictionary:config.requestArgument ? : @{}];
            parameters = dictionary.copy;
        }
        NSString *baseUrl = [config respondsToSelector:@selector(baseUrl)] ? config.baseUrl : self.baseUrl;
        NSString *url = [NSString stringWithFormat:@"%@%@", baseUrl, config.requestUrl];
        _finalURL = [url js_URLStringByAppendingParameters:parameters];
        if ([config respondsToSelector:@selector(requestUrlFilterWithURL:)]) {
            _finalURL = [config requestUrlFilterWithURL:_finalURL];
        }
        _finalArguments = [NSDictionary js_URLQueryDictionaryWithURLString:_finalURL];
        /// 拼接请求头
        NSDictionary *headers = JSNetworkConfig.sharedConfig.HTTPHeaderFields;
        if ([config respondsToSelector:@selector(requestHeaderFieldValueDictionary)]) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:headers];
            [dic addEntriesFromDictionary:config.requestHeaderFieldValueDictionary ? : @{}];
            headers = dic.copy;
        }
        _finalHTTPHeaderFields = headers;
        /// 全部的插件
        NSMutableArray *plugins = [NSMutableArray arrayWithArray:JSNetworkConfig.sharedConfig.plugins];
        if ([config respondsToSelector:@selector(requestPlugins)]) {
            [plugins addObjectsFromArray:config.requestPlugins];
        }
        _finalPlugins = plugins.copy;
        /// 缓存的文件名
        if ([config respondsToSelector:@selector(cacheFileName)]) {
            _finalCacheFileName = config.cacheFileName;
        } else {
            NSString *requestUrl = config.requestUrl;
            NSDictionary *argument = @{};
            if ([config respondsToSelector:@selector(requestArgument)]) {
                argument = config.requestArgument ? : @{};
            }
            NSString *requestInfo = [NSString stringWithFormat:@"Host:%@ Url:%@ Argument:%@ Method:%@",
                                     baseUrl,
                                     requestUrl,
                                     argument,
                                     @(self.requestMethod)];
            _finalCacheFileName = [JSNetworkUtil md5StringFromString:requestInfo];
        }
    }
    return self;
}

#pragma mark - JSNetworkRequestConfigProtocol

- (NSString *)requestUrl {
    return _finalURL;
}

- (NSString *)baseUrl {
    return JSNetworkConfig.sharedConfig.baseURL;
}

- (nullable NSDictionary *)requestArgument {
    return _finalArguments;
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

- (NSIndexSet *)responseAcceptableStatusCodes {
    return [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(100, 500)];;
}

- (NSArray<id<JSNetworkPluginProtocol>> *)requestPlugins {
    return _finalPlugins;
}

- (BOOL)cacheIgnore {
    return YES;
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
@property (nonatomic, strong) NSArray<NSString *> *ignoreForwardingSelectors; /// 忽略转发的方法名

@end

@implementation JSNetworkRequestConfigProxy

- (instancetype)initWithTarget:(id<JSNetworkRequestConfigProtocol>)target {
    self = [super initWithTarget:target];
    if (self) {
        _privateConfig = [[_JSNetworkRequestConfigPrivate alloc] initWithConfig:target];
        _ignoreForwardingSelectors = @[NSStringFromSelector(@selector(requestUrl)),
                                       NSStringFromSelector(@selector(requestArgument)),
                                       NSStringFromSelector(@selector(requestHeaderFieldValueDictionary)),
                                       NSStringFromSelector(@selector(requestPlugins)),
                                       NSStringFromSelector(@selector(cacheFileName))];
    }
    return self;
}

#pragma mark - NSProxy

- (id)forwardingTargetForSelector:(SEL)aSelector {
    if ([_ignoreForwardingSelectors containsObject:NSStringFromSelector(aSelector)]) {
        return _privateConfig;
    }
    if ([self.target respondsToSelector:aSelector]) {
        return self.target;
    }
    if ([_privateConfig respondsToSelector:aSelector]) {
        return _privateConfig;
    }
    return nil;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    if ([self.target respondsToSelector:aSelector]) {
        return YES;
    }
    if ([_privateConfig respondsToSelector:aSelector]) {
        return YES;
    }
    return NO;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@: <%p>\n{\nURL: %@\nArguments: %@\nBody: %@\nHeader: %@\nMethod: %@\nCacheFilePath: %@\n}",
            NSStringFromClass([self.target class]),
            self.target,
            [self performSelector:@selector(requestUrl)],
            [self performSelector:@selector(requestArgument)],
            [self performSelector:@selector(requestBody)],
            [self performSelector:@selector(requestHeaderFieldValueDictionary)],
            @((JSRequestMethod)[self performSelector:@selector(requestMethod)]),
            !(BOOL)[self performSelector:@selector(cacheIgnore)] ? [NSString stringWithFormat:@"%@/%@.metadata", [self performSelector:@selector(cacheDirectoryPath)], [self performSelector:@selector(cacheFileName)]] : @""
            ];
}

- (void)dealloc {
    //    JSNetworkLog(@"%@ - 已经释放", NSStringFromClass([_privateConfig class]));
}

@end
