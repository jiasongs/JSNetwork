//
//  NSString+JSURLCode.m
//  JSNetwork
//
//  Created by jiasong on 2020/4/19.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import "NSString+JSURLCode.h"

@implementation NSString (JSURLCode)

- (NSString *)js_urlEncode {
    return [self js_urlEncodeUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)js_urlEncodeUsingEncoding:(NSStringEncoding)encoding {
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

- (NSString *)js_urlDecode {
    return [self js_urlDecodeUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)js_urlDecodeUsingEncoding:(NSStringEncoding)encoding {
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
