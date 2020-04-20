//
//  BaseAPI.m
//  JSNetwork
//
//  Created by jiasong on 2020/4/19.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import "BaseAPI.h"
#import "NetworkToastPlugin.h"
#import "NetworkResponse.h"

@interface BaseAPI ()

@property (nonatomic, strong) NSArray *plugins;

@end

@implementation BaseAPI

- (NSString *)requestUrl {
    return @"";
}

- (NSArray<id<JSNetworkPluginProtocol>> *)requestPlugins {
    if (!_plugins) {
        _plugins = @[NetworkToastPlugin.new];
    }
    return _plugins;
}

@end
