//
//  JSNetworkConfig.m
//  JSNetwork
//
//  Created by jiasong on 2020/4/17.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import "JSNetworkConfig.h"
#import "JSNetworkResponse.h"
#import "JSNetworkRequest.h"
#import "JSNetworkDiskCache.h"

@interface JSNetworkConfig () {
    NSMutableArray *_plugins;
    NSDictionary *_urlFilterArguments;
    NSDictionary *_HTTPHeaderFields;
}

@end

@implementation JSNetworkConfig

+ (instancetype)sharedConfig {
    static dispatch_once_t onceToken;
    static JSNetworkConfig *instance = nil;
    dispatch_once(&onceToken,^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return [self sharedConfig];
}

- (instancetype)init {
    if (self = [super init]) {
        _urlFilterArguments = @{};
        _plugins = [NSMutableArray array];
        _baseURL = @"";
        _timeoutInterval = 20;
        _requestClass = JSNetworkRequest.class;
        _responseClass = JSNetworkResponse.class;
        _processingQueue = dispatch_queue_create("com.jsnetwork.agent.processing", DISPATCH_QUEUE_CONCURRENT);
        _completionQueue = dispatch_get_main_queue();
        NSArray *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        _cacheDirectoryPath = [NSString stringWithFormat:@"%@/com.jsnetwork.cache", cachePaths.firstObject];
        _diskCache = JSNetworkDiskCache.class;
        _HTTPHeaderFields = @{};
    }
    return self;
}

- (void)addUrlFilterArguments:(NSDictionary *)filter {
    NSParameterAssert(filter);
    @synchronized (self) {
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:_urlFilterArguments];
        [dictionary addEntriesFromDictionary:filter];
        _urlFilterArguments = filter;
    }
}

- (void)clearUrlFilterArguments {
    @synchronized (self) {
        _urlFilterArguments = @{};
    }
}

- (void)addPlugin:(id<JSNetworkPluginProtocol>)plugin {
    NSParameterAssert(plugin);
    @synchronized (self) {
        [_plugins addObject:plugin];
    }
}

- (void)clearPlugins {
    @synchronized (self) {
        [_plugins removeAllObjects];
    }
}

- (void)addHTTPHeaderFields:(NSDictionary *)headerFields {
    NSParameterAssert(headerFields);
    @synchronized (self) {
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:_HTTPHeaderFields];
        [dictionary addEntriesFromDictionary:headerFields];
        _HTTPHeaderFields = headerFields;
    }
}

- (void)clearHTTPHeaderFields {
    @synchronized (self) {
        _HTTPHeaderFields = @{};
    }
}

- (NSDictionary *)urlFilterArguments {
    return _urlFilterArguments;;
}

- (NSArray *)plugins {
    return _plugins.copy;
}

- (NSDictionary *)HTTPHeaderFields {
    return _HTTPHeaderFields;
}

@end
