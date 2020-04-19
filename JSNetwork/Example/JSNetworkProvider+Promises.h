//
//  JSNetworkProvider+Promises.h
//  JSNetwork
//
//  Created by jiasong on 2020/4/19.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import "JSNetworkProvider.h"
#import <FBLPromises.h>

NS_ASSUME_NONNULL_BEGIN

@interface JSNetworkProvider (Promises)

/**
 *  @brief FBLPromise、requestConfig
 *
 *  @param config  遵循<JSNetworkRequestConfigProtocol>的配置项
 *
 *  @return FBLPromise<JSNetworkRequestProtocol>
 */
+ (FBLPromise<id<JSNetworkRequestProtocol>> *)requestWithConfig:(id<JSNetworkRequestConfigProtocol>)config;

/**
 *  @brief FBLPromise、requestConfig、uploadProgress
 *
 *  @param config  遵循<JSNetworkRequestConfigProtocol>的配置项
 *  @param uploadProgress 上传进度
 *
 *  @return FBLPromise<JSNetworkRequestProtocol>
 */
+ (FBLPromise<id<JSNetworkRequestProtocol>> *)requestWithConfig:(id<JSNetworkRequestConfigProtocol>)config
                                                 uploadProgress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress;

/**
 *  @brief FBLPromise、requestConfig、downloadProgress
 *
 *  @param config  遵循<JSNetworkRequestConfigProtocol>的配置项
 *  @param downloadProgress 下载进度
 *
 *  @return FBLPromise<JSNetworkRequestProtocol>
 */
+ (FBLPromise<id<JSNetworkRequestProtocol>> *)requestWithConfig:(id<JSNetworkRequestConfigProtocol>)config
                                               downloadProgress:(nullable void (^)(NSProgress *uploadProgress))downloadProgress;

/**
 *  @brief FBLPromise、requestConfig、uploadProgress、downloadProgress
 *
 *  @param config  遵循<JSNetworkRequestConfigProtocol>的配置项
 *  @param uploadProgress 上传进度
 *  @param downloadProgress 下载进度
 *
 *  @return FBLPromise<JSNetworkRequestProtocol>
 */
+ (FBLPromise<id<JSNetworkRequestProtocol>> *)requestWithConfig:(id<JSNetworkRequestConfigProtocol>)config
                                                 uploadProgress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress
                                               downloadProgress:(nullable void (^)(NSProgress *downloadProgress))downloadProgress;

/**
 *  @brief FBLPromise、requestConfig
 *
 *  @param request 遵循<JSNetworkRequestProtocol>请求
 *  @param config  遵循<JSNetworkRequestConfigProtocol>的配置项
 *
 *  @return FBLPromise<JSNetworkRequestProtocol>
 */
+ (FBLPromise<id<JSNetworkRequestProtocol>> *)request:(id<JSNetworkRequestProtocol>)request
                                           withConfig:(id<JSNetworkRequestConfigProtocol>)config;

/**
 *  @brief FBLPromise、request、requestConfig、downloadProgress
 *
 *  @param request 遵循<JSNetworkRequestProtocol>请求
 *  @param config 遵循<JSNetworkRequestConfigProtocol>的配置项
 *  @param downloadProgress 下载进度
 *
 *  @return FBLPromise<JSNetworkRequestProtocol>
 */
+ (FBLPromise<id<JSNetworkRequestProtocol>> *)request:(id<JSNetworkRequestProtocol>)request
                                           withConfig:(id<JSNetworkRequestConfigProtocol>)config
                                     downloadProgress:(nullable void (^)(NSProgress *downloadProgress))downloadProgress;

/**
 *  @brief FBLPromise、request、requestConfig、downloadProgress
 *
 *  @param request 遵循<JSNetworkRequestProtocol>请求
 *  @param config 遵循<JSNetworkRequestConfigProtocol>的配置项
 *  @param uploadProgress 上传进度
 *
 *  @return FBLPromise<JSNetworkRequestProtocol>
 */
+ (FBLPromise<id<JSNetworkRequestProtocol>> *)request:(id<JSNetworkRequestProtocol>)request
                                           withConfig:(id<JSNetworkRequestConfigProtocol>)config
                                       uploadProgress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress;

/**
 *  @brief FBLPromise、request、requestConfig、uploadProgress、downloadProgress
 *
 *  @param request 遵循<JSNetworkRequestProtocol>的请求类
 *  @param config 遵循<JSNetworkRequestConfigProtocol>的配置项
 *  @param uploadProgress 上传进度
 *  @param downloadProgress 下载进度
 *
 *  @return FBLPromise<JSNetworkRequestProtocol>
 */
+ (FBLPromise<id<JSNetworkRequestProtocol>> *)request:(id<JSNetworkRequestProtocol>)request
                                           withConfig:(id<JSNetworkRequestConfigProtocol>)config
                                       uploadProgress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress
                                     downloadProgress:(nullable void (^)(NSProgress *downloadProgress))downloadProgress;

@end

NS_ASSUME_NONNULL_END
