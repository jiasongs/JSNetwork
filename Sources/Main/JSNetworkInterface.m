
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

FOUNDATION_STATIC_INLINE dispatch_queue_t
JSNetworkTaskIdentifierQueue(void) {
    static dispatch_queue_t queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("com.jsnetwork.task.identifier.queue", DISPATCH_QUEUE_SERIAL);
    });
    return queue;
}

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
        
        /// 回调函数
        _completionBlocks = [NSMutableArray array];
        [self requestUploadProgress:uploadProgress];
        [self requestDownloadProgress:downloadProgress];
        [self requestCompletedBlock:completionBlock];
        
        /// 生成任务ID
        static NSUInteger jsNetworkRequestTaskIdentifier = 0;
        dispatch_sync(JSNetworkTaskIdentifierQueue(), ^{
            jsNetworkRequestTaskIdentifier = jsNetworkRequestTaskIdentifier + 1;
            _taskIdentifier = [NSString stringWithFormat:@"%@_%@", @"task", @(jsNetworkRequestTaskIdentifier)];
        });
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
    __block NSString *taskIdentifier;
    dispatch_sync(JSNetworkTaskIdentifierQueue(), ^{
        taskIdentifier = _taskIdentifier;
    });
    return taskIdentifier;
}

- (NSString *)description {
#ifdef DEBUG
    NSDictionary *config = [NSJSONSerialization JSONObjectWithData:[JSNetworkUtil dataFromObject:self.processedConfig.description] options:NSJSONReadingMutableContainers error:nil];
    NSDictionary *value = @{
        @"request": [config isKindOfClass:NSDictionary.class] ? config : @{},
        @"response": @{
            @"statusCode": @(self.response.responseStatusCode),
            @"error": self.response.error ? : @""
        },
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

- (void)dealloc {
    JSNetworkLog(@"%@ - 已经释放", NSStringFromClass([self class]));
    JSNetworkLog(@"%@ - 已经释放", NSStringFromClass([_config class]));
}

@end
