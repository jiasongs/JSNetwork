//
//  JSNetworkResponseProtocol.h
//  JSNetwork
//
//  Created by jiasong on 2020/4/17.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol JSNetworkResponseProtocol <NSObject>

@required

/**
 *  @brief 处理task
 *
 *  @param task NSURLSessionTask
 *  @param responseObject 解析出的响应数据
 *  @param error 错误
 *
 */
- (void)processingTask:(NSURLSessionTask *)task responseObject:(nullable id)responseObject error:(nullable NSError *)error;

/**
 *  @brief URL
 */
- (nullable NSString *)responseURLString;

/**
 *  @brief 响应头
 */
- (nullable NSDictionary<NSString *, NSString *> *)responseHeaders;

/**
 *  @brief 状态码
 */
- (NSInteger)responseStatusCode;

/**
 *  @brief 响应数据
 */
- (nullable id)responseObject;

/**
 *  @brief 错误
 */
- (nullable NSError *)error;

/**
 *  @brief 原始的响应
 */
- (nullable NSHTTPURLResponse *)originalResponse;

/**
 *  @brief 网络连接是否异常
 */
- (BOOL)networkingAbnormal;

@end

NS_ASSUME_NONNULL_END
