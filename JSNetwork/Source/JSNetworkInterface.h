//
//  JSNetworkInterface.h
//  JSNetwork
//
//  Created by jiasong on 2020/4/18.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol JSNetworkRequestConfigProtocol;
@protocol JSNetworkResponseProtocol;

NS_ASSUME_NONNULL_BEGIN

@interface JSNetworkInterface : NSObject

/**
 *  @brief 过滤后最终需要请求的URL
 */
@property (nonatomic, strong, readonly) NSString *finalURL;
/**
 *  @brief 过滤后URL的参数信息
 */
@property (nonatomic, strong, readonly) id finalArguments;
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
