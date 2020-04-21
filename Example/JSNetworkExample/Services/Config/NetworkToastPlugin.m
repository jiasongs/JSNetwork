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
#import <JSNetworkInterfaceProtocol.h>
#import <QMUITips.h>

@implementation NetworkToastPlugin

- (void)requestWillStart:(id<JSNetworkInterfaceProtocol>)interface {
    dispatch_async(dispatch_get_main_queue(), ^{
        [QMUITips showLoading:@"正在请求" inView:UIApplication.sharedApplication.delegate.window];
    });
}

- (void)requestDidStop:(id<JSNetworkInterfaceProtocol>)interface {
     dispatch_async(dispatch_get_main_queue(), ^{
           [QMUITips hideAllTips];
           if (!interface.response.error) {
               [QMUITips showSucceed:@"请求成功！"];
           } else {
               [QMUITips showError:interface.response.error.localizedDescription];
           }
       });
}

@end
