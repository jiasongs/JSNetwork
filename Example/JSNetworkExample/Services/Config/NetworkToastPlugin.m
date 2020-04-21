//
//  NetworkToastPlugin.m
//  JSNetwork
//
//  Created by jiasong on 2020/4/19.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import "NetworkToastPlugin.h"
#import <JSNetworkResponseProtocol.h>
#import <JSNetworkRequestProtocol.h>
#import <QMUITips.h>

@implementation NetworkToastPlugin

- (void)requestWillStart:(id<JSNetworkRequestProtocol>)request {
    dispatch_async(dispatch_get_main_queue(), ^{
        [QMUITips showLoading:@"正在请求" inView:UIApplication.sharedApplication.delegate.window];
    });
}

- (void)requestDidStop:(id<JSNetworkRequestProtocol>)request  {
    dispatch_async(dispatch_get_main_queue(), ^{
        [QMUITips hideAllTips];
        if (!request.response.error) {
            [QMUITips showSucceed:@"请求成功！"];
        } else {
            [QMUITips showError:request.response.error.localizedDescription];
        }
    });
}

@end
