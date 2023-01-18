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
 *  @param uploadProgress         上传进度
 *  @param downloadProgress       下载进度
 *  @param constructingFormData   合成constructingFormData
 *  @param didCreateURLRequest    创建URLRRequest
 *  @param didCreateTask          创建Task
 *  @param didCompleted           任务 <完全结束> 后的回调
 */
- (void)buildTaskWithConfig:(id<JSNetworkRequestConfigProtocol>)config
             uploadProgress:(void(^)(NSProgress *uploadProgress))uploadProgress
           downloadProgress:(void(^)(NSProgress *downloadProgress))downloadProgress
       constructingFormData:(void(^)(id formData))constructingFormData
        didCreateURLRequest:(NSURLRequest *(^)(NSURLRequest *urlRequest))didCreateURLRequest
              didCreateTask:(void(^)(NSURLSessionTask *task))didCreateTask
               didCompleted:(void(^)(id _Nullable responseObject, NSError *_Nullable error))didCompleted;

/**
 *  @brief SessionTask
 */
- (NSURLSessionTask *)requestTask;

@end

NS_ASSUME_NONNULL_END
