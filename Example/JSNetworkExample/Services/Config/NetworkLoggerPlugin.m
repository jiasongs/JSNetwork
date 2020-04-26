//
//  NetworkLoggerPlugin.m
//  JSNetwork
//
//  Created by jiasong on 2020/4/19.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import "NetworkLoggerPlugin.h"
#import <JSNetworkInterfaceProtocol.h>

@implementation NetworkLoggerPlugin

- (void)requestWillStart:(id<JSNetworkInterfaceProtocol>)interface {
    NSLog(@"requestWillStart - ");
}

- (void)requestDidStart:(id<JSNetworkInterfaceProtocol>)interface {
    NSLog(@"requestDidStart - ");
}

- (void)requestWillStop:(id<JSNetworkInterfaceProtocol>)interface {
    NSLog(@"requestWillStop - ");
}

- (void)requestDidStop:(id<JSNetworkInterfaceProtocol>)interface {
    NSLog(@"requestDidStop - ");
}

@end
