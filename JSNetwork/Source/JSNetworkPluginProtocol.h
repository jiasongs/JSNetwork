//
//  JSNetworkPlugin.h
//  JSNetwork
//
//  Created by jiasong on 2020/4/17.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol JSNetworkPluginProtocol <NSObject>

@optional

- (void)requestWillStart:(id)request;
- (void)requestDidStart:(id)request;
- (void)requestWillStop:(id)request;
- (void)requestDidStop:(id)request;

@end

NS_ASSUME_NONNULL_END
