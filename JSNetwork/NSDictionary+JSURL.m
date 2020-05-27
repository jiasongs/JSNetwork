//
//  NSDictionary+JSURL.m
//  JSNetwork
//
//  Created by jiasong on 2020/4/19.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import "NSDictionary+JSURL.h"
#import "NSString+JSURLCode.h"

@implementation NSDictionary (JSURL)

+ (NSDictionary *)js_dictionaryWithURLQuery:(NSString *)query {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (query && query.length > 0) {
        /// 先使用url query编码
        NSString *totalUrl = [query stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
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

- (NSString *)js_URLQueryString {
    NSMutableString *string = [NSMutableString string];
    for (NSString *key in [self allKeys]) {
        if (string.length > 0) {
            [string appendString:@"&"];
        }
        NSString *value = [[[self objectForKey:key] description] stringByRemovingPercentEncoding];
        NSString *encode = value.js_urlEncode;
        [string appendFormat:@"%@=%@", key, encode];
    }
    return [NSString stringWithString:string];
}

@end
