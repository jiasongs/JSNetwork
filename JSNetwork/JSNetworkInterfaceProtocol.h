//
//  JSNetworkInterfaceProtocol.h
//  ITHomeClient
//
//  Created by jiasong on 2020/4/20.
//  Copyright © 2020 ruanmei. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol JSNetworkInterfaceProtocol;
@protocol JSNetworkRequestConfigProtocol;
@protocol JSNetworkResponseProtocol;
@protocol JSNetworkRequestProtocol;
@protocol JSNetworkDiskCacheProtocol;

NS_ASSUME_NONNULL_BEGIN

typedef void(^JSNetworkRequestCompletedFilter)(id<JSNetworkInterfaceProtocol> aInterface);
typedef void(^JSNetworkProgressBlock)(NSProgress *progress);

@protocol JSNetworkInterfaceProtocol <NSObject>

@required
/**
 *  @brief 已经处理好的请求配置类
 */
@property (nonatomic, strong, readonly) id<JSNetworkRequestConfigProtocol> processedConfig;
/**
 *  @brief 请求类
 */
@property (nonatomic, strong, readonly) __kindof NSOperation<JSNetworkRequestProtocol> *request;
/**
 *  @brief 响应类
 */
@property (nonatomic, strong, readonly) id<JSNetworkResponseProtocol> response;
/**
 *  @brief 缓存类的实例
 */
@property (nonatomic, strong, readonly) id<JSNetworkDiskCacheProtocol> diskCache;
/**
 *  @brief 上传进度的回调
 */
@property (nullable, nonatomic, copy, readonly) JSNetworkProgressBlock uploadProgress;
/**
 *  @brief 下载进度的回调
 */
@property (nullable, nonatomic, copy, readonly) JSNetworkProgressBlock downloadProgress;
/**
 *  @brief 返回已经完成的回调
 */
@property (nonatomic, strong, readonly) NSArray<JSNetworkRequestCompletedFilter> *completionBlocks;

/**
 *  @brief 根据config初始化一个Interface
 *
 *  @param config JSNetworkRequestConfigProtocol
 */
- (instancetype)initWithRequestConfig:(id<JSNetworkRequestConfigProtocol>)config;

/**
 *  @brief 设置上传进度的回调
 *
 *  @param uploadProgress 上传进度
 *
 *  @use 实现此方法时需要持有uploadProgress
 */
- (void)requestUploadProgress:(nullable JSNetworkProgressBlock)uploadProgress;

/**
 *  @brief 设置下载进度的回调
 *
 *  @param downloadProgress 下载进度
 *
 *  @use 实现此方法时需要持有downloadProgress
 */
- (void)requestDownloadProgress:(nullable JSNetworkProgressBlock)downloadProgress;

/**
 *  @brief 设置请求完成的回调，此时响应已经被处理
 *
 *  @param completionBlock 完成前的回调
 *
 *  @use 实现此方法时需要用一个数组持有completionBlock，因为外部会设置多个回调
 *  @see JSNetworkRequest.m
 */
- (void)requestCompletedFilter:(nullable JSNetworkRequestCompletedFilter)completionBlock;

/**
 *  @brief 清空所有回调
 */
- (void)clearAllCallBack;

@end

NS_ASSUME_NONNULL_END
