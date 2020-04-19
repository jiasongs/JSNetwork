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
 *  @brief 响应类的Class
*/
- (Class<JSNetworkResponseProtocol>)responseClass;

/**
 *  @brief 插件
*/
- (NSArray<id<JSNetworkPluginProtocol>> *)requestPlugins;

@end

NS_ASSUME_NONNULL_END
