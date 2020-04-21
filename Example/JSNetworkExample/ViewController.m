//
//  ViewController.m
//  JSNetworkExample
//
//  Created by jiasong on 2020/4/21.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import "ViewController.h"
#import <JSNetwork.h>
#import "NetworkLoggerPlugin.h"
#import "NetworkResponse.h"
#import "NetworkRequest.h"
#import "CNodeAPI.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    /// 全局配置
    JSNetworkConfig.sharedConfig.requestClass = NetworkRequest.class;
    JSNetworkConfig.sharedConfig.responseClass = NetworkResponse.class;
    JSNetworkConfig.sharedConfig.debugLogEnabled = true;
    [JSNetworkConfig.sharedConfig addUrlFilterArguments:@{@"app": @"1.0.0", @"token": @"token"}];
    [JSNetworkConfig.sharedConfig addUrlFilterArguments:@{@"other": @"other"}];
    [JSNetworkConfig.sharedConfig addHTTPHeaderFields:@{@"userName": @"123"}];
    [JSNetworkConfig.sharedConfig addPlugin:NetworkLoggerPlugin.new];
}

- (IBAction)onPressRequest:(id)sender {
    CNodeAPI *api = [CNodeAPI new];
    [JSNetworkProvider requestWithConfig:api completed:^(id<JSNetworkInterfaceProtocol> aInterface) {
        NetworkResponse *response = aInterface.response;
        NSLog(@"completed - %@", response);
    }];
}

@end
