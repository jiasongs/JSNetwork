//
//  JSNetworkProvider.m
//  JSNetwork
//
//  Created by jiasong on 2020/4/17.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import "JSNetworkProvider.h"
#import "JSNetworkAgent.h"
#import "JSNetworkRequest.h"

@implementation JSNetworkProvider

+ (void)requestConfig:(id<JSNetworkRequestConfigProtocol>)config complete:(JSRequestCompletionBlock)complete {
    JSNetworkRequest *request = [JSNetworkRequest new];
    [self request:request requestConfig:config complete:complete];
}

+ (void)request:(id<JSNetworkRequestProtocol>)request requestConfig:(id<JSNetworkRequestConfigProtocol>)config complete:(JSRequestCompletionBlock)complete {
    [request buildTaskWithRequestConfig:config];
    [JSNetworkAgent.sharedInstance addRequest:request];
}

@end
