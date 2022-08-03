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
@protocol JSNetworkRequestCancellableProtocol;
@protocol JSNetworkDiskCacheProtocol;
@protocol JSNetworkDiskCacheProtocol;
@protocol JSNetworkRequestProtocol;

NS_ASSUME_NONNULL_BEGIN

typedef void(^JSNetworkProgressBlock)(NSProgress *progress);
typedef void(^JSNetworkRequestCompletionHandler)(id<JSNetworkInterfaceProtocol> aInterface);

@protocol JSNetworkInterfaceProtocol <NSObject>

@required
/**
 *  @brief 已经处理好的请求配置类
 */
@property (nonatomic, strong) id<JSNetworkRequestConfigProtocol> config;
/**
 *  @brief 请求类
 */
@property (nonatomic, strong) __kindof NSOperation<JSNetworkRequestProtocol> *request;
/**
 *  @brief 请求取消类
 */
@property (nonatomic, strong) id<JSNetworkRequestCancellableProtocol> requestCancellable;
/**
 *  @brief 响应类
 */
@property (nonatomic, strong) id<JSNetworkResponseProtocol> response;
/**
 *  @brief 缓存类
 */
@property (nullable, nonatomic, strong) id<JSNetworkDiskCacheProtocol> diskCache;
/**
 *  @brief 上传进度的回调
 */
@property (nullable, nonatomic, copy) JSNetworkProgressBlock uploadProgress;
/**
 *  @brief 下载进度的回调
 */
@property (nullable, nonatomic, copy) JSNetworkProgressBlock downloadProgress;
/**
 *  @brief 返回已经完成的回调
 */
@property (nullable, nonatomic, copy) JSNetworkRequestCompletionHandler completionHandler;
/**
 *  @brief 任务ID, 保证全局唯一
 *
 * @return NSString
 */
@property (nonatomic, copy) NSString *taskIdentifier;

@end

NS_ASSUME_NONNULL_END
