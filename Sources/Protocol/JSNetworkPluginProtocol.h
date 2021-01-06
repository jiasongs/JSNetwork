//
//  JSNetworkPlugin.h
//  JSNetwork
//
//  Created by jiasong on 2020/4/17.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol JSNetworkInterfaceProtocol;

NS_ASSUME_NONNULL_BEGIN

@protocol JSNetworkPluginProtocol <NSObject>

@optional

/**
 *  @brief 请求将要开始
 *
 *  @param interface 遵循<JSNetworkInterfaceProtocol>的接口类
 *
 *  @use 可能不在主线程被调用
 */
- (void)requestWillStart:(id<JSNetworkInterfaceProtocol>)interface;

/**
 *  @brief 请求已经开始
 *
 *  @param interface 遵循<JSNetworkInterfaceProtocol>的接口类
 *
 *  @use 可能不在主线程被调用
 */
- (void)requestDidStart:(id<JSNetworkInterfaceProtocol>)interface;

/**
 *  @brief 请求将要结束
 *
 *  @param interface 遵循<JSNetworkInterfaceProtocol>的接口类
 *
 *  @use 可能不在主线程被调用
 */
- (void)requestWillStop:(id<JSNetworkInterfaceProtocol>)interface;

/**
 *  @brief 请求已经结束
 *
 *  @param interface 遵循<JSNetworkInterfaceProtocol>的接口类
 *
 *  @use 可能不在主线程被调用
 */
- (void)requestDidStop:(id<JSNetworkInterfaceProtocol>)interface;

@end

NS_ASSUME_NONNULL_END
