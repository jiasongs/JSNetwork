//
//  BaseAPI.m
//  JSNetwork
//
//  Created by jiasong on 2020/4/19.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import "BaseAPI.h"
#import "NetworkToastPlugin.h"

@interface BaseAPI ()

@end

@implementation BaseAPI

- (NSString *)requestURLString {
    return @"";
}

- (NSArray<id<JSNetworkPluginProtocol>> *)requestPlugins {
    return @[];
//    return @[NetworkToastPlugin.new];
}

@end
