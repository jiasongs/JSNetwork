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

+ (instancetype)sharedAgent;

/**
 *  @brief 处理一个请求，该请求被处理后自动执行'- (void)addRequest:'
 *
 *  @param interface 遵循<JSNetworkInterfaceProtocol>的接口类
 *
 */
- (void)processingInterface:(id<JSNetworkInterfaceProtocol>)interface;

/**
 *  @brief 处理task完成后的响应并且执行回调。完成后自动执行'- (void)removeRequest:'
 *
 *  @param interface 遵循<JSNetworkInterfaceProtocol>的接口类
 *  @param responseObject 响应数据
 *  @param error 错误
 *
 *  @see JSNetworkProvider.m
 */
- (void)processingResponseWithInterface:(id<JSNetworkInterfaceProtocol>)interface
                         responseObject:(nullable id)responseObject
                             error:(nullable NSError *)error;

@end

@interface JSNetworkAgent (Plugin)

- (void)toggleWillStartWithInterface:(id<JSNetworkInterfaceProtocol>)interface;
- (void)toggleDidStartWithInterface:(id<JSNetworkInterfaceProtocol>)interface;
- (void)toggleWillStopWithInterface:(id<JSNetworkInterfaceProtocol>)interface;
- (void)toggleDidStopWithInterface:(id<JSNetworkInterfaceProtocol>)interface;

@end

NS_ASSUME_NONNULL_END
