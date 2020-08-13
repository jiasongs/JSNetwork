//
//  NSDictionary+JSURL.m
//  JSNetwork
//
//  Created by jiasong on 2020/4/19.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import "NSDictionary+JSURL.h"
#import "NSString+JSURL.h"

@implementation NSDictionary (JSURL)

+ (NSDictionary *)js_URLQueryDictionaryWithURLString:(NSString *)URLString {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (URLString && URLString.length > 0) {
        NSString *totalUrl = [URLString stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
        NSRange range = [totalUrl rangeOfString:@"^[a-zA-Z0-9]+?://" options:NSRegularExpressionSearch];
        if (range.location == NSNotFound || range.location != 0) {
            totalUrl = [@"https://host" stringByAppendingFormat:@"?%@", totalUrl];
        }
        NSURLComponents *components = [NSURLComponents componentsWithString:totalUrl];
        [components.queryItems enumerateObjectsUsingBlock:^(NSURLQueryItem *queryItem, NSUInteger idx, BOOL *stop) {
            [dict setObject:queryItem.value ? : @"" forKey:queryItem.name];
        }];
    }
    return dict.copy;
}

- (NSString *)js_URLQueryString {
    NSMutableString *string = [NSMutableString string];
    for (NSString *key in [self allKeys]) {
        if (string.length > 0) {
            [string appendString:@"&"];
        }
        NSString *description = [[self objectForKey:key] description];
        NSString *encode = description.js_URLStringDecode.js_URLStringEncode;
        [string appendFormat:@"%@=%@", key, encode];
    }
    return string.copy;
}

@end
