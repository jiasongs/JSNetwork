//
//  JSNetworkLoggerPlugin.m
//  JSNetwork
//
//  Created by jiasong on 2020/4/19.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import "JSNetworkLoggerPlugin.h"
#import "JSNetworkPluginProtocol.h"
#import "JSNetworkRequest.h"

@implementation JSNetworkLoggerPlugin

- (void)requestWillStart:(id<JSNetworkRequestProtocol>)request {
    NSLog(@"requestWillStart - ");
}

- (void)requestDidStart:(id<JSNetworkRequestProtocol>)request {
     NSLog(@"requestDidStart - ");
}

- (void)requestWillStop:(id<JSNetworkRequestProtocol>)request {
     NSLog(@"requestWillStop - ");
}

- (void)requestDidStop:(id<JSNetworkRequestProtocol>)request {
    NSLog(@"requestDidStop - ");
}

@end
