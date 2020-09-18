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

- (NSString *)js_URLLastPath {
    NSURL *URL = [NSURL URLWithString:self];
    return URL.lastPathComponent;
}

- (NSString *)js_URLByDeletingLastPath {
    NSURL *URL = [NSURL URLWithString:self];
    NSString *absoluteString = URL.URLByDeletingLastPathComponent.absoluteString;
    if ([absoluteString containsString:@"?"]) {
        absoluteString = [absoluteString componentsSeparatedByString:@"?"].firstObject;
    }
    return absoluteString;
}

- (NSArray<NSString *> *)js_URLPaths {
    NSURL *URL = [NSURL URLWithString:self];
    return URL.pathComponents;
}

#pragma mark - 拼接URL

- (NSString *)js_URLStringByAppendingParameters:(NSDictionary *)parameters {
    return [self js_URLStringByAppendingPaths:@[] parameters:parameters];
}

- (NSString *)js_URLStringByAppendingPaths:(NSArray<NSString *> *)paths {
    return [self js_URLStringByAppendingPaths:paths parameters:@{}];
}

- (NSString *)js_URLStringByAppendingPaths:(NSArray<NSString *> *)paths parameters:(NSDictionary *)parameters {
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
    NSMutableDictionary *newParameters = [NSMutableDictionary dictionaryWithDictionary:[NSDictionary js_URLQueryDictionaryWithURLString:query]];
    [newParameters addEntriesFromDictionary:parameters ? : @{}];
    if (newParameters.count > 0) {
        newUrl = [newUrl stringByAppendingFormat:@"?%@", newParameters.js_URLQueryString];
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
