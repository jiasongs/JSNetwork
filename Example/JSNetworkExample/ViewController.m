//
//  ViewController.m
//  JSNetworkExample
//
//  Created by jiasong on 2020/4/21.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import "ViewController.h"
#import <JSNetwork.h>
#import <AFNetworking.h>
#import "NetworkLoggerPlugin.h"
#import "NetworkResponse.h"
#import "NetworkRequest.h"
#import "CNodeAPI.h"
#import "DownloadAPI.h"
#import "UploadImageAPI.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    /// 全局配置
    JSNetworkConfig.sharedConfig.debugLogEnabled = true;
    JSNetworkConfig.sharedConfig.requestClass = NetworkRequest.class;
    JSNetworkConfig.sharedConfig.responseClass = NetworkResponse.class;
    [JSNetworkConfig.sharedConfig addUrlFilterArguments:@{@"app": @"1.0.0", @"token": @"token"}];
    [JSNetworkConfig.sharedConfig addUrlFilterArguments:@{@"other": @"other"}];
    [JSNetworkConfig.sharedConfig addHTTPHeaderFields:@{@"userName": @"123"}];
    [JSNetworkConfig.sharedConfig addPlugin:NetworkLoggerPlugin.new];
}

- (IBAction)onPressRequest:(id)sender {
    CNodeAPI *api = [CNodeAPI new];
    /// 生成接口
    [JSNetworkProvider requestWithConfig:api
                               completed:^(id<JSNetworkInterfaceProtocol> aInterface) {
        NSLog(@"%@", aInterface);
    }];
}

- (IBAction)onPressUpload:(id)sender {
    UploadImageAPI *api = [[UploadImageAPI alloc] init];
    [JSNetworkProvider requestWithConfig:api
                          uploadProgress:^(NSProgress *uploadProgress) {
        NSLog(@"uploadProgress - %@", uploadProgress);
    } completed:^(id<JSNetworkInterfaceProtocol> aInterface) {
        NSLog(@"%@", aInterface);
    }];
}

- (IBAction)onPressDownload:(id)sender {
    /// 生成接口
    DownloadAPI *api = [DownloadAPI apiWithDownloadURLType:DownloadURLTypeTypeCachefly];
    [JSNetworkProvider requestWithConfig:api
                        downloadProgress:^(NSProgress *downloadProgress) {
        NSLog(@"downloadProgress - %@", downloadProgress);
    } completed:^(id<JSNetworkInterfaceProtocol> aInterface) {
        NSLog(@"%@", aInterface);
    }];
}

@end
