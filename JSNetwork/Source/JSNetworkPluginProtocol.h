//
//  JSNetworkPlugin.h
//  JSNetwork
//
//  Created by jiasong on 2020/4/17.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol JSNetworkRequestProtocol;

NS_ASSUME_NONNULL_BEGIN

@protocol JSNetworkPluginProtocol <NSObject>

@optional

/**
 *  @brief 请求将要开始
 *
 *  @param request 请求类
*/
- (void)requestWillStart:(id<JSNetworkRequestProtocol>)request;

/**
 *  @brief 请求已经开始
 *
 *  @param request 请求类
*/
- (void)requestDidStart:(id<JSNetworkRequestProtocol>)request;

/**
 *  @brief 请求将要结束
 *
 *  @param request 请求类
*/
- (void)requestWillStop:(id<JSNetworkRequestProtocol>)request;

/**
 *  @brief 请求已经结束
 *
 *  @param request 请求类
*/
- (void)requestDidStop:(id<JSNetworkRequestProtocol>)request;

@end

NS_ASSUME_NONNULL_END
