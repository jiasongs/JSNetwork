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

NS_ASSUME_NONNULL_BEGIN

@protocol JSNetworkInterfaceProtocol <NSObject>

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
 *  @brief 任务处理所在的队列，默认并行队列
 */
@property (nonatomic, strong, readonly) dispatch_queue_t processingQueue;
/**
 *  @brief 回调处理所在的队列，默认主队列
 */
@property (nonatomic, strong, readonly) dispatch_queue_t completionQueue;
/**
 *  @brief 全部插件
 */
@property (nonatomic, strong, readonly) NSArray *allPlugins;
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
