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
@protocol JSNetworkInterfaceProtocol;

NS_ASSUME_NONNULL_BEGIN

@interface JSNetworkProvider : NSObject

/**
 *  @brief requestConfig、completed
 *
 *  @param config 遵循<JSNetworkRequestConfigProtocol>的配置项
 *  @param completed 请求完成的回调
 *
 *  @return 遵循<JSNetworkInterfaceProtocol>的接口
 */
+ (id<JSNetworkInterfaceProtocol>)requestWithConfig:(id<JSNetworkRequestConfigProtocol>)config
                                          completed:(nullable void (^)(id<JSNetworkInterfaceProtocol> aInterface))completed;

/**
 *  @brief requestConfig、constructingFormData、completed
 *
 *  @param config 遵循<JSNetworkRequestConfigProtocol>的配置项
 *  @param constructingFormData FormData
 *  @param completed 请求完成的回调
 *
 *  @return 遵循<JSNetworkInterfaceProtocol>的接口
 */
+ (id<JSNetworkInterfaceProtocol>)requestWithConfig:(id<JSNetworkRequestConfigProtocol>)config
                               constructingFormData:(nullable void(^)(id formData))constructingFormData
                                          completed:(nullable void (^)(id<JSNetworkInterfaceProtocol> aInterface))completed;

/**
 *  @brief requestConfig、uploadProgress、completed
 *
 *  @param config 遵循<JSNetworkRequestConfigProtocol>的配置项
 *  @param uploadProgress 上传进度
 *  @param completed 请求完成的回调
 *
 *  @return 遵循<JSNetworkInterfaceProtocol>的接口
 */
+ (id<JSNetworkInterfaceProtocol>)requestWithConfig:(id<JSNetworkRequestConfigProtocol>)config
                                     uploadProgress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress
                                          completed:(nullable void (^)(id<JSNetworkInterfaceProtocol> aInterface))completed;

/**
 *  @brief requestConfig、constructingFormData、uploadProgress、completed
 *
 *  @param config 遵循<JSNetworkRequestConfigProtocol>的配置项
 *  @param constructingFormData FormData
 *  @param uploadProgress 上传进度
 *  @param completed 请求完成的回调
 *
 *  @return 遵循<JSNetworkInterfaceProtocol>的接口
 */
+ (id<JSNetworkInterfaceProtocol>)requestWithConfig:(id<JSNetworkRequestConfigProtocol>)config
                               constructingFormData:(nullable void(^)(id formData))constructingFormData
                                     uploadProgress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress
                                          completed:(nullable void (^)(id<JSNetworkInterfaceProtocol> aInterface))completed;

/**
 *  @brief requestConfig、downloadProgress、completed
 *
 *  @param config 遵循<JSNetworkRequestConfigProtocol>的配置项
 *  @param downloadProgress 下载进度
 *  @param completed 请求完成的回调
 *
 *  @return 遵循<JSNetworkInterfaceProtocol>的接口
 */
+ (id<JSNetworkInterfaceProtocol>)requestWithConfig:(id<JSNetworkRequestConfigProtocol>)config
                                   downloadProgress:(nullable void (^)(NSProgress *downloadProgress))downloadProgress
                                          completed:(nullable void (^)(id<JSNetworkInterfaceProtocol> aInterface))completed;

/**
 *  @brief requestConfig、constructingFormData、downloadProgress、completed
 *
 *  @param config 遵循<JSNetworkRequestConfigProtocol>的配置项
 *  @param constructingFormData FormData
 *  @param downloadProgress 下载进度
 *  @param completed 请求完成的回调
 *
 *  @return 遵循<JSNetworkInterfaceProtocol>的接口
 */
+ (id<JSNetworkInterfaceProtocol>)requestWithConfig:(id<JSNetworkRequestConfigProtocol>)config
                               constructingFormData:(nullable void(^)(id formData))constructingFormData
                                   downloadProgress:(nullable void (^)(NSProgress *downloadProgress))downloadProgress
                                          completed:(nullable void (^)(id<JSNetworkInterfaceProtocol> aInterface))completed;

/**
 *  @brief requestConfig、uploadProgress、downloadProgress、completed
 *
 *  @param config 遵循<JSNetworkRequestConfigProtocol>的配置项
 *  @param uploadProgress 上传进度
 *  @param downloadProgress 下载进度
 *  @param completed 请求完成的回调
 *
 *  @return 遵循<JSNetworkInterfaceProtocol>的接口
 */
+ (id<JSNetworkInterfaceProtocol>)requestWithConfig:(id<JSNetworkRequestConfigProtocol>)config
                                     uploadProgress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress
                                   downloadProgress:(nullable void (^)(NSProgress *downloadProgress))downloadProgress
                                          completed:(nullable void (^)(id<JSNetworkInterfaceProtocol> aInterface))completed;

/**
 *  @brief requestConfig、constructingFormData、uploadProgress、downloadProgress、completed
 *
 *  @param config 遵循<JSNetworkRequestConfigProtocol>的配置项
 *  @param constructingFormData FormData
 *  @param uploadProgress 上传进度
 *  @param downloadProgress 下载进度
 *  @param completed 请求完成的回调
 *
 *  @return 遵循<JSNetworkInterfaceProtocol>的接口
 */
+ (id<JSNetworkInterfaceProtocol>)requestWithConfig:(id<JSNetworkRequestConfigProtocol>)config
                               constructingFormData:(nullable void(^)(id formData))constructingFormData
                                     uploadProgress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress
                                   downloadProgress:(nullable void (^)(NSProgress *downloadProgress))downloadProgress
                                          completed:(nullable void (^)(id<JSNetworkInterfaceProtocol> aInterface))completed;


@end

NS_ASSUME_NONNULL_END
