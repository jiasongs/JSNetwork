//
//  NSString+JSURL.h
//  JSNetwork
//
//  Created by jiasong on 2020/8/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (JSURL)

/**
 *  @brief  获取URL最后一条路径
 *
 *  @return NSString 最后一条路径
 */
- (nullable NSString *)js_URLLastPath;

/**
 *  @brief  删除URL最后一条路径
 *
 *  @return NSString 删除后的URL字符串
 */
- (NSString *)js_URLByDeletingLastPath;

/**
 *  @brief  获取URL路径的数组
 *
 *  @return NSArray 路径的数组
 */
- (NSArray<NSString *> *)js_URLPaths;

/**
 *  @brief  获取URL的参数
 *
 *  @return NSDictionary 参数
 */
- (NSDictionary<NSString *, NSString *> *)js_URLParameters;

/**
 *  @brief  将一段URL字符串拼接上参数
 *
 *  @return NSString 拼接后的字符串
 */
- (NSString *)js_URLStringByAppendingParameters:(NSDictionary *)parameters NS_SWIFT_NAME(js_URLStringByAppending(parameters:));

/**
 *  @brief  将一段URL字符串拼接上路径
 *
 *  @return NSString 拼接后的字符串
 */
- (NSString *)js_URLStringByAppendingPaths:(NSArray<NSString *> *)paths NS_SWIFT_NAME(js_URLStringByAppending(paths:));

/**
 *  @brief  将一段URL字符串拼接上路径、参数
 *
 *  @return NSString 拼接后的字符串
 */
- (NSString *)js_URLStringByAppendingPaths:(NSArray<NSString *> *)paths parameters:(NSDictionary *)parameters NS_SWIFT_NAME(js_URLStringByAppending(paths:parameters:));

/**
 *  @brief  将一段字符串进行URL编码
 *
 *  @return NSString 编码后的字符串
 */
- (NSString *)js_URLStringEncode;

/**
 *  @brief  将一段字符串进行编码
 *
 *  @param  encoding 编码
 *
 *  @return NSString 编码后的字符串
 */
- (NSString *)js_URLStringEncodeUsingEncoding:(NSStringEncoding)encoding NS_SWIFT_NAME(js_URLStringEncode(usingEncoding:));

/**
 *  @brief  将一段字符串进行URL解码
 *
 *  @return NSString 解码后的字符串
 */
- (NSString *)js_URLStringDecode;

/**
 *  @brief  将一段字符串进行解码
 *
 *  @param  encoding 解码
 *
 *  @return NSString 解码后的字符串
 */
- (NSString *)js_URLStringDecodeUsingEncoding:(NSStringEncoding)encoding NS_SWIFT_NAME(js_URLStringDecode(usingEncoding:));

@end

NS_ASSUME_NONNULL_END
