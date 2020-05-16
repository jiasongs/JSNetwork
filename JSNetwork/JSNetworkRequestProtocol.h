//
//  JSNetworkRequestProtocol.h
//  JSNetwork
//
//  Created by jiasong on 2020/4/17.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol JSNetworkRequestConfigProtocol;
@protocol JSNetworkResponseProtocol;
@protocol JSNetworkRequestProtocol;
@protocol JSNetworkInterfaceProtocol;

NS_ASSUME_NONNULL_BEGIN

typedef void(^JSNetworkRequestCompletedFilter)(id<JSNetworkInterfaceProtocol> aInterface);
typedef void(^JSNetworkProgressBlock)(NSProgress *progress);

@protocol JSNetworkRequestProtocol <NSObject>

@required

/**
 *  @brief 构建一个NSURLSessionTask
 *
 *  @param config 遵循<JSNetworkRequestConfigProtocol>的配置类
 *  @param taskCompleted 任务 <完全结束> 后的回调
 *
 *  @see JSNetworkRequest.m JSNetworkProvider.m
 */
- (void)buildTaskWithRequestConfig:(id<JSNetworkRequestConfigProtocol>)config
                     taskCompleted:(void(^)(id _Nullable responseObject, NSError *_Nullable error))taskCompleted;


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
 *  @brief 上传进度的回调
 *
 *  @return uploadProgress
 *
 */
- (nullable JSNetworkProgressBlock)uploadProgress;

/**
 *  @brief 下载进度的回调
 *
 *  @return downloadProgress
 *
 */
- (nullable JSNetworkProgressBlock)downloadProgress;

/**
 *  @brief 返回已经完成的回调
 *
 *  @return 数组
 *
 */
- (NSArray<JSNetworkRequestCompletedFilter> *)completedFilters;

/**
 *  @brief 清空所有回调
 */
- (void)clearAllCallBack;

/**
 *  @brief 请求任务
 */
- (NSURLSessionTask *)requestTask;

/**
 *  @brief 任务ID
 *
 * @return NSString
 */
- (NSString *)taskIdentifier;

@end

NS_ASSUME_NONNULL_END
