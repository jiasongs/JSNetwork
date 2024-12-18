//
//  JSNetworkDiskCache.m
//  JSNetwork
//
//  Created by jiasong on 2020/4/22.
//

#import "JSNetworkDiskCache.h"
#import "JSNetworkRequestConfigProtocol.h"
#import "JSNetworkDiskCacheMetadata.h"
#import "JSNetworkUtil.h"

@interface JSNetworkDiskCache ()

@property (nonatomic) dispatch_queue_t ioQueue;

@end

@implementation JSNetworkDiskCache

- (instancetype)init {
    if (self = [super init]) {
        _ioQueue = dispatch_queue_create("com.jsnetwork.cache.io.queue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)buildTaskWithConfig:(id<JSNetworkRequestConfigProtocol>)config
               didCompleted:(JSNetworkDiskCacheCompleted)didCompletedBlock {
    [self cacheForRequestConfig:config
                      completed:^(id<JSNetworkDiskCacheMetadataProtocol> metadata) {
        if (metadata) {
            /// 时间
            id<JSNetworkDiskCacheMetadataProtocol> resultMetadata = nil;
            NSTimeInterval duration = -[metadata.creationDate timeIntervalSinceNow];
            if (config.cacheTimeInSeconds > 0 && duration > 0 && duration < config.cacheTimeInSeconds) {
                resultMetadata = metadata;
            }
            /// 版本
            else if (config.cacheVersion > 0 && metadata.version == config.cacheVersion) {
                resultMetadata = metadata;
            }
            /// TODO: App version
            if (didCompletedBlock) {
                didCompletedBlock(resultMetadata);
            }
        } else {
            if (didCompletedBlock) {
                didCompletedBlock(nil);
            }
        }
    }];
}

- (void)cacheForRequestConfig:(id<JSNetworkRequestConfigProtocol>)config
                    completed:(nullable JSNetworkDiskCacheCompleted)completed {
    dispatch_async(self.ioQueue, ^{
        JSNetworkDiskCacheMetadata *metadata = nil;
        NSString *filePath = [self cacheFilePathWithRequestConfig:config];
        if ([NSFileManager.defaultManager fileExistsAtPath:filePath]) {
            NSData *data = [NSData dataWithContentsOfFile:filePath];
            metadata = [NSKeyedUnarchiver unarchivedObjectOfClass:JSNetworkDiskCacheMetadata.class
                                                         fromData:data
                                                            error:NULL];
        }
        if (completed) {
            completed(metadata);
        }
    });
}

- (void)setCacheData:(id)cacheData
    forRequestConfig:(id<JSNetworkRequestConfigProtocol>)config
           completed:(nullable JSNetworkDiskCacheCompleted)completed {
    dispatch_async(self.ioQueue, ^{
        BOOL success = [self createCacheDirectoryWithRequestConfig:config];
        if (success) {
            JSNetworkDiskCacheMetadata *metadata = [[JSNetworkDiskCacheMetadata alloc] init];
            metadata.version = config.cacheVersion;
            metadata.creationDate = NSDate.date;
            metadata.appVersionString = [JSNetworkUtil appVersionString];
            metadata.cacheData = [JSNetworkUtil dataFromObject:cacheData];
            NSString *filePath = [self cacheFilePathWithRequestConfig:config];
            NSData *newData = [NSKeyedArchiver archivedDataWithRootObject:metadata requiringSecureCoding:YES error:NULL];
            [newData writeToFile:filePath atomically:YES];
            if (completed) {
                completed(metadata);
            }
        } else {
            if (completed) {
                completed(nil);
            }
        }
    });
}

- (NSString *)cacheFilePathWithRequestConfig:(id<JSNetworkRequestConfigProtocol>)config {
    return [[config.cacheDirectoryPath stringByAppendingPathComponent:config.cacheFileName] stringByAppendingPathExtension:@"metadata"];
}

- (BOOL)createCacheDirectoryWithRequestConfig:(id<JSNetworkRequestConfigProtocol>)config {
    NSString *cacheDirectoryPath = config.cacheDirectoryPath;
    NSError *error = nil;
    BOOL result = YES;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:cacheDirectoryPath]) {
        result = [fileManager createDirectoryAtPath:cacheDirectoryPath withIntermediateDirectories:NO attributes:@{} error:&error];
    }
    return result && !error;
}

- (void)dealloc {
    JSNetworkLog(@"%@ - 已经释放", NSStringFromClass([self class]));
}

@end
