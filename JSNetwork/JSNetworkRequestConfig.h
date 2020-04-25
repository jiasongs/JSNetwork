//
//  JSNetworkRequestConfig.h
//  AFNetworking
//
//  Created by jiasong on 2020/4/24.
//

#import <Foundation/Foundation.h>
#import "JSNetworkRequestConfigProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface JSNetworkRequestConfig : NSObject <JSNetworkRequestConfigProtocol>

/**
 *  @brief 根据config初始化一个JSNetworkRequestConfig
 *
 *  @param config JSNetworkRequestConfigProtocol
 */
- (instancetype)initWithConfig:(id<JSNetworkRequestConfigProtocol>)config;

@end

NS_ASSUME_NONNULL_END
