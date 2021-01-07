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

@protocol JSNetworkRequestProtocol <NSObject>

@required

/**
 *  @brief 构建一个NSURLSessionTask
 *
 *  @param config 遵循<JSNetworkRequestConfigProtocol>的配置类
 *  @param constructingURLRequest     配置请求, 可自定义
 *  @param constructingFormDataBlock  拼接FormData
 *  @param uploadProgressBlock        上传进度
 *  @param downloadProgressBlock      下载进度
 *  @param taskCompleted            任务 <完全结束> 后的回调
 *
 *  @see JSNetworkRequest.m JSNetworkProvider.m
 */
- (void)buildTaskWithRequestConfig:(id<JSNetworkRequestConfigProtocol>)config
                    uploadProgress:(void(^)(NSProgress *uploadProgress))uploadProgressBlock
                  downloadProgress:(void(^)(NSProgress *downloadProgress))downloadProgressBlock
                     taskCompleted:(void(^)(id _Nullable responseObject, NSError *_Nullable error))taskCompleted;

- (NSMutableURLRequest *)requestWithRequestConfig:(id<JSNetworkRequestConfigProtocol>)config
                        constructingFormDataBlock:(void(^)(id formData))constructingFormDataBlock;

/**
 *  @brief SessionTask
 */
- (NSURLSessionTask *)requestTask;

/**
 *  @brief 任务ID, 保证唯一, 注意线程安全
 *
 * @return NSString
 */
- (NSString *)taskIdentifier;

@end

NS_ASSUME_NONNULL_END
