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
    JSRequestMethodGET     NS_SWIFT_NAME(get),
    JSRequestMethodPOST    NS_SWIFT_NAME(post),
    JSRequestMethodHEAD    NS_SWIFT_NAME(head),
    JSRequestMethodPUT     NS_SWIFT_NAME(put),
    JSRequestMethodDELETE  NS_SWIFT_NAME(delete),
    JSRequestMethodPATCH   NS_SWIFT_NAME(patch),
};

typedef NS_ENUM(NSInteger, JSRequestSerializerType) {
    JSRequestSerializerTypeJSON        NS_SWIFT_NAME(json),  /// POST时Body转换为JSON字符串传输
    JSRequestSerializerTypeHTTP        NS_SWIFT_NAME(http),  /// POST时Body转换为自定义的字符串传输
    JSRequestSerializerTypeFormData    NS_SWIFT_NAME(formData),  /// POST时Body转换为FormData传输
    JSRequestSerializerTypeBinaryData  NS_SWIFT_NAME(binaryData),  /// POST时Body转换为二进制数据传输
};

typedef NS_ENUM(NSInteger, JSRequestCachePolicy) {
    JSRequestCachePolicyIgnoringCacheData = 0,      /// 忽略本地缓存, 直接从后台请求数据
    JSRequestCachePolicyUseCacheDataElseLoad = 1,   /// 若缓存存在则使用缓存, 否则从后台请求数据
};

typedef NS_ENUM(NSInteger, JSResponseSerializerType) {
    JSResponseSerializerTypeJSON       NS_SWIFT_NAME(json),
    JSResponseSerializerTypeHTTP       NS_SWIFT_NAME(http),
    JSResponseSerializerTypeXMLParser  NS_SWIFT_NAME(xmlParser),
};

NS_ASSUME_NONNULL_BEGIN

@protocol JSNetworkRequestConfigProtocol <NSObject>

@required

/**
 *  @brief URLString
 */
- (NSString *)requestURLString NS_SWIFT_NAME(requestUrlString());

@optional

/**
 *  @brief BaseURLString
 */
- (NSString *)baseURLString NS_SWIFT_NAME(baseUrlString());

/**
 *  @brief URL中需要拼接的路径
 */
- (nullable NSArray<NSString *> *)requestPaths;

/**
 *  @brief URL中需要拼接的参数, 注意：会拼接上全局的设置
 */
- (nullable NSDictionary<NSString *, id> *)requestParameters;

/**
 *  @brief 需要忽略的全局设置的参数
 */
- (nullable NSArray<NSString *> *)ignoreGlobalParameterForKeys;

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
 *  @brief 筛选URL
 *
 *  @param URLString 需要筛选的URL
 *
 *  @return 返回新的URL
 */
- (NSString *)requestURLStringFilterWithURLString:(NSString *)URLString NS_SWIFT_NAME(requestUrlFilter(_:));

/**
 *  @brief 拼接FormData
 *
 *  @param multipartFormData 可拼接的FormData, 如果外部使用AFN, 则是AFMultipartFormData
 */
- (void)constructingMultipartFormData:(id)multipartFormData NS_SWIFT_NAME(constructingMultipart(formData:));

/**
 *  @brief 拼接URLRequest
 *
 *  @param urlRequest 可拼接的URLRequest
 */
- (void)constructingMultipartURLRequest:(NSMutableURLRequest *)urlRequest NS_SWIFT_NAME(constructingMultipart(urlRequest:));

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
 *  @brief 缓存策略, 注意并不是<NSURLRequestCachePolicy>
 *
 *  @use 当设置JSRequestCachePolicyUseCacheDataElseLoad时, 则必须设置cacheVersion或者cacheTimeInSeconds
 */
- (JSRequestCachePolicy)cachePolicy;

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
