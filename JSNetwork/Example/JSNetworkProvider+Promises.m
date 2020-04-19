//
//  JSNetworkProvider+Promises.m
//  JSNetwork
//
//  Created by jiasong on 2020/4/19.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import "JSNetworkProvider+Promises.h"
#import "JSNetworkRequest.h"

@implementation JSNetworkProvider (Promises)

+ (FBLPromise<id<JSNetworkRequestProtocol>> *)requestWithConfig:(id<JSNetworkRequestConfigProtocol>)config {
    return [self request:JSNetworkRequest.new withConfig:config uploadProgress:nil downloadProgress:nil];
}

+ (FBLPromise<id<JSNetworkRequestProtocol>> *)requestWithConfig:(id<JSNetworkRequestConfigProtocol>)config downloadProgress:(nullable void (^)(NSProgress *downloadProgress))downloadProgress {
    return [self request:JSNetworkRequest.new withConfig:config uploadProgress:nil downloadProgress:downloadProgress];
}

+ (FBLPromise<id<JSNetworkRequestProtocol>> *)requestWithConfig:(id<JSNetworkRequestConfigProtocol>)config uploadProgress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress {
    return [self request:JSNetworkRequest.new withConfig:config uploadProgress:uploadProgress downloadProgress:nil];
}

+ (FBLPromise<id<JSNetworkRequestProtocol>> *)requestWithConfig:(id<JSNetworkRequestConfigProtocol>)config uploadProgress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress downloadProgress:(nullable void (^)(NSProgress *downloadProgress))downloadProgress {
    return [self request:JSNetworkRequest.new withConfig:config uploadProgress:uploadProgress downloadProgress:downloadProgress];
}

+ (FBLPromise<id<JSNetworkRequestProtocol>> *)request:(id<JSNetworkRequestProtocol>)request
                                           withConfig:(id<JSNetworkRequestConfigProtocol>)config {
    return [JSNetworkProvider request:request withConfig:config uploadProgress:nil downloadProgress:nil];
}


+ (FBLPromise<id<JSNetworkRequestProtocol>> *)request:(id<JSNetworkRequestProtocol>)request
                                           withConfig:(id<JSNetworkRequestConfigProtocol>)config downloadProgress:(nullable void (^)(NSProgress *downloadProgress))downloadProgress {
    return [JSNetworkProvider request:request withConfig:config uploadProgress:nil downloadProgress:downloadProgress];
}

+ (FBLPromise<id<JSNetworkRequestProtocol>> *)request:(id<JSNetworkRequestProtocol>)request
                                           withConfig:(id<JSNetworkRequestConfigProtocol>)config uploadProgress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress {
    return [JSNetworkProvider request:request withConfig:config uploadProgress:uploadProgress downloadProgress:nil];
}

+ (FBLPromise<id<JSNetworkRequestProtocol>> *)request:(id<JSNetworkRequestProtocol>)request
                                           withConfig:(id<JSNetworkRequestConfigProtocol>)config uploadProgress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress downloadProgress:(nullable void (^)(NSProgress *downloadProgress))downloadProgress {
    FBLPromise *promise = [FBLPromise pendingPromise];
    [JSNetworkProvider request:request withConfig:config uploadProgress:uploadProgress downloadProgress:downloadProgress completed:^(id<JSNetworkRequestProtocol> aRequest) {
        [promise fulfill:aRequest];
    }];
    return promise;
}

@end
