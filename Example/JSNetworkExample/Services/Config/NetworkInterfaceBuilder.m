//
//  NetworkInterfaceBuilder.m
//  JSNetworkExample
//
//  Created by jiasong on 2023/1/18.
//  Copyright © 2023 jiasong. All rights reserved.
//

#import "NetworkInterfaceBuilder.h"
#import <JSNetwork/JSNetwork.h>
#import "NetworkResponse.h"

@implementation NetworkInterfaceBuilder

- (id<JSNetworkInterfaceProtocol>)buildWithConfig:(id<JSNetworkRequestConfigProtocol>)config {
    JSNetworkInterface *interface = [[JSNetworkInterface alloc] init];
    interface.request = [[JSNetworkAFRequest alloc] init];
    interface.response = [[NetworkResponse alloc] init];
    return interface;
}

@end
