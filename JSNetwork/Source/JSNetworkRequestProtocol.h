//
//  JSNetworkRequestProtocol.h
//  JSNetwork
//
//  Created by jiasong on 2020/4/17.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSNetworkRequestConfigProtocol.h"
#import "JSNetworkResponseProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@protocol JSNetworkRequestProtocol <NSObject>

@property (nonatomic, strong, readonly) id<JSNetworkRequestConfigProtocol> requestConfig;
@property (nonatomic, strong, readonly) id<JSNetworkResponseProtocol> response;

/// 这个协议要实现什么内容呢
/// 构造请求类
- (void)buildTaskWithRequestConfig:(id<JSNetworkRequestConfigProtocol>)config;
/// 开始
- (void)start;
/// 取消
- (void)cancel;
/// 完成
- (void)requestCompleteFilter:(void (^)(void))completed;
/// 错误
- (void)requestFailedFilter:(void (^)(void))failed;
/// 唯一ID
- (NSString *)taskIdentifier;

@end

NS_ASSUME_NONNULL_END
