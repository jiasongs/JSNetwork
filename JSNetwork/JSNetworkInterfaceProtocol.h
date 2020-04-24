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
 *  @brief 已经处理好的请求配置类
 */
@property (nonatomic, strong, readonly) id<JSNetworkRequestConfigProtocol> processedConfig;
/**
 *  @brief 原始的请求配置类
 */
@property (nonatomic, strong, readonly) id<JSNetworkRequestConfigProtocol> originalConfig;
/**
 *  @brief 缓存类的实例
 */
@property (nonatomic, strong, readonly) id<JSNetworkDiskCacheProtocol> diskCache;
/**
 *  @brief 请求类
 */
@property (nonatomic, strong, readonly) __kindof NSOperation<JSNetworkRequestProtocol> *request;
/**
 *  @brief 响应类
 */
@property (nonatomic, strong, readonly) id<JSNetworkResponseProtocol> response;

/**
 *  @brief 根据config初始化一个Interface
 *
 *  @param config JSNetworkRequestConfigProtocol
 */
- (instancetype)initWithRequestConfig:(id<JSNetworkRequestConfigProtocol>)config;

@end

NS_ASSUME_NONNULL_END
