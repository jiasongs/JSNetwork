
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
#import "JSNetworkRequestConfigProxy.h"

@implementation JSNetworkInterface

@synthesize processedConfig = _processedConfig;
@synthesize response = _response;
@synthesize request = _request;
@synthesize diskCache = _diskCache;

- (instancetype)initWithRequestConfig:(id<JSNetworkRequestConfigProtocol>)config {
    NSParameterAssert(config);
    if (self = [super init]) {
        /// 处理过的请求配置实例
        _processedConfig = (id<JSNetworkRequestConfigProtocol>)[JSNetworkRequestConfigProxy proxyWithTarget:config];
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
            Class DiskCacheClass = JSNetworkConfig.sharedConfig.diskCacheClass;
            _diskCache = [[DiskCacheClass alloc] init];
        }
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"\n{\n%@: <%p>\n----------------\n%@\n----------------\n%@\n----------------\n%@\n}",
            NSStringFromClass(self.class),
            self,
            _processedConfig,
            _request,
            _response
            ];
}

- (void)dealloc {
    JSNetworkLog(@"%@ - 已经释放", NSStringFromClass([self class]));
}

@end
