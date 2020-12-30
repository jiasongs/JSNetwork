//
//  NSDictionary+JSURL.h
//  JSNetwork
//
//  Created by jiasong on 2020/4/19.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (JSURL)

/**
 *  @brief  将url参数转换成NSDictionary
 *
 *  @param URLString url或者参数
 *
 *  @return NSDictionary
 */
+ (NSDictionary *)js_URLQueryDictionaryWithURLString:(NSString *)URLString NS_SWIFT_NAME(js_URLQueryDictionary(URLString:));

/**
 *  @brief  将NSDictionary转换成url 参数字符串
 *
 *  @return url 参数字符串
 */
- (NSString *)js_URLQueryString;

@end

NS_ASSUME_NONNULL_END
