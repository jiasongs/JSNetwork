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
#import "JSNetworkMutexLock.h"
#import <os/lock.h>

@interface JSNetworkDiskCache () {
    os_unfair_lock _lock;
}

@property (nonatomic, strong) NSString *taskIdentifier;
@property (nonatomic, strong) dispatch_queue_t processingQueue;

@end

@implementation JSNetworkDiskCache

- (instancetype)init {
    if (self = [super init]) {
        _processingQueue = dispatch_queue_create("com.jsnetwork.cache.queue", DISPATCH_QUEUE_CONCURRENT);
        _lock = OS_UNFAIR_LOCK_INIT;
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
    dispatch_async(_processingQueue, ^{
        [self addLock];
        @autoreleasepool {
            NSString *filePath = [self cacheFilePathWithRequestConfig:config];
            if ([NSFileManager.defaultManager fileExistsAtPath:filePath]) {
                JSNetworkDiskCacheMetadata *metadata = nil;
                if (@available(iOS 11.0, *)) {
                    NSData *data = [NSData dataWithContentsOfFile:filePath];
                    metadata = [NSKeyedUnarchiver unarchivedObjectOfClass:JSNetworkDiskCacheMetadata.class
                                                                 fromData:data
                                                                    error:NULL];
                } else {
                    @try {
                        metadata = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
                    } @catch (NSException *exception) {
                        NSLog(@"NSKeyedUnarchiver unarchive failed with exception: %@", exception);
                    }
                }
                if (completed) {
                    completed(metadata);
                }
            } else {
                if (completed) {
                    completed(nil);
                }
            }
        }
        [self unLock];
    });
}

- (void)setCacheData:(id)cacheData
    forRequestConfig:(id<JSNetworkRequestConfigProtocol>)config
           completed:(nullable JSNetworkDiskCacheCompleted)completed {
    dispatch_async(_processingQueue, ^{
        [self addLock];
        @autoreleasepool {
            BOOL success = [self createCacheDirectoryWithRequestConfig:config];
            if (success) {
                JSNetworkDiskCacheMetadata *metadata = [[JSNetworkDiskCacheMetadata alloc] init];
                metadata.version = config.cacheVersion;
                metadata.creationDate = NSDate.date;
                metadata.appVersionString = [JSNetworkUtil appVersionString];
                metadata.cacheData = [JSNetworkUtil dataFromObject:cacheData];
                NSString *filePath = [self cacheFilePathWithRequestConfig:config];
                if (@available(iOS 11.0, *)) {
                    NSData *newData = [NSKeyedArchiver archivedDataWithRootObject:metadata requiringSecureCoding:YES error:NULL];
                    [newData writeToFile:filePath atomically:YES];
                } else {
                    @try {
                        [NSKeyedArchiver archiveRootObject:metadata toFile:filePath];
                    } @catch (NSException *exception) {
                        NSLog(@"NSKeyedArchiver archive failed with exception: %@", exception);
                    }
                }
                if (completed) {
                    completed(metadata);
                }
            } else {
                if (completed) {
                    completed(nil);
                }
            }
        }
        [self unLock];
    });
}

- (NSString *)cacheFilePathWithRequestConfig:(id<JSNetworkRequestConfigProtocol>)config {
    return [[config.cacheDirectoryPath stringByAppendingPathComponent:config.cacheFileName] stringByAppendingPathExtension:@"metadata"];
}

- (BOOL)createCacheDirectoryWithRequestConfig:(id<JSNetworkRequestConfigProtocol>)config {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *cacheDirectoryPath = config.cacheDirectoryPath;
    NSError *error = nil;
    BOOL result = YES;
    if (![fileManager fileExistsAtPath:cacheDirectoryPath]) {
        result = [fileManager createDirectoryAtPath:cacheDirectoryPath withIntermediateDirectories:NO attributes:@{} error:&error];
    }
    return result && !error;
}

- (void)addLock {
    os_unfair_lock_lock(&_lock);
}

- (void)unLock {
    os_unfair_lock_unlock(&_lock);
}

- (void)dealloc {
    JSNetworkLog(@"%@ - 已经释放", NSStringFromClass([self class]));
}

@end
