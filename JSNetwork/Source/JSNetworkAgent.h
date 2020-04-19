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

NS_ASSUME_NONNULL_BEGIN

@interface JSNetworkAgent : NSObject

+ (instancetype)sharedInstance;

/**
 *  @brief 添加一个请求，该请求被添加后执行 '- (void)start'
 *
 *  @param request 遵循<JSNetworkRequestProtocol>的请求类
 */
- (void)addRequest:(id<JSNetworkRequestProtocol>)request;

/**
 *  @brief 移除一个请求，该请求如果没有结束，则先执行 '- (void)cancel'
 *
 *  @param request 遵循<JSNetworkRequestProtocol>的请求类
 */
- (void)removeRequest:(id<JSNetworkRequestProtocol>)request;

/**
 *  @brief 处理task完成后的响应，再removeRequest之前调用
 *
 *  @param request 遵循<JSNetworkRequestProtocol>的请求类
 *  @param responseObject 响应数据
 *  @param error 错误
 *
 *  @see JSNetworkProvider.m
 */
- (void)handleTaskWithRequest:(id<JSNetworkRequestProtocol>)request responseObject:(nullable id)responseObject error:(nullable NSError *)error;

@end

@interface JSNetworkAgent (Plugin)

- (NSArray *)getAllPluginsWithRequest:(id<JSNetworkRequestProtocol>)request;
- (void)toggleWillStartWithPlugins:(NSArray *)plugins request:(id<JSNetworkRequestProtocol>)request;
- (void)toggleDidStartWithPlugins:(NSArray *)plugins request:(id<JSNetworkRequestProtocol>)request;
- (void)toggleWillStopWithPlugins:(NSArray *)plugins request:(id<JSNetworkRequestProtocol>)request;
- (void)toggleDidStopWithPlugins:(NSArray *)plugins request:(id<JSNetworkRequestProtocol>)request;

@end

NS_ASSUME_NONNULL_END
