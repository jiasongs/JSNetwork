//
//  JSNetworkResponseProtocol.h
//  JSNetwork
//
//  Created by jiasong on 2020/4/17.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol JSNetworkRequestProtocol;

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
 *  @brief 原始的响应
 */
- (NSHTTPURLResponse *)originalResponse;

/**
 *  @brief 状态码
 */
- (NSInteger)responseStatusCode;

/**
 *  @brief 响应头
 */
- (NSDictionary *)responseHeaders;

/**
 *  @brief 响应数据
 */
- (id)responseObject;

/**
 *  @brief 错误
 */
- (NSError *)error;

@end

NS_ASSUME_NONNULL_END
