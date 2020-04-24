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
 *  @brief 处理一个接口
 *
 *  @param interface 遵循<JSNetworkInterfaceProtocol>的接口类
 *
 */
- (void)processingInterface:(id<JSNetworkInterfaceProtocol>)interface;

@end

@interface JSNetworkAgent (Plugin)

- (void)toggleWillStartWithInterface:(id<JSNetworkInterfaceProtocol>)interface;
- (void)toggleDidStartWithInterface:(id<JSNetworkInterfaceProtocol>)interface;
- (void)toggleWillStopWithInterface:(id<JSNetworkInterfaceProtocol>)interface;
- (void)toggleDidStopWithInterface:(id<JSNetworkInterfaceProtocol>)interface;

@end

NS_ASSUME_NONNULL_END
