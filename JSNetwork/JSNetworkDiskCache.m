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

@property (nonatomic, strong) NSString *taskIdentifier;
@property (nonatomic, strong) dispatch_queue_t processingQueue;
@property (nonatomic, strong) dispatch_semaphore_t lock;
@property (nonatomic, copy) id testBlockSave;
@property (nonatomic, copy) id testBlockValid;
@property (nonatomic, copy) id testBlockGet;

@end

@implementation JSNetworkDiskCache

- (instancetype)init {
    if (self = [super init]) {
        _processingQueue = dispatch_queue_create("com.jsnetwork.cache.queue", DISPATCH_QUEUE_CONCURRENT);
        _lock = dispatch_semaphore_create(1);
    }
    return self;
}

static NSUInteger JSNetworkDiskCache_TaskIdentifier = 0;
- (void)buildTaskWithRequestConfig:(id<JSNetworkRequestConfigProtocol>)config {
    @synchronized (self) {
        JSNetworkDiskCache_TaskIdentifier = JSNetworkDiskCache_TaskIdentifier + 1;
        _taskIdentifier = [@"cache_task" stringByAppendingFormat:@"%@", @(JSNetworkDiskCache_TaskIdentifier)];
    }
}

- (NSString *)taskIdentifier {
    @synchronized (self) {
        return _taskIdentifier;
    }
}

- (void)validCacheForRequestConfig:(id<JSNetworkRequestConfigProtocol>)config
                         completed:(nullable JSNetworkDiskCacheCompleted)completed {
    //    self.testBlockValid = completed;
    [self cacheForRequestConfig:config
                      completed:^(id<JSNetworkDiskCacheMetadataProtocol> metadata) {
        if (metadata) {
            @autoreleasepool {
                NSLog(@"%@", @(config.cacheVersion));
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
                if (completed) {
                    completed(resultMetadata);
                }
            }
        } else {
            if (completed) {
                completed(nil);
            }
        }
    }];
}

- (void)cacheForRequestConfig:(id<JSNetworkRequestConfigProtocol>)config
                    completed:(nullable JSNetworkDiskCacheCompleted)completed {
    //    self.testBlockGet = completed;
    dispatch_async(_processingQueue, ^{
        [self addLock];
        NSString *filePath = [self cacheFilePathWithRequestConfig:config];
        if ([NSFileManager.defaultManager fileExistsAtPath:filePath]) {
            @autoreleasepool {
                JSNetworkDiskCacheMetadata *metadata = nil;
                if (@available(iOS 11.0, *)) {
                    NSData *data = [NSData dataWithContentsOfFile:filePath];
                    metadata = [NSKeyedUnarchiver unarchivedObjectOfClass:JSNetworkDiskCacheMetadata.class
                                                                 fromData:data
                                                                    error:NULL];
                } else {
                    metadata = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
                }
                if (completed) {
                    completed(metadata);
                }
            }
        } else {
            if (completed) {
                completed(nil);
            }
        }
        [self unLock];
    });
}

- (void)setCacheData:(id)cacheData
    forRequestConfig:(id<JSNetworkRequestConfigProtocol>)config
           completed:(nullable JSNetworkDiskCacheCompleted)completed {
    self.testBlockSave = completed;
    dispatch_async(_processingQueue, ^{
        [self addLock];
        BOOL success = [self createCacheDirectoryWithRequestConfig:config];
        if (success) {
            @autoreleasepool {
                JSNetworkDiskCacheMetadata *metadata = [[JSNetworkDiskCacheMetadata alloc] init];
                metadata.version = config.cacheVersion;
                metadata.creationDate = NSDate.date;
                metadata.appVersionString = [JSNetworkUtil appVersionString];
                metadata.cacheData = [JSNetworkUtil dataFromObject:cacheData];
                NSString *filePath = [self cacheFilePathWithRequestConfig:config];
                if (@available(iOS 11.0, *)) {
                    NSData *newData = [NSKeyedArchiver archivedDataWithRootObject:metadata requiringSecureCoding:YES error:NULL];
                    [newData writeToFile:filePath atomically:true];
                } else {
                    [NSKeyedArchiver archiveRootObject:metadata toFile:filePath];
                }
                if (completed) {
                    completed(metadata);
                }
            }
        } else {
            if (completed) {
                completed(nil);
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
    NSError *error;
    if (![fileManager fileExistsAtPath:cacheDirectoryPath]) {
        [fileManager createDirectoryAtPath:cacheDirectoryPath withIntermediateDirectories:NO attributes:@{} error:&error];
    }
    return !error;
}

- (void)addLock {
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
}

- (void)unLock {
    dispatch_semaphore_signal(_lock);
}

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"JSNetworkDiskCache - 已经释放");
#endif
}

@end
