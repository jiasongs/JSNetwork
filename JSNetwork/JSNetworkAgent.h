//
//  JSNetworkAgent.h
//  JSNetwork
//
//  Created by jiasong on 2020/4/17.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol JSNetworkRequestProtocol;
@protocol JSNetworkRequestConfigProtocol;
@protocol JSNetworkInterfaceProtocol;

NS_ASSUME_NONNULL_BEGIN

@interface JSNetworkAgent : NSObject

/**
 *  @brief 单例
 */
+ (instancetype)sharedAgent;

/**
 *  @brief 添加一个请求
 *
 *  @param interface 遵循<JSNetworkInterfaceProtocol>的接口类
 *
 */
- (void)addRequestForInterface:(id<JSNetworkInterfaceProtocol>)interface;

/**
 *  @brief 取消一个请求
 *
 *  @param interface 遵循<JSNetworkInterfaceProtocol>的接口类
 *
 */
- (void)cancelRequestForInterface:(id<JSNetworkInterfaceProtocol>)interface;

/**
 *  @brief 取消一个请求, 根据任务ID
 *
 *  @param taskIdentifier 任务ID
 *
 */
- (void)cancelRequestForTaskIdentifier:(NSString *)taskIdentifier;

/**
 *  @brief 获得一个接口
 *
 *  @param taskIdentifier 任务ID
 *
 */
- (nullable id<JSNetworkInterfaceProtocol>)interfaceForTaskIdentifier:(NSString *)taskIdentifier;

@end

@interface JSNetworkAgent (Plugin)

- (void)toggleWillStartWithInterface:(id<JSNetworkInterfaceProtocol>)interface;
- (void)toggleDidStartWithInterface:(id<JSNetworkInterfaceProtocol>)interface;
- (void)toggleWillStopWithInterface:(id<JSNetworkInterfaceProtocol>)interface;
- (void)toggleDidStopWithInterface:(id<JSNetworkInterfaceProtocol>)interface;

@end

NS_ASSUME_NONNULL_END
