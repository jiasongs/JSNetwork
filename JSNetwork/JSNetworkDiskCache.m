//
//  JSNetworkDiskCache.m
//  AFNetworking
//
//  Created by jiasong on 2020/4/22.
//

#import "JSNetworkDiskCache.h"
#import "JSNetworkInterfaceProtocol.h"
#import "JSNetworkDiskCacheMetadata.h"
#import "JSNetworkResponseProtocol.h"
#import "JSNetworkUtil.h"

@interface JSNetworkDiskCache ()

@property (nonatomic, strong) dispatch_queue_t processingQueue;
@property (nonatomic, strong) dispatch_semaphore_t lock;

@end

@implementation JSNetworkDiskCache

- (instancetype)init {
    if (self = [super init]) {
        _processingQueue = dispatch_queue_create("com.jsnetwork.cache.queue", DISPATCH_QUEUE_CONCURRENT);
        _lock = dispatch_semaphore_create(1);
    }
    return self;
}

- (void)validCacheForInterface:(id<JSNetworkInterfaceProtocol>)interface completed:(nullable JSNetworkDiskCacheCompleted)completed {
    [self cacheForInterface:interface completed:^(id<JSNetworkDiskCacheMetadataProtocol> metadata) {
        if (metadata) {
            @autoreleasepool {
                /// Date
                id<JSNetworkDiskCacheMetadataProtocol> resultMetadata = nil;
                NSTimeInterval duration = -[metadata.creationDate timeIntervalSinceNow];
                if (interface.cacheTimeInSeconds > 0 && duration > 0 && duration < interface.cacheTimeInSeconds) {
                    resultMetadata = metadata;
                }
                /// Version
                else if (interface.cacheVersion > 0 && metadata.version == interface.cacheVersion) {
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

- (void)cacheForInterface:(id<JSNetworkInterfaceProtocol>)interface completed:(nullable JSNetworkDiskCacheCompleted)completed {
    dispatch_async(_processingQueue, ^{
        [self addLock];
        NSString *filePath = [self cacheFilePathWithInterface:interface];
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
        [self unlock];
    });
}

- (void)setCacheData:(id)cacheData forInterface:(id<JSNetworkInterfaceProtocol>)interface completed:(nullable JSNetworkDiskCacheCompleted)completed {
    dispatch_async(_processingQueue, ^{
        [self addLock];
        BOOL success = [self createCacheDirectoryWithInterface:interface];
        if (success) {
            @autoreleasepool {
                JSNetworkDiskCacheMetadata *metadata = [[JSNetworkDiskCacheMetadata alloc] init];
                metadata.version = interface.cacheVersion;
                metadata.stringEncoding = [JSNetworkUtil stringEncodingWithTextEncodingName:interface.response.originalResponse.textEncodingName];
                metadata.creationDate = NSDate.date;
                metadata.appVersionString = [JSNetworkUtil appVersionString];
                metadata.cacheData = [JSNetworkUtil dataFromObject:cacheData];
                NSString *filePath = [self cacheFilePathWithInterface:interface];
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
        [self unlock];
    });
}

- (NSString *)cacheFilePathWithInterface:(id<JSNetworkInterfaceProtocol>)interface {
    NSString *requestUrl = interface.finalURL;
    NSString *cacheFileName = [JSNetworkUtil md5StringFromString:requestUrl];
    return [[interface.cacheDirectoryPath stringByAppendingPathComponent:cacheFileName] stringByAppendingPathExtension:@"metadata"];
}

- (BOOL)createCacheDirectoryWithInterface:(id<JSNetworkInterfaceProtocol>)interface {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *cacheDirectoryPath = interface.cacheDirectoryPath;
    NSError *error;
    if (![fileManager fileExistsAtPath:cacheDirectoryPath]) {
        [fileManager createDirectoryAtPath:cacheDirectoryPath withIntermediateDirectories:NO attributes:@{} error:&error];
    }
    return !error;
}

- (void)addLock {
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
}

- (void)unlock {
    dispatch_semaphore_signal(_lock);
}

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"JSNetworkDiskCache - 已经释放");
#endif
}

@end
