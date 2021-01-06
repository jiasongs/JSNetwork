//
//  JSNetworkRequestConfigProtocol.h
//  JSNetwork
//
//  Created by jiasong on 2020/4/17.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol JSNetworkPluginProtocol;
@protocol JSNetworkRequestProtocol;
@protocol JSNetworkResponseProtocol;
@protocol JSNetworkDiskCacheProtocol;

typedef NS_ENUM(NSInteger, JSRequestMethod) {
    JSRequestMethodGET,
    JSRequestMethodPOST,
    JSRequestMethodHEAD,
    JSRequestMethodPUT,
    JSRequestMethodDELETE,
    JSRequestMethodPATCH,
};

typedef NS_ENUM(NSInteger, JSRequestSerializerType) {
    JSRequestSerializerTypeJSON,        /// POST时Body转换为JSON字符串传输
    JSRequestSerializerTypeHTTP,        /// POST时Body转换为自定义的字符串传输
    JSRequestSerializerTypeFormData,    /// POST时Body转换为FormData传输
    JSRequestSerializerTypeBinaryData,  /// POST时Body转换为二进制数据传输
};

typedef NS_ENUM(NSInteger, JSResponseSerializerType) {
    JSResponseSerializerTypeJSON,
    JSResponseSerializerTypeHTTP,
    JSResponseSerializerTypeXMLParser,
};

NS_ASSUME_NONNULL_BEGIN

@protocol JSNetworkRequestConfigProtocol <NSObject>

@required

/**
 *  @brief URL
 */
- (NSString *)requestUrl;

@optional

/**
 *  @brief BaseURL
 */
- (NSString *)baseUrl;

/**
 *  @brief URL中需要拼接的路径
 */
- (nullable NSArray<NSString *> *)requestPaths;

/**
 *  @brief URL中需要拼接的参数, 注意：会拼接上全局的设置
 */
- (nullable NSDictionary *)requestArgument;

/**
 *  @brief 需要忽略的全局设置的参数
 */
- (nullable NSArray<NSString *> *)ignoreGlobalArgumentForKeys;

/**
 *  @brief request中的HTTPBody
 */
- (nullable id)requestBody;

/**
 *  @brief 请求方式GET/POST, 默认为GET
 */
- (JSRequestMethod)requestMethod;

/**
 *  @brief POST时Body的转换方式，默认JSRequestSerializerTypeJSON
 */
- (JSRequestSerializerType)requestSerializerType;

/**
 *  @brief 响应的数据解析方式，默认为JSResponseSerializerTypeJSON
 */
- (JSResponseSerializerType)responseSerializerType;

/**
 *  @brief 请求超时时间, 默认是全局设置的超时时间
 */
- (NSTimeInterval)requestTimeoutInterval;

/**
 *  @brief 请求头, 默认是全局设置的请求头, 注意：会拼接上全局的设置
 */
- (nullable NSDictionary<NSString *, NSString *> *)requestHeaderFieldValueDictionary;

/**
 *  @brief 拼接FormData
 *
 *  @param multipartFormData 可拼接的FormData, 如果外部使用AFN, 则是AFMultipartFormData
 */
- (void)constructingMultipartFormData:(id)multipartFormData NS_SWIFT_NAME(constructingMultipart(formData:));

/**
 *  @brief 筛选URL
 *
 *  @param URLString 需要筛选的URL
 *
 *  @return 返回新的URL
 */
- (NSString *)requestUrlFilterWithURLString:(NSString *)URLString NS_SWIFT_NAME(requestUrlFilter(URLString:));

/**
 *  @brief 内容类型
 */
- (nullable NSSet<NSString *> *)responseAcceptableContentTypes;

/**
 *  @brief 状态码，默认是100 - 500
 */
- (NSIndexSet *)responseAcceptableStatusCodes;

/**
 *  @brief 请求类，继承于NSOperation, 默认全局设置的request
 */
- (__kindof NSOperation<JSNetworkRequestProtocol> *)request;

/**
 *  @brief 响应类, 默认全局设置的response
 */
- (id<JSNetworkResponseProtocol>)response;

/**
 *  @brief 磁盘缓存类, 默认全局设置的diskCache
 */
- (id<JSNetworkDiskCacheProtocol>)diskCache;

/**
 *  @brief 插件, 默认全局设置的Plugins, 注意：会拼接上全局的设置
 */
- (NSArray<id<JSNetworkPluginProtocol>> *)requestPlugins;

/**
 *  @brief 是否忽略缓存, 默认为true
 *
 *  @use 当设置不忽略缓存时, 则必须设置cacheVersion或者cacheTimeInSeconds
 */
- (BOOL)cacheIgnore;

/**
 *  @brief 缓存版本, 默认是-1
 */
- (long long)cacheVersion;

/**
 *  @brief 缓存时间, 默认是-1
 */
- (NSInteger)cacheTimeInSeconds;

/**
 *  @brief 根据响应最后一次询问是否保存缓存, 默认true
 *
 *  @param response 响应
 */
- (BOOL)cacheIsSavedWithResponse:(id<JSNetworkResponseProtocol>)response NS_SWIFT_NAME(cacheIsSaved(response:));

/**
 *  @brief 缓存的文件名
 */
- (NSString *)cacheFileName;

/**
 *  @brief 缓存的文件夹路径
 */
- (NSString *)cacheDirectoryPath;


@end

NS_ASSUME_NONNULL_END