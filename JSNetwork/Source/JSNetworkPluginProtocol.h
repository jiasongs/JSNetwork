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

- (void)requestWillStart:(id<JSNetworkRequestProtocol>)request;
- (void)requestDidStart:(id<JSNetworkRequestProtocol>)request;
- (void)requestWillStop:(id<JSNetworkRequestProtocol>)request;
- (void)requestDidStop:(id<JSNetworkRequestProtocol>)request;

@end

NS_ASSUME_NONNULL_END
