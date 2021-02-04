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

- (NSString *)js_URLParameterString {
    NSMutableString *string = [NSMutableString string];
    for (NSString *key in self.allKeys) {
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
