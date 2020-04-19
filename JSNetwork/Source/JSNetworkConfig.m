//
//  JSNetworkConfig.m
//  JSNetwork
//
//  Created by jiasong on 2020/4/17.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import "JSNetworkConfig.h"
#import "JSNetworkLoggerPlugin.h"

@interface JSNetworkConfig () {
    NSMutableArray *_plugins;
    NSDictionary *_urlFilterArguments;
    NSDictionary *_HTTPHeaderFields;
}

@property (nonatomic, strong) JSNetworkLoggerPlugin *loggerPlugin;

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
    }
    return self;
}

- (void)addUrlFilterArguments:(NSDictionary *)filter {
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
    [_plugins addObject:plugin];
}

- (void)clearPlugins {
    NSArray *array = [NSArray arrayWithArray:_plugins];
    for (id<JSNetworkPluginProtocol> plugin in array) {
        if (![_loggerPlugin isEqual:plugin]) {
            [_plugins removeObject:plugin];
        }
    }
}

- (void)addHTTPHeaderFields:(NSDictionary *)headerFields {
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

- (void)setDebugLogEnabled:(BOOL)debugLogEnabled {
    if (_debugLogEnabled != debugLogEnabled) {
        _debugLogEnabled = debugLogEnabled;
        if (debugLogEnabled && !_loggerPlugin) {
            [self addPlugins:self.loggerPlugin];
        } else if (!debugLogEnabled && _loggerPlugin) {
            [_plugins removeObject:_loggerPlugin];
            _loggerPlugin = nil;
        }
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

- (JSNetworkLoggerPlugin *)loggerPlugin {
    if (!_loggerPlugin) {
        _loggerPlugin = [[JSNetworkLoggerPlugin alloc] init];
    }
    return _loggerPlugin;;
}

@end
