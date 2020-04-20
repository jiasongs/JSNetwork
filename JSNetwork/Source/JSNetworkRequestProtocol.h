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
@class JSNetworkInterface;

NS_ASSUME_NONNULL_BEGIN

typedef void(^JSNetworkRequestCompletedFilter)(id<JSNetworkRequestProtocol> aRequest);
typedef void(^JSNetworkProgressBlock)(NSProgress *progress);

@protocol JSNetworkRequestProtocol <NSObject>

@required

/**
 *  @brief 构建一个NSURLSessionTask
 *
 *  @param interface 根据config生成的接口类
 *  @param taskCompleted 任务 <完全结束> 后的回调
 *
 *  @see JSNetworkRequest.m JSNetworkProvider.m
 */
- (void)buildTaskWithInterface:(JSNetworkInterface *)interface taskCompleted:(void(^)(NSURLSessionDataTask *task, id _Nullable responseObject, NSError *_Nullable error))taskCompleted;

/**
 *  @brief 开始一个请求
 */
- (void)start;

/**
 *  @brief 取消一个请求
 */
- (void)cancel;

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
 *  @brief 返回已经完成的回调
 *
 *  @return 数组
 *
 */
- (NSArray<JSNetworkRequestCompletedFilter> *)completedFilters;

/**
 *  @brief 清空所有Block
 */
- (void)clearAllCallBack;

/**
 *  @brief 返回设置的interface
 *
 *  @use 需要持有一个requestInterface
 */
- (JSNetworkInterface *)requestInterface;

/**
 *  @brief 返回响应体
 */
- (id<JSNetworkResponseProtocol>)response;

/**
 *  @brief 请求任务
 */
- (NSURLSessionTask *)requestTask;

/**
 *  @brief 当前NSURLRequest
 */
- (NSURLRequest *)currentURLRequest;

/**
 *  @brief 原始NSURLRequest
 */
- (NSURLRequest *)originalURLRequest;

/**
 *  @brief 任务是否正在执行
 */
- (BOOL)isExecuting;

/**
 *  @brief 任务是否已经取消
 */
- (BOOL)isCancelled;

@end

NS_ASSUME_NONNULL_END
