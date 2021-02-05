//
//  NSString+JSURL.m
//  JSNetwork
//
//  Created by jiasong on 2020/8/6.
//

#import "NSString+JSURL.h"
#import "NSDictionary+JSURL.h"

@implementation NSString (JSURL)

#pragma mark - 工具

- (nullable NSString *)js_URLLastPath {
    return self.js_URLPaths.lastObject;
}

- (NSString *)js_URLByDeletingLastPath {
    if (self.js_URLPaths.count > 0) {
        NSMutableArray *array = [NSMutableArray arrayWithArray:[self componentsSeparatedByString:@"/"]];
        [array removeLastObject];
        return [array componentsJoinedByString:@"/"];
    }
    return self;
}

- (NSArray<NSString *> *)js_URLPaths {
    NSURLComponents *components = [NSURLComponents componentsWithString:[self stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet]];
    NSString *path = components.path ? : @"";
    NSMutableArray<NSString *> *paths = [NSMutableArray arrayWithArray:[path componentsSeparatedByString:@"/"]];
    if (paths.count > 0 && paths.firstObject.length == 0) {
        [paths removeObjectAtIndex:0];
    }
    return paths;
}

- (NSDictionary<NSString *, NSString *> *)js_URLParameters {
    NSMutableDictionary<NSString *, NSString *> *dict = [NSMutableDictionary dictionary];
    if (self.length > 0) {
        NSString *totalUrl = [self stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
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

#pragma mark - 拼接URL

- (NSString *)js_URLStringByAppendingParameters:(NSDictionary<NSString *, id> *)parameters {
    return [self js_URLStringByAppendingPaths:@[] parameters:parameters];
}

- (NSString *)js_URLStringByAppendingPaths:(NSArray<NSString *> *)paths {
    return [self js_URLStringByAppendingPaths:paths parameters:@{}];
}

- (NSString *)js_URLStringByAppendingPaths:(NSArray<NSString *> *)paths parameters:(NSDictionary<NSString *, id> *)parameters {
    NSURLComponents *components = [NSURLComponents componentsWithString:[self stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet]];
    NSString *scheme = components.scheme ? [NSString stringWithFormat:@"%@://", components.scheme] : @"";
    NSString *host = components.host ? : @"";
    NSString *port = components.port ? [NSString stringWithFormat:@":%@", components.port] : @"";
    NSString *path = components.path ? : @"";
    NSString *query = components.query ? : @"";
    NSMutableArray *encodePaths = [NSMutableArray arrayWithCapacity:paths.count];
    for (NSString *item in paths) {
        [encodePaths addObject:item.js_URLStringDecode.js_URLStringEncode];
    }
    NSString *newPath = encodePaths.count > 0 ? [path stringByAppendingFormat:@"/%@", [encodePaths componentsJoinedByString:@"/"]] : path;
    NSString *newUrl = [NSString stringWithFormat:@"%@%@%@%@", scheme, host, port, newPath];
    NSMutableDictionary<NSString *, id> *newParameters = [NSMutableDictionary dictionaryWithDictionary:query.js_URLParameters];
    [newParameters addEntriesFromDictionary:parameters ? : @{}];
    if (newParameters.count > 0) {
        newUrl = [newUrl stringByAppendingFormat:@"?%@", newParameters.js_URLParameterString];
    }
    return newUrl;
}

#pragma mark - 编码

- (NSString *)js_URLStringEncode {
    return [self js_URLStringEncodeUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)js_URLStringEncodeUsingEncoding:(NSStringEncoding)encoding {
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
    NSString *resultString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                                   (__bridge CFStringRef)self,
                                                                                                   NULL,
                                                                                                   (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                                                                   CFStringConvertNSStringEncodingToEncoding(encoding)));
    return resultString ? : self;
#pragma clang diagnostic pop
}

#pragma mark - 解码

- (NSString *)js_URLStringDecode {
    return [self js_URLStringDecodeUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)js_URLStringDecodeUsingEncoding:(NSStringEncoding)encoding {
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
    NSString *resultString = (NSString *)CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,
                                                                                                                   (__bridge CFStringRef)self,
                                                                                                                   CFSTR(""),
                                                                                                                   CFStringConvertNSStringEncodingToEncoding(encoding)));
    return resultString ? : self;
#pragma clang diagnostic pop
}

@end
