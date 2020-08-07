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
    JSNetworkConfig.sharedConfig.requestMaxConcurrentCount = 3;
    [JSNetworkConfig.sharedConfig addUrlFilterArguments:@{@"app": @"1.0.0", @"token": @"token"}];
    [JSNetworkConfig.sharedConfig addUrlFilterArguments:@{@"other": @"other"}];
    [JSNetworkConfig.sharedConfig addHTTPHeaderFields:@{@"userName": @"123"}];
    [JSNetworkConfig.sharedConfig addPlugin:NetworkLoggerPlugin.new];
}

- (IBAction)onPressRequest:(id)sender {
    void (^test)(void) = ^(void) {
        CNodeAPI *api = [CNodeAPI new];
        /// 生成接口
        [JSNetworkProvider requestWithConfig:api
                                   completed:^(id<JSNetworkInterfaceProtocol> aInterface) {
            NSLog(@"%@", aInterface);
        }];
    };
    /// 测试
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        test();
    });
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        test();
    });
}

- (IBAction)onPressBatch:(id)sender {
    /// 暂未封装
    dispatch_group_t group = dispatch_group_create();
    for (int i = 0; i < 10; i++) {
        CNodeAPI *api = [CNodeAPI new];
        dispatch_group_enter(group);
        [JSNetworkProvider requestWithConfig:api
                                   completed:^(id<JSNetworkInterfaceProtocol> aInterface) {
            NSLog(@"%@", aInterface);
            dispatch_group_leave(group);
        }];
    }
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"全部请求完毕");
    });
}

- (IBAction)onPressChain:(id)sender {
    /// 暂未封装
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        for (int i = 0; i < 10; i++) {
            CNodeAPI *api = [CNodeAPI new];
            [JSNetworkProvider requestWithConfig:api
                                       completed:^(id<JSNetworkInterfaceProtocol> aInterface) {
                NSLog(@"%@", aInterface);
                dispatch_semaphore_signal(semaphore);
            }];
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        }
    });
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
