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


- (void)buildTaskWithConfig:(id<JSNetworkRequestConfigProtocol>)config
          multipartFormData:(void(^)(id formData))multipartFormDataBlock
        didCreateURLRequest:(void(^)(NSMutableURLRequest *urlRequest))didCreateURLRequestBlock
              didCreateTask:(void(^)(NSURLSessionTask *task))didCreateTaskBlock
             uploadProgress:(void(^)(NSProgress *uploadProgress))uploadProgressBlock
           downloadProgress:(void(^)(NSProgress *downloadProgress))downloadProgressBlock
               didCompleted:(void(^)(id _Nullable responseObject, NSError *_Nullable error))didCompletedBlock;

/**
 *  @brief SessionTask
 */
- (NSURLSessionTask *)requestTask;

@end

NS_ASSUME_NONNULL_END
