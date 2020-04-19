//
//  TestViewController.m
//  JSNetwork
//
//  Created by jiasong on 2020/4/18.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import "TestViewController.h"
#import "JSNetwork.h"
#import "CnodeAPI.h"
#import "NetworkToastPlugin.h"
#import "NetworkLoggerPlugin.h"
#import "NetworkResponse.h"
#import "JSNetworkProvider+Promises.h"

@interface TestViewController ()

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    static BOOL marker = false;
    if (!marker) {
        /// 全局配置
        JSNetworkConfig.sharedInstance.debugLogEnabled = true;
        [JSNetworkConfig.sharedInstance addUrlFilterArguments:@{@"app": @"1.0.0", @"token": @"123456"}];
        [JSNetworkConfig.sharedInstance addHTTPHeaderFields:@{@"userName": @"123"}];
        [JSNetworkConfig.sharedInstance addPlugins:NetworkLoggerPlugin.new];
        JSNetworkConfig.sharedInstance.responseClass = NetworkResponse.class;
        marker = true;
    }
    [self onPress:nil];
}

- (void)dealloc {
    NSLog(@"TestViewController - 已经释放");
}

- (IBAction)onPress:(nullable id)sender {
    /// 发起请求
    CnodeAPI *api = [CnodeAPI new];
    [[JSNetworkProvider requestWithConfig:api uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"uploadProgress - %@", uploadProgress);
    } downloadProgress:^(NSProgress * downloadProgress) {
        NSLog(@"requestDownloadProgress - %@", downloadProgress);
    }] then:^id (id<JSNetworkRequestProtocol> value) {
        NetworkResponse *response = value.response;
        NSLog(@"requestCompletedFilter - %@", response);
        return nil;
    }];
}

@end
