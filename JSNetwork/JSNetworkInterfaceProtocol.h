//
//  JSNetworkInterfaceProtocol.h
//  ITHomeClient
//
//  Created by jiasong on 2020/4/20.
//  Copyright © 2020 ruanmei. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol JSNetworkRequestConfigProtocol;
@protocol JSNetworkResponseProtocol;
@protocol JSNetworkRequestProtocol;
@protocol JSNetworkDiskCacheProtocol;

NS_ASSUME_NONNULL_BEGIN

@protocol JSNetworkInterfaceProtocol <NSObject>

@required
/**
 *  @brief 过滤后最终需要请求的URL, 已经拼接好参数所有参数
 */
@property (nonatomic, strong, readonly) NSString *finalURL;
/**
 *  @brief 过滤后URL的参数信息, URL已经拼接, 这里只是返回一下最终的参数
 */
@property (nonatomic, strong, readonly) NSDictionary *finalArguments;
/**
 *  @brief POST请求中携带的HTTPBody
 */
@property (nonatomic, strong, readonly) id finalHTTPBody;
/**
 *  @brief 请求方式GET/POST
 */
@property (nonatomic, strong, readonly) NSString *HTTPMethod;
/**
 *  @brief 请求头
 */
@property (nonatomic, strong, readonly) NSDictionary *HTTPHeaderFields;
/**
 *  @brief 设置超时时间
 */
@property (nonatomic, assign, readonly) NSTimeInterval timeoutInterval;
/**
 *  @brief 全部插件
 */
@property (nonatomic, strong, readonly) NSArray *allPlugins;
/**
 *  @brief 缓存类的实例
 */
@property (nonatomic, strong, readonly) id<JSNetworkDiskCacheProtocol> diskCache;
/**
 *  @brief 是否缓存
 */
@property (nonatomic, assign, readonly) BOOL cacheIgnore;
/**
 *  @brief 缓存版本
 */
@property (nonatomic, assign, readonly) long long cacheVersion;
/**
 *  @brief 缓存时间
 */
@property (nonatomic, assign, readonly) NSInteger cacheTimeInSeconds;
/**
 *  @brief 缓存的文件夹路径
 */
@property (nonatomic, strong, readonly) NSString *cacheDirectoryPath;
/**
 *  @brief 请求类
 */
@property (nonatomic, strong, readonly) __kindof NSOperation<JSNetworkRequestProtocol> *request;
/**
 *  @brief 响应类
 */
@property (nonatomic, strong, readonly) id<JSNetworkResponseProtocol> response;
/**
 *  @brief 原始的请求配置类
 */
@property (nonatomic, strong, readonly) id<JSNetworkRequestConfigProtocol> originalConfig;

/**
 *  @brief 根据config初始化一个Interface
 *
 *  @param config JSNetworkRequestConfigProtocol
 */
- (instancetype)initWithRequestConfig:(id<JSNetworkRequestConfigProtocol>)config;

@end

NS_ASSUME_NONNULL_END
