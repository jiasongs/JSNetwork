//
//  JSNetworkUtil.m
//  ITHomeClient
//
//  Created by jiasong on 2020/4/20.
//  Copyright © 2020 ruanmei. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#import "JSNetworkUtil.h"
#import "NSDictionary+JSURL.h"
#import "NSString+JSURLCode.h"
#import "JSNetworkConfig.h"

@implementation JSNetworkUtil

@end

@implementation JSNetworkUtil (FilterURL)

+ (NSString *)filterURL:(NSString *)URL withParameter:(NSDictionary *)parameter {
    NSString *finalUrl = URL.js_urlDecode;
    NSDictionary *finalParameters = @{};
    @autoreleasepool {
        NSString *newUrl = URL;
        NSString *newQuery = @"";
        if ([URL containsString:@"?"]) {
            NSArray *array = [URL componentsSeparatedByString:@"?"];
            newUrl = array.firstObject;
            newQuery = array.lastObject;
        }
        NSMutableDictionary *newParameters = [NSMutableDictionary dictionaryWithDictionary:parameter];
        [newParameters addEntriesFromDictionary:[NSDictionary js_dictionaryWithURLQuery:newQuery]];
        finalParameters = newParameters.copy;
        finalUrl = newUrl;
        if (finalParameters.count > 0) {
            finalUrl = [finalUrl stringByAppendingFormat:@"?%@", finalParameters.js_URLQueryString];
        }
    }
    return finalUrl;
}

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
    CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x", outputBuffer[count]];
    }
    return outputString;
}

+ (NSString *)appVersionString {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

@end

@implementation JSNetworkUtil (Logger)

void JSNetworkLog(NSString *format, ...) {
#ifdef DEBUG
    if (!JSNetworkConfig.sharedConfig.debugLogEnabled) {
        return;
    }
    NSString *newFormat = [NSString stringWithFormat:@"JSNetworLog - %@", format];
    va_list argptr;
    va_start(argptr, format);
    NSLogv(newFormat, argptr);
    va_end(argptr);
#endif
}

@end
