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
 *  @brief 根据task得到一个请求
 *
 *  @param task NSURLSessionTask
 * @retutn JSNetworkRequestProtocol
 */
- (nullable id<JSNetworkRequestProtocol>)getRequestWithTask:(NSURLSessionTask *)task;

/**
*  @brief 处理一个请求，该请求被处理后自动执行'- (void)addRequest:'
*
*  @param request 遵循<JSNetworkRequestProtocol>的请求类
*/
- (void)processingRequest:(id<JSNetworkRequestProtocol>)request;

/**
 *  @brief 处理task完成后的响应并且执行回调。完成后自动执行'- (void)removeRequest:'
 *
 *  @param task NSURLSessionTask
 *  @param responseObject 响应数据
 *  @param error 错误
 *
 *  @see JSNetworkProvider.m
 */
- (void)processingResponseWithTask:(NSURLSessionTask *)task
                              responseObject:(nullable id)responseObject
                                       error:(nullable NSError *)error;

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

@end

@interface JSNetworkAgent (Plugin)

- (void)toggleWillStartWithPlugins:(NSArray *)plugins request:(id<JSNetworkRequestProtocol>)request;
- (void)toggleDidStartWithPlugins:(NSArray *)plugins request:(id<JSNetworkRequestProtocol>)request;
- (void)toggleWillStopWithPlugins:(NSArray *)plugins request:(id<JSNetworkRequestProtocol>)request;
- (void)toggleDidStopWithPlugins:(NSArray *)plugins request:(id<JSNetworkRequestProtocol>)request;

@end

NS_ASSUME_NONNULL_END
