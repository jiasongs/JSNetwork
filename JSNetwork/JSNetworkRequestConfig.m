//
//  JSNetworkRequestConfig.m
//  AFNetworking
//
//  Created by jiasong on 2020/4/24.
//

#import "JSNetworkRequestConfig.h"
#import "NSDictionary+JSURL.h"
#import "JSNetworkConfig.h"
#import "JSNetworkUtil.h"

@interface JSNetworkRequestConfig ()

@property (nonatomic, weak) id<JSNetworkRequestConfigProtocol> originalConfig;
@property (nonatomic, strong) NSString *finalURL;
@property (nonatomic, strong) NSDictionary *finalArguments;
@property (nonatomic, strong) NSDictionary *finalHTTPHeaderFields;
@property (nonatomic, strong) NSArray *allPlugins;
@property (nonatomic, strong) NSString *finalCacheFileName;

@end

@implementation JSNetworkRequestConfig

- (instancetype)initWithConfig:(id<JSNetworkRequestConfigProtocol>)config {
    if (self = [super init]) {
        /// 原始的配置, 用weak即可, 外部已经引用
        _originalConfig = config;
        /// URL拼接参数
        NSDictionary *parameters = JSNetworkConfig.sharedConfig.urlFilterArguments;
        if ([config respondsToSelector:@selector(requestArgument)]) {
            NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:parameters];
            [dictionary addEntriesFromDictionary:config.requestArgument ? : @{}];
            parameters = dictionary.copy;
        }
        NSString *url = [NSString stringWithFormat:@"%@%@", self.baseUrl, config.requestUrl];
        _finalURL = [self requestUrlFilterWithURL:[JSNetworkUtil filterURL:url withParameter:parameters]];;
        _finalArguments = [NSDictionary js_dictionaryWithURLQuery:_finalURL];
        /// 拼接请求头
        NSDictionary *headers = JSNetworkConfig.sharedConfig.HTTPHeaderFields;
        if ([config respondsToSelector:@selector(requestHeaderFieldValueDictionary)]) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:headers];
            [dic addEntriesFromDictionary:config.requestHeaderFieldValueDictionary];
            headers = dic.copy;
        }
        _finalHTTPHeaderFields = headers;
        /// 全部的插件
        NSMutableArray *plugins = [NSMutableArray arrayWithArray:JSNetworkConfig.sharedConfig.plugins];
        if ([config respondsToSelector:@selector(requestPlugins)]) {
            [plugins addObjectsFromArray:config.requestPlugins];
        }
        _allPlugins = plugins.copy;
        /// 缓存的文件名
        if ([config respondsToSelector:@selector(cacheFileName)]) {
            _finalCacheFileName = config.cacheFileName;
        } else {
            NSString *requestUrl = config.requestUrl;
            NSString *baseUrl = self.baseUrl;
            NSDictionary *argument = @{};
            if ([_originalConfig respondsToSelector:@selector(requestArgument)]) {
                argument = _originalConfig.requestArgument;
            }
            NSString *requestInfo = [NSString stringWithFormat:@"Host:%@ Url:%@ Argument:%@ Method:%@", baseUrl, requestUrl, argument, @(self.requestMethod)];
            _finalCacheFileName = [JSNetworkUtil md5StringFromString:requestInfo];;
        }
    }
    return self;
}

- (NSString *)requestUrl {
    return _finalURL;
}

- (NSString *)baseUrl {
    if ([_originalConfig respondsToSelector:@selector(baseUrl)]) {
        return [_originalConfig baseUrl];
    }
    return JSNetworkConfig.sharedConfig.baseURL;
}

- (nullable NSDictionary *)requestArgument {
    return _finalArguments;
}

- (nullable id)requestBody {
    if ([_originalConfig respondsToSelector:@selector(requestBody)]) {
        return [_originalConfig requestBody];
    }
    return nil;
}

- (JSRequestMethod)requestMethod {
    if ([_originalConfig respondsToSelector:@selector(requestMethod)]) {
        return [_originalConfig requestMethod];
    }
    return JSRequestMethodGET;
}

- (JSRequestSerializerType)requestSerializerType {
    if ([_originalConfig respondsToSelector:@selector(requestSerializerType)]) {
        return [_originalConfig requestSerializerType];
    }
    return JSRequestSerializerTypeJSON;
}

- (JSResponseSerializerType)responseSerializerType {
    if ([_originalConfig respondsToSelector:@selector(responseSerializerType)]) {
        return [_originalConfig responseSerializerType];
    }
    return JSResponseSerializerTypeJSON;
}

- (NSTimeInterval)requestTimeoutInterval {
    if ([_originalConfig respondsToSelector:@selector(requestTimeoutInterval)]) {
        return [_originalConfig requestTimeoutInterval];
    }
    return JSNetworkConfig.sharedConfig.timeoutInterval;
}

- (nullable NSDictionary<NSString *, NSString *> *)requestHeaderFieldValueDictionary {
    return _finalHTTPHeaderFields;
}

- (NSString *)requestUrlFilterWithURL:(NSString *)URL {
    if ([_originalConfig respondsToSelector:@selector(requestUrlFilterWithURL:)]) {
        return [_originalConfig requestUrlFilterWithURL:_finalURL];
    }
    return URL;
}

- (NSArray<id<JSNetworkPluginProtocol>> *)requestPlugins {
    return _allPlugins;
}

- (BOOL)cacheIgnore {
    if ([_originalConfig respondsToSelector:@selector(cacheIgnore)]) {
        return [_originalConfig cacheIgnore];
    }
    return true;
}

- (long long)cacheVersion {
    if ([_originalConfig respondsToSelector:@selector(cacheVersion)]) {
        return [_originalConfig cacheVersion];
    }
    return -1;
}

- (NSInteger)cacheTimeInSeconds {
    if ([_originalConfig respondsToSelector:@selector(cacheTimeInSeconds)]) {
        return [_originalConfig cacheTimeInSeconds];
    }
    return -1;
}

- (BOOL)cacheIsSavedWithResponse:(id<JSNetworkResponseProtocol>)response {
    if ([_originalConfig respondsToSelector:@selector(cacheIsSavedWithResponse:)]) {
        return [_originalConfig cacheIsSavedWithResponse:response];
    }
    return true;
}

- (NSString *)cacheFileName {
    return _finalCacheFileName;
}

- (NSString *)cacheDirectoryPath {
    if ([_originalConfig respondsToSelector:@selector(cacheDirectoryPath)]) {
        return [_originalConfig cacheDirectoryPath];
    }
    return JSNetworkConfig.sharedConfig.cacheDirectoryPath;
}

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"JSNetworkRequestConfig - 已经释放");
#endif
}

@end
