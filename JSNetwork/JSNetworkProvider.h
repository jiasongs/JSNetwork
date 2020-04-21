//
//  JSNetworkProvider.h
//  JSNetwork
//
//  Created by jiasong on 2020/4/17.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol JSNetworkRequestConfigProtocol;
@protocol JSNetworkRequestProtocol;

NS_ASSUME_NONNULL_BEGIN

@interface JSNetworkProvider : NSObject

/**
 *  @brief requestConfig
 *
 *  @param config 遵循<JSNetworkRequestConfigProtocol>的配置项
 *
 *  @return 遵循<JSNetworkRequestProtocol>的请求类
 */
+ (id<JSNetworkRequestProtocol>)requestWithConfig:(id<JSNetworkRequestConfigProtocol>)config;

/**
 *  @brief requestConfig、completed
 *
 *  @param config 遵循<JSNetworkRequestConfigProtocol>的配置项
 *  @param completed 请求完成的回调
 *
 *  @return 遵循<JSNetworkRequestProtocol>的请求类
 */
+ (id<JSNetworkRequestProtocol>)requestWithConfig:(id<JSNetworkRequestConfigProtocol>)config
                                        completed:(nullable void (^)(id<JSNetworkRequestProtocol> aRequest))completed;

/**
 *  @brief requestConfig、uploadProgress、completed
 *
 *  @param config 遵循<JSNetworkRequestConfigProtocol>的配置项
 *  @param uploadProgress 上传进度
 *  @param completed 请求完成的回调
 *
 *  @return 遵循<JSNetworkRequestProtocol>的请求类
 */
+ (id<JSNetworkRequestProtocol>)requestWithConfig:(id<JSNetworkRequestConfigProtocol>)config
                                   uploadProgress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress
                                        completed:(nullable void (^)(id<JSNetworkRequestProtocol> aRequest))completed;

/**
 *  @brief requestConfig、downloadProgress、completed
 *
 *  @param config 遵循<JSNetworkRequestConfigProtocol>的配置项
 *  @param downloadProgress 下载进度
 *  @param completed 请求完成的回调
 *
 *  @return 遵循<JSNetworkRequestProtocol>的请求类
 */
+ (id<JSNetworkRequestProtocol>)requestWithConfig:(id<JSNetworkRequestConfigProtocol>)config
                                 downloadProgress:(nullable void (^)(NSProgress *downloadProgress))downloadProgress
                                        completed:(nullable void (^)(id<JSNetworkRequestProtocol> aRequest))completed;

/**
 *  @brief requestConfig、uploadProgress、downloadProgress、completed
 *
 *  @param config 遵循<JSNetworkRequestConfigProtocol>的配置项
 *  @param uploadProgress 上传进度
 *  @param downloadProgress 下载进度
 *  @param completed 请求完成的回调
 *
 *  @return 遵循<JSNetworkRequestProtocol>的请求类
 */
+ (id<JSNetworkRequestProtocol>)requestWithConfig:(id<JSNetworkRequestConfigProtocol>)config
                                   uploadProgress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress
                                 downloadProgress:(nullable void (^)(NSProgress *downloadProgress))downloadProgress
                                        completed:(nullable void (^)(id<JSNetworkRequestProtocol> aRequest))completed;

/**
 *  @brief request、requestConfig、completed
 *
 *  @param request 遵循<JSNetworkRequestProtocol>的请求类
 *  @param config 遵循<JSNetworkRequestConfigProtocol>的配置项
 *  @param completed 请求完成的回调
 *
 *  @return 遵循<JSNetworkRequestProtocol>的请求类
 */
+ (id<JSNetworkRequestProtocol>)request:(__kindof NSOperation<JSNetworkRequestProtocol> *)request
                             withConfig:(id<JSNetworkRequestConfigProtocol>)config
                              completed:(nullable void (^)(id<JSNetworkRequestProtocol> aRequest))completed;

/**
 *  @brief request、requestConfig、uploadProgress、completed
 *
 *  @param request 遵循<JSNetworkRequestProtocol>的请求类
 *  @param config 遵循<JSNetworkRequestConfigProtocol>的配置项
 *  @param uploadProgress 上传进度
 *  @param completed 请求完成的回调
 *
 *  @return 遵循<JSNetworkRequestProtocol>的请求类
 */
+ (id<JSNetworkRequestProtocol>)request:(__kindof NSOperation<JSNetworkRequestProtocol> *)request
                             withConfig:(id<JSNetworkRequestConfigProtocol>)config
                         uploadProgress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress
                              completed:(nullable void (^)(id<JSNetworkRequestProtocol> aRequest))completed;

/**
 *  @brief request、requestConfig、downloadProgress、completed
 *
 *  @param request 遵循<JSNetworkRequestProtocol>的请求类
 *  @param config 遵循<JSNetworkRequestConfigProtocol>的配置项
 *  @param downloadProgress 下载进度
 *  @param completed 请求完成的回调
 *
 *  @return 遵循<JSNetworkRequestProtocol>的请求类
 */
+ (id<JSNetworkRequestProtocol>)request:(__kindof NSOperation<JSNetworkRequestProtocol> *)request
                             withConfig:(id<JSNetworkRequestConfigProtocol>)config
                       downloadProgress:(nullable void (^)(NSProgress *downloadProgress))downloadProgress
                              completed:(nullable void (^)(id<JSNetworkRequestProtocol> aRequest))completed;

/**
 *  @brief request、requestConfig、uploadProgress、downloadProgress、completed
 *
 *  @param request 遵循<JSNetworkRequestProtocol>的请求类
 *  @param config 遵循<JSNetworkRequestConfigProtocol>的配置项
 *  @param uploadProgress 上传进度
 *  @param downloadProgress 下载进度
 *  @param completed 请求完成的回调
 *
 *  @return 遵循<JSNetworkRequestProtocol>的请求类
 */
+ (id<JSNetworkRequestProtocol>)request:(__kindof NSOperation<JSNetworkRequestProtocol> *)request
                             withConfig:(id<JSNetworkRequestConfigProtocol>)config
                         uploadProgress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress
                       downloadProgress:(nullable void (^)(NSProgress *downloadProgress))downloadProgress
                              completed:(nullable void (^)(id<JSNetworkRequestProtocol> aRequest))completed;


@end

NS_ASSUME_NONNULL_END
