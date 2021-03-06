
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
#import "JSNetworkSpinLock.h"

@interface JSNetworkInterface () {
    id<JSNetworkRequestConfigProtocol> _config;
    NSMutableArray<JSNetworkRequestCompletedBlock> *_completionBlocks;
    NSString *_taskIdentifier;
}

@end

@implementation JSNetworkInterface

@synthesize processedConfig = _processedConfig;
@synthesize response = _response;
@synthesize request = _request;
@synthesize diskCache = _diskCache;
@synthesize uploadProgress = _uploadProgress;
@synthesize downloadProgress = _downloadProgress;
@synthesize completionBlocks = _completionBlocks;

- (instancetype)initWithRequestConfig:(id<JSNetworkRequestConfigProtocol>)config
                       uploadProgress:(nullable JSNetworkProgressBlock)uploadProgress
                     downloadProgress:(nullable JSNetworkProgressBlock)downloadProgress
                       completedBlock:(nullable JSNetworkRequestCompletedBlock)completionBlock {
    NSParameterAssert(config);
    if (self = [super init]) {
        /// 持有一下config, 防止提前释放
        _config = config;
        /// 处理过的请求配置实例
        _processedConfig = (id<JSNetworkRequestConfigProtocol>)[JSNetworkRequestConfigProxy proxyWithTarget:config];
        JSNetworkConfig *sharedConfig = JSNetworkConfig.sharedConfig;
        /// 请求实例
        if ([config respondsToSelector:@selector(request)]) {
            _request = config.request;
        } else if (sharedConfig.buildNetworkRequest) {
            _request = sharedConfig.buildNetworkRequest(self);
        }
        NSAssert(_request, @"请设置request");
        /// 响应实例
        if ([config respondsToSelector:@selector(response)]) {
            _response = config.response;
        } else if (sharedConfig.buildNetworkResponse) {
            _response = sharedConfig.buildNetworkResponse(self);
        }
        NSAssert(_response, @"请设置response");
        /// 磁盘缓存的实例
        if (_processedConfig.cachePolicy == JSRequestCachePolicyUseCacheDataElseLoad) {
            if ([config respondsToSelector:@selector(diskCache)]) {
                _diskCache = config.diskCache;
            } else if (sharedConfig.buildNetworkDiskCache) {
                _diskCache = sharedConfig.buildNetworkDiskCache(self);
            }
            NSAssert(_diskCache, @"请设置diskCache");
        }
        _completionBlocks = [NSMutableArray array];
        /// 回调函数
        [self requestUploadProgress:uploadProgress];
        [self requestDownloadProgress:downloadProgress];
        [self requestCompletedBlock:completionBlock];
        /// 生成任务ID
        static NSUInteger jsNetworkRequestTaskIdentifier = 0;
        [JSNetworkSpinLock execute:^{
            jsNetworkRequestTaskIdentifier = jsNetworkRequestTaskIdentifier + 1;
            _taskIdentifier = [NSString stringWithFormat:@"%@_%@", @"task", @(jsNetworkRequestTaskIdentifier)];
        }];
    }
    return self;
}

- (void)requestUploadProgress:(nullable JSNetworkProgressBlock)uploadProgress {
    _uploadProgress = uploadProgress;
}

- (void)requestDownloadProgress:(nullable JSNetworkProgressBlock)downloadProgress {
    _downloadProgress = downloadProgress;
}

- (void)requestCompletedBlock:(nullable JSNetworkRequestCompletedBlock)completionBlock {
    if (completionBlock) {
        [_completionBlocks addObject:completionBlock];
    }
}

- (void)clearAllCallBack {
    [_completionBlocks removeAllObjects];
    _uploadProgress = nil;
    _downloadProgress = nil;
}

- (NSString *)taskIdentifier {
    return [JSNetworkSpinLock executeWithReturnValue:^id{
        return _taskIdentifier;
    }];
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
