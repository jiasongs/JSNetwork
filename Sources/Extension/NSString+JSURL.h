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
 *  @brief  NSURLComponents
 *
 *  @return NSURLComponents
 */
- (NSURLComponents *)js_URLComponents NS_SWIFT_NAME(js_urlComponents());

/**
 *  @brief  获取URL最后一条路径
 *
 *  @return NSString 最后一条路径
 */
- (nullable NSString *)js_URLLastPath NS_SWIFT_NAME(js_urlLastPath());

/**
 *  @brief  删除URL最后一条路径
 *
 *  @return NSString 删除后的URL字符串
 */
- (NSString *)js_URLByDeletingLastPath NS_SWIFT_NAME(js_urlByDeletingLastPath());

/**
 *  @brief  获取URL路径的数组
 *
 *  @return NSArray 路径的数组
 */
- (NSArray<NSString *> *)js_URLPaths NS_SWIFT_NAME(js_urlPaths());

/**
 *  @brief  删除URL的参数
 *
 *  @return NSString 删除后的URL字符串
 */
- (NSString *)js_URLByDeletingParameter NS_SWIFT_NAME(js_urlByDeletingParameter());

/**
 *  @brief  获取URL的参数
 *
 *  @return NSDictionary 参数
 */
- (NSDictionary<NSString *, NSString *> *)js_URLParameters NS_SWIFT_NAME(js_urlParameters());

/**
 *  @brief  将一段URL字符串拼接上参数
 *
 *  @return NSString 拼接后的字符串
 */
- (NSString *)js_URLStringByAppendingParameters:(NSDictionary<NSString *, id> *)parameters NS_SWIFT_NAME(js_urlStringByAppending(parameters:));

/**
 *  @brief  将一段URL字符串拼接上路径
 *
 *  @return NSString 拼接后的字符串
 */
- (NSString *)js_URLStringByAppendingPaths:(NSArray<NSString *> *)paths NS_SWIFT_NAME(js_urlStringByAppending(paths:));

/**
 *  @brief  将一段URL字符串拼接上路径、参数
 *
 *  @return NSString 拼接后的字符串
 */
- (NSString *)js_URLStringByAppendingPaths:(NSArray<NSString *> *)paths parameters:(NSDictionary<NSString *, id> *)parameters NS_SWIFT_NAME(js_urlStringByAppending(paths:parameters:));

/**
 *  @brief  将一段字符串进行URL编码
 *
 *  @return NSString 编码后的字符串
 */
- (NSString *)js_URLStringEncode NS_SWIFT_NAME(js_urlStringEncode());

/**
 *  @brief  将一段字符串进行编码
 *
 *  @param  encoding 编码
 *
 *  @return NSString 编码后的字符串
 */
- (NSString *)js_URLStringEncodeUsingEncoding:(NSStringEncoding)encoding NS_SWIFT_NAME(js_urlStringEncode(usingEncoding:));

/**
 *  @brief  将一段字符串进行URL解码
 *
 *  @return NSString 解码后的字符串
 */
- (NSString *)js_URLStringDecode NS_SWIFT_NAME(js_urlStringDecode());

/**
 *  @brief  将一段字符串进行解码
 *
 *  @param  encoding 解码
 *
 *  @return NSString 解码后的字符串
 */
- (NSString *)js_URLStringDecodeUsingEncoding:(NSStringEncoding)encoding NS_SWIFT_NAME(js_urlStringDecode(usingEncoding:));

@end

NS_ASSUME_NONNULL_END
