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

//@property (nonatomic, strong) id<JSNetworkRequestProtocol> request;

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    static BOOL marker = false;
    if (!marker) {
        [FBLPromise setDefaultDispatchQueue:dispatch_queue_create("com.promise", DISPATCH_QUEUE_CONCURRENT)];
        /// 全局配置
        JSNetworkConfig.sharedInstance.debugLogEnabled = true;
        [JSNetworkConfig.sharedInstance addUrlFilterArguments:@{@"app": @"1.0.0", @"token": @"123456"}];
        [JSNetworkConfig.sharedInstance addHTTPHeaderFields:@{@"userName": @"123"}];
        [JSNetworkConfig.sharedInstance addPlugin:NetworkLoggerPlugin.new];
        JSNetworkConfig.sharedInstance.responseClass = NetworkResponse.class;
        marker = true;
    }
    [self onPress:nil];
}

- (IBAction)onPress:(nullable id)sender {
    /// 发起请求
    CnodeAPI *api = [CnodeAPI new];
    [JSNetworkProvider requestwithConfig:api completed:^(id<JSNetworkRequestProtocol> aRequest) {
        NetworkResponse *response = aRequest.response;
        NSLog(@"requestCompletedFilter - %@", response);
    }];
//    [[JSNetworkProvider promiseRequestWithConfig:api] then:^id(id<JSNetworkRequestProtocol> aRequest) {
//        NetworkResponse *response = aRequest.response;
//        NSLog(@"requestCompletedFilter - %@", response);
//        return nil;
//    }];
}

- (void)dealloc {
    NSLog(@"TestViewController - 已经释放");
}

@end
