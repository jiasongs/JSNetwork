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

typedef void(^JSNetworkRequestCompletePreprocessor)(id<JSNetworkRequestProtocol> aRequest, id _Nullable responseObject, NSError *_Nullable error);
typedef void(^JSNetworkRequestCompletedFilter)(id<JSNetworkRequestProtocol> aRequest);
typedef void(^JSNetworkProgressBlock)(NSProgress *progress);

@protocol JSNetworkRequestProtocol <NSObject>

@required

@property (nonatomic, strong) id<JSNetworkResponseProtocol> response;

/// 构造请求类
- (void)buildTaskWithInterface:(JSNetworkInterface *)interface taskCompleted:(void(^)(id<JSNetworkRequestProtocol> aRequest))taskCompleted;
/// 开始
- (void)start;
/// 取消
- (void)cancel;
/// 上传进度
- (void)requestUploadProgress:(nullable JSNetworkProgressBlock)uploadProgress;
/// 下载进度
- (void)requestDownloadProgress:(nullable JSNetworkProgressBlock)downloadProgress;
/// 请求完成之前，还未构造Response
- (void)requestCompletePreprocessor:(nullable JSNetworkRequestCompletePreprocessor)completionBlock;
/// 构造Response完成
- (void)requestCompletedFilter:(nullable JSNetworkRequestCompletedFilter)completionBlock;
- (JSNetworkInterface *)requestInterface;
/// 唯一ID
- (NSString *)taskIdentifier;
- (NSURLSessionTask *)requestTask;
- (NSURLRequest *)currentURLRequest;
- (NSURLRequest *)originalURLRequest;
- (BOOL)isCancelled;
- (BOOL)isExecuting;

@optional



@end

NS_ASSUME_NONNULL_END
