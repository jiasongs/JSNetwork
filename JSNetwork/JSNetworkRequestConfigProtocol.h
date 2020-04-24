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

typedef NS_ENUM(NSInteger, JSRequestMethod) {
    JSRequestMethodGET,
    JSRequestMethodPOST,
};

typedef NS_ENUM(NSInteger, JSRequestSerializerType) {
    JSRequestSerializerTypeJSON,      /// POST时Body转换为JSON字符串传输
    JSRequestSerializerTypeFormData,  /// POST时Body转换为FormData传输
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
 *  @brief URL中需要拼接的参数
 */
- (nullable NSDictionary *)requestArgument;

/**
 *  @brief request中的HTTPBody
 */
- (nullable id)requestBody;

/**
 *  @brief 请求方式GET/POST
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
 *  @brief 请求超时时间
 */
- (NSTimeInterval)requestTimeoutInterval;

/**
 *  @brief 请求头
 */
- (nullable NSDictionary<NSString *, NSString *> *)requestHeaderFieldValueDictionary;

/**
 *  @brief 筛选URL
 *
 *  @param URL 需要筛选的URL
 *
 *  @return 返回新的URL
 */
- (NSString *)requestUrlFilterWithURL:(NSString *)URL;

/**
 *  @brief 请求类的Class，继承于NSOperation
 */
- (Class<JSNetworkRequestProtocol>)requestClass;

/**
 *  @brief 响应类的Class
 */
- (Class<JSNetworkResponseProtocol>)responseClass;

/**
 *  @brief 插件
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
- (BOOL)cacheIsSavedWithResponse:(id<JSNetworkResponseProtocol>)response;

/**
 *  @brief 缓存的文件夹路径
 */
- (NSString *)cacheDirectoryPath;


@end

NS_ASSUME_NONNULL_END
