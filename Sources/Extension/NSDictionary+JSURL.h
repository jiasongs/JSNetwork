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
 *  @brief  将Dictionary转换成已编码的参数字符串
 *
 *  @return url 参数字符串
 */
- (NSString *)js_URLParameterString NS_SWIFT_NAME(js_urlParameterString());

@end

NS_ASSUME_NONNULL_END
