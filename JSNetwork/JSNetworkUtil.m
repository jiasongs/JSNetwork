//
//  JSNetworkUtil.m
//  ITHomeClient
//
//  Created by jiasong on 2020/4/20.
//  Copyright © 2020 ruanmei. All rights reserved.
//

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

@implementation JSNetworkUtil (Logger)

void JSNetworkLog(NSString *format, ...) {
#ifdef DEBUG
    if (!JSNetworkConfig.sharedInstance.debugLogEnabled) {
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
