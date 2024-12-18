//
//  JSNetworkUtil.m
//  JSNetwork
//
//  Created by jiasong on 2020/4/20.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#import "JSNetworkUtil.h"
#import "JSNetworkConfig.h"

@implementation JSNetworkUtil

@end

@implementation JSNetworkUtil (Cache)

+ (NSData *)dataFromObject:(id)object {
    NSData *data = nil;
    if ([object isKindOfClass:NSString.class]) {
        data = [object dataUsingEncoding:NSUTF8StringEncoding];
    } else if ([object isKindOfClass:NSDictionary.class] || [object isKindOfClass:NSArray.class]) {
        data = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:nil];
    } else if ([object isKindOfClass:NSData.class]) {
        data = object;
    }
    return data;
}

+ (NSString *)md5StringFromString:(NSString *)string {
    NSParameterAssert(string != nil && [string length] > 0);
    const char *value = [string UTF8String];
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);
#pragma clang diagnostic pop
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++) {
        [outputString appendFormat:@"%02x", outputBuffer[count]];
    }
    return outputString;
}

+ (NSString *)appVersionString {
    static NSString *_appVersionString;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _appVersionString = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    });
    return _appVersionString;
}

+ (long long)fileSizeAtPath:(NSString *)filePath {
    if (![NSFileManager.defaultManager fileExistsAtPath:filePath]) {
        return 0;
    }
    NSError *error;
    NSDictionary<NSFileAttributeKey, id> *attributes = [NSFileManager.defaultManager attributesOfItemAtPath:filePath error:&error];
    if (attributes && !error) {
        return attributes.fileSize;
    } else {
        return 0;
    }
}

+ (long long)directorySizeAtPath:(NSString *)directoryPath {
    BOOL isDirectory;
    if (![NSFileManager.defaultManager fileExistsAtPath:directoryPath isDirectory:&isDirectory]) {
        return 0;
    }
    if (isDirectory) {
        __block long long folderSize = 0;
        NSError *error;
        NSArray<NSString *> *items = [NSFileManager.defaultManager contentsOfDirectoryAtPath:directoryPath error:&error];
        if (items && !error) {
            [items enumerateObjectsUsingBlock:^(NSString *path, NSUInteger idx, BOOL *stop) {
                NSString *filePath = [directoryPath stringByAppendingPathComponent:path];
                BOOL isDirectoryForSub;
                [NSFileManager.defaultManager fileExistsAtPath:filePath isDirectory:&isDirectoryForSub];
                if (isDirectoryForSub) {
                    folderSize += [self directorySizeAtPath:filePath];
                } else {
                    folderSize += [self fileSizeAtPath:filePath];
                }
            }];
        }
        return folderSize;
    } else {
        return [self fileSizeAtPath:directoryPath];
    }
}

@end

@implementation JSNetworkUtil (Logger)

void JSNetworkLog(NSString *format, ...) {
#ifdef DEBUG
    if (!JSNetworkConfig.sharedConfig.debugLogEnabled) {
        return;
    }
    NSString *result = [NSString stringWithFormat:@"JSNetworLog: %@", format];
    va_list argptr;
    va_start(argptr, format);
    NSLogv(result, argptr);
    va_end(argptr);
#endif
}

@end
