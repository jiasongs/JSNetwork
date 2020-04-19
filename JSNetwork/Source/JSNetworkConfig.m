//
//  JSNetworkConfig.m
//  JSNetwork
//
//  Created by jiasong on 2020/4/17.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import "JSNetworkConfig.h"
#import "JSNetworkResponse.h"

@interface JSNetworkConfig () {
    NSMutableArray *_plugins;
    NSDictionary *_urlFilterArguments;
    NSDictionary *_HTTPHeaderFields;
}

@end

@implementation JSNetworkConfig

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static JSNetworkConfig *instance = nil;
    dispatch_once(&onceToken,^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return [self sharedInstance];
}

- (instancetype)init {
    if (self = [super init]) {
        _urlFilterArguments = [NSDictionary dictionary];
        _plugins = [NSMutableArray array];
        _timeoutInterval = 20;
        _responseClass = JSNetworkResponse.class;
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

- (void)addPlugins:(id<JSNetworkPluginProtocol>)plugin {
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
