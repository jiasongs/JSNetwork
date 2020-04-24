
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
#import "JSNetworkRequestConfig.h"

@implementation JSNetworkInterface

@synthesize processedConfig = _processedConfig;
@synthesize originalConfig = _originalConfig;
@synthesize response = _response;
@synthesize request = _request;
@synthesize diskCache = _diskCache;

- (instancetype)initWithRequestConfig:(id<JSNetworkRequestConfigProtocol>)config {
    NSParameterAssert(config);
    if (self = [super init]) {
        /// 原始的请求配置实例
        _originalConfig = config;
        /// 处理过的请求配置实例
        _processedConfig = [[JSNetworkRequestConfig alloc] initWithConfig:config];
        /// 请求实例
        Class RequestClass = JSNetworkConfig.sharedConfig.requestClass;
        if ([config respondsToSelector:@selector(requestClass)]) {
            RequestClass = config.requestClass;
        }
        _request = [[RequestClass alloc] init];
        /// 响应实例
        Class ResponseClass = JSNetworkConfig.sharedConfig.responseClass;
        if ([config respondsToSelector:@selector(responseClass)]) {
            ResponseClass = config.responseClass;
        }
        _response = [[ResponseClass alloc] init];
        /// 磁盘缓存的实例
        if (!_processedConfig.cacheIgnore) {
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
