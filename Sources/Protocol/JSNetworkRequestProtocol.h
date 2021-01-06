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
 *  @param taskCompleted 任务 <完全结束> 后的回调
 *
 *  @see JSNetworkRequest.m JSNetworkProvider.m
 */
- (void)buildTaskWithRequestConfig:(id<JSNetworkRequestConfigProtocol>)config
                     taskCompleted:(void(^)(id _Nullable responseObject, NSError *_Nullable error))taskCompleted;

/**
 *  @brief 设置代理
 *
 *  @param interfaceProxy 遵循<JSNetworkInterfaceProtocol>的接口
 *
 *  @see JSNetworkInterface.m
 */
- (void)addInterfaceProxy:(id<JSNetworkInterfaceProtocol>)interfaceProxy;

/**
 *  @brief 获得代理
 *
 *  @see JSNetworkInterface.m
 */
- (id<JSNetworkInterfaceProtocol>)interfaceProxy;

/**
 *  @brief 请求任务
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
