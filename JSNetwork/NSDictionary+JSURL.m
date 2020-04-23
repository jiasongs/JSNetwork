//
//  NSDictionary+JSURL.m
//  JSNetwork
//
//  Created by jiasong on 2020/4/19.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import "NSDictionary+JSURL.h"

@implementation NSDictionary (JSURL)

/**
 *  @brief  将url参数转换成NSDictionary
 *
 *  @param query url参数
 *
 *  @return NSDictionary
 */
+ (NSDictionary *)js_dictionaryWithURLQuery:(NSString *)query {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (query && query.length > 0) {
        /// 先使用url query编码
        NSString *totalUrl = [query stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        if (![totalUrl hasPrefix:@"http"]) {
            totalUrl = [@"https://host" stringByAppendingFormat:@"?%@", totalUrl];
        }
        NSURLComponents *components = [NSURLComponents componentsWithString:totalUrl];
        [components.queryItems enumerateObjectsUsingBlock:^(NSURLQueryItem *queryItem, NSUInteger idx, BOOL *stop) {
            if (queryItem.value) {
                /// 解除url query编码
                NSString *value = [queryItem.value stringByRemovingPercentEncoding];
                [dict setObject:value forKey:queryItem.name];
            }
        }];
    }
    return [NSDictionary dictionaryWithDictionary:dict];
}

/**
 *  @brief  将NSDictionary转换成url 参数字符串
 *
 *  @return url 参数字符串
 */
- (NSString *)js_URLQueryString {
    NSMutableString *string = [NSMutableString string];
    for (NSString *key in [self allKeys]) {
        if ([string length]) {
            [string appendString:@"&"];
        }
        NSString *value = [[[self objectForKey:key] description] stringByRemovingPercentEncoding];
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
        CFStringRef escaped = CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)value,
                                                                      NULL,(CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                      kCFStringEncodingUTF8);
#pragma clang diagnostic pop
        [string appendFormat:@"%@=%@", key, escaped];
        CFRelease(escaped);
    }
    return [NSString stringWithString:string];
}

@end
