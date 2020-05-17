
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
#import "JSNetworkProxy.h"
#import "JSNetworkRequestProtocol.h"

@interface JSNetworkInterface ()

@property (nonatomic, strong) id<JSNetworkRequestConfigProtocol> config;
@property (nonatomic, strong) JSNetworkProxy *interfaceProxy;
@property (nonatomic, strong) NSMutableArray<JSNetworkRequestCompletedFilter> *completionBlocks;

@end

@implementation JSNetworkInterface

@synthesize processedConfig = _processedConfig;
@synthesize response = _response;
@synthesize request = _request;
@synthesize diskCache = _diskCache;
@synthesize uploadProgress = _uploadProgress;
@synthesize downloadProgress = _downloadProgress;
@synthesize completionBlocks = _completionBlocks;

- (instancetype)initWithRequestConfig:(id<JSNetworkRequestConfigProtocol>)config {
    NSParameterAssert(config);
    if (self = [super init]) {
        /// 持有一下config, 防止提前释放
        _config = config;
        /// 处理过的请求配置实例
        _processedConfig = (id<JSNetworkRequestConfigProtocol>)[JSNetworkRequestConfigProxy proxyWithTarget:config];
        /// 请求实例
        Class RequestClass = JSNetworkConfig.sharedConfig.requestClass;
        if ([config respondsToSelector:@selector(requestClass)]) {
            RequestClass = config.requestClass;
        }
        _request = [[RequestClass alloc] init];
        /// 必须设置代理, 先持有一下, 防止提前释放
        _interfaceProxy = [JSNetworkProxy proxyWithTarget:self];
        [_request addInterfaceProxy:(id<JSNetworkInterfaceProtocol>)_interfaceProxy];
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
        _completionBlocks = [NSMutableArray array];
    }
    return self;
}

- (void)requestUploadProgress:(nullable JSNetworkProgressBlock)uploadProgress {
    _uploadProgress = uploadProgress;
}

- (void)requestDownloadProgress:(nullable JSNetworkProgressBlock)downloadProgress {
    _downloadProgress = downloadProgress;
}

- (void)requestCompletedFilter:(nullable JSNetworkRequestCompletedFilter)completionBlock {
    if (completionBlock) {
        [_completionBlocks addObject:completionBlock];
    }
}

- (void)clearAllCallBack {
    [_completionBlocks removeAllObjects];
    _uploadProgress = nil;
    _downloadProgress = nil;
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
    JSNetworkLog(@"%@ - 已经释放", NSStringFromClass([_config class]));
}

@end
