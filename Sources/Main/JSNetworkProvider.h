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
@protocol JSNetworkRequestCancellableProtocol;

NS_ASSUME_NONNULL_BEGIN

@interface JSNetworkProvider : NSObject

/**
 *  @brief requestConfig、completed
 *
 *  @param config 遵循<JSNetworkRequestConfigProtocol>的配置项
 *  @param completed 请求完成的回调
 *
 *  @return 遵循<JSNetworkRequestCancellableProtocol>
 */
+ (id<JSNetworkRequestCancellableProtocol>)requestWithConfig:(id<JSNetworkRequestConfigProtocol>)config
                                                   completed:(nullable void (^)(id<JSNetworkInterfaceProtocol> aInterface))completed NS_SWIFT_NAME(request(config:completed:));

+ (id<JSNetworkRequestCancellableProtocol>)requestWithConfig:(id<JSNetworkRequestConfigProtocol>)config
                                                    onTarget:(nullable __kindof NSObject *)target
                                                   completed:(nullable void (^)(__kindof NSObject *_Nullable target, id<JSNetworkInterfaceProtocol> aInterface))completed NS_SWIFT_NAME(request(config:onTarget:completed:));

/**
 *  @brief requestConfig、uploadProgress、completed
 *
 *  @param config 遵循<JSNetworkRequestConfigProtocol>的配置项
 *  @param uploadProgress 上传进度
 *  @param completed 请求完成的回调
 *
 *  @return 遵循<JSNetworkRequestCancellableProtocol>
 */
+ (id<JSNetworkRequestCancellableProtocol>)requestWithConfig:(id<JSNetworkRequestConfigProtocol>)config
                                              uploadProgress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress
                                                   completed:(nullable void (^)(id<JSNetworkInterfaceProtocol> aInterface))completed NS_SWIFT_NAME(request(config:uploadProgress:completed:));

+ (id<JSNetworkRequestCancellableProtocol>)requestWithConfig:(id<JSNetworkRequestConfigProtocol>)config
                                                    onTarget:(nullable __kindof NSObject *)target
                                              uploadProgress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress
                                                   completed:(nullable void (^)(__kindof NSObject *_Nullable target, id<JSNetworkInterfaceProtocol> aInterface))completed NS_SWIFT_NAME(request(config:onTarget:uploadProgress:completed:));

/**
 *  @brief requestConfig、downloadProgress、completed
 *
 *  @param config 遵循<JSNetworkRequestConfigProtocol>的配置项
 *  @param downloadProgress 下载进度
 *  @param completed 请求完成的回调
 *
 *  @return 遵循<JSNetworkRequestCancellableProtocol>
 */
+ (id<JSNetworkRequestCancellableProtocol>)requestWithConfig:(id<JSNetworkRequestConfigProtocol>)config
                                            downloadProgress:(nullable void (^)(NSProgress *downloadProgress))downloadProgress
                                                   completed:(nullable void (^)(id<JSNetworkInterfaceProtocol> aInterface))completed NS_SWIFT_NAME(request(config:downloadProgress:completed:));

+ (id<JSNetworkRequestCancellableProtocol>)requestWithConfig:(id<JSNetworkRequestConfigProtocol>)config
                                                    onTarget:(nullable __kindof NSObject *)target
                                            downloadProgress:(nullable void (^)(NSProgress *downloadProgress))downloadProgress
                                                   completed:(nullable void (^)(__kindof NSObject *_Nullable target, id<JSNetworkInterfaceProtocol> aInterface))completed NS_SWIFT_NAME(request(config:onTarget:downloadProgress:completed:));

/**
 *  @brief requestConfig、uploadProgress、downloadProgress、completed
 *
 *  @param config 遵循<JSNetworkRequestConfigProtocol>的配置项
 *  @param uploadProgress 上传进度
 *  @param downloadProgress 下载进度
 *  @param completed 请求完成的回调
 *
 *  @return 遵循<JSNetworkRequestCancellableProtocol>
 */
+ (id<JSNetworkRequestCancellableProtocol>)requestWithConfig:(id<JSNetworkRequestConfigProtocol>)config
                                              uploadProgress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress
                                            downloadProgress:(nullable void (^)(NSProgress *downloadProgress))downloadProgress
                                                   completed:(nullable void (^)(id<JSNetworkInterfaceProtocol> aInterface))completed NS_SWIFT_NAME(request(config:uploadProgress:downloadProgress:completed:));

+ (id<JSNetworkRequestCancellableProtocol>)requestWithConfig:(id<JSNetworkRequestConfigProtocol>)config
                                                    onTarget:(nullable __kindof NSObject *)target
                                              uploadProgress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress
                                            downloadProgress:(nullable void (^)(NSProgress *downloadProgress))downloadProgress
                                                   completed:(nullable void (^)(__kindof NSObject *_Nullable target, id<JSNetworkInterfaceProtocol> aInterface))completed NS_SWIFT_NAME(request(config:onTarget:uploadProgress:downloadProgress:completed:));


@end

NS_ASSUME_NONNULL_END
