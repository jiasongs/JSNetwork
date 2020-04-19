//
//  TestViewController.m
//  JSNetwork
//
//  Created by jiasong on 2020/4/18.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import "TestViewController.h"
#import "JSNetwork.h"
#import "CnodeApi.h"

@interface TestViewController ()

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    JSNetworkConfig.sharedInstance.debugLogEnabled = true;
    [JSNetworkConfig.sharedInstance addUrlFilterArguments:@{@"app": @"1.0.0", @"token": @"123456"}];
    [JSNetworkConfig.sharedInstance addHTTPHeaderFields:@{@"userName": @"123"}];
    CnodeApi *api = [CnodeApi new];
    [JSNetworkProvider requestWithConfig:api uploadProgress:^(NSProgress *uploadProgress) {
        NSLog(@"uploadProgress - %@", uploadProgress);
    } downloadProgress:^(NSProgress *downloadProgress) {
        NSLog(@"requestDownloadProgress - %@", downloadProgress);
    } completed:^(id<JSNetworkRequestProtocol> aRequest) {
        NSLog(@"requestCompletedFilter - %@", aRequest);
    }];
}

- (void)dealloc {
    NSLog(@"TestViewController - 已经释放");
}

- (IBAction)onPress:(id)sender {
    
}

@end
