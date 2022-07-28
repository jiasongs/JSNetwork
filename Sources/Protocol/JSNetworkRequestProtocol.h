//
//  JSNetworkRequestProtocol.h
//  JSNetwork
//
//  Created by jiasong on 2020/4/17.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JSNetworkRequestConfigProtocol;

NS_ASSUME_NONNULL_BEGIN

@protocol JSNetworkRequestProtocol <NSObject>

@required

/**
 *  @brief 构建NSURLSessionTask
 *
 *  @param config 遵循<JSNetworkRequestConfigProtocol>的配置类
 *  @param multipartFormDataBlock       拼接FormData
 *  @param uploadProgressBlock          上传进度
 *  @param downloadProgressBlock        下载进度
 *  @param didCreateURLRequestBlock     URLRRequest创建完毕
 *  @param didCreateTaskBlock           Task创建完毕
 *  @param didCompletedBlock            任务 <完全结束> 后的回调
 *
 *  @see JSNetworkRequest.m
 */
- (void)buildTaskWithConfig:(id<JSNetworkRequestConfigProtocol>)config
          multipartFormData:(void(^)(id formData))multipartFormDataBlock
             uploadProgress:(void(^)(NSProgress *uploadProgress))uploadProgressBlock
           downloadProgress:(void(^)(NSProgress *downloadProgress))downloadProgressBlock
        didCreateURLRequest:(void(^)(NSMutableURLRequest *urlRequest))didCreateURLRequestBlock
              didCreateTask:(void(^)(__kindof NSURLSessionTask *task))didCreateTaskBlock
               didCompleted:(void(^)(id _Nullable responseObject, NSError *_Nullable error))didCompletedBlock;

/**
 *  @brief SessionTask
 */
- (NSURLSessionTask *)requestTask;

@end

NS_ASSUME_NONNULL_END
