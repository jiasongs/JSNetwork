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

+ (FBLPromise<id<JSNetworkRequestProtocol>> *)promiseRequestWithConfig:(id<JSNetworkRequestConfigProtocol>)config {
    return [self promiseRequest:JSNetworkRequest.new withConfig:config uploadProgress:nil downloadProgress:nil];
}

+ (FBLPromise<id<JSNetworkRequestProtocol>> *)promiseRequestWithConfig:(id<JSNetworkRequestConfigProtocol>)config downloadProgress:(nullable void (^)(NSProgress *downloadProgress))downloadProgress {
    return [self promiseRequest:JSNetworkRequest.new withConfig:config uploadProgress:nil downloadProgress:downloadProgress];
}

+ (FBLPromise<id<JSNetworkRequestProtocol>> *)promiseRequestWithConfig:(id<JSNetworkRequestConfigProtocol>)config uploadProgress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress {
    return [self promiseRequest:JSNetworkRequest.new withConfig:config uploadProgress:uploadProgress downloadProgress:nil];
}

+ (FBLPromise<id<JSNetworkRequestProtocol>> *)promiseRequestWithConfig:(id<JSNetworkRequestConfigProtocol>)config uploadProgress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress downloadProgress:(nullable void (^)(NSProgress *downloadProgress))downloadProgress {
    return [self promiseRequest:JSNetworkRequest.new withConfig:config uploadProgress:uploadProgress downloadProgress:downloadProgress];
}

+ (FBLPromise<id<JSNetworkRequestProtocol>> *)promiseRequest:(__kindof NSOperation<JSNetworkRequestProtocol> *)request
                                           withConfig:(id<JSNetworkRequestConfigProtocol>)config {
    return [JSNetworkProvider promiseRequest:request withConfig:config uploadProgress:nil downloadProgress:nil];
}


+ (FBLPromise<id<JSNetworkRequestProtocol>> *)promiseRequest:(__kindof NSOperation<JSNetworkRequestProtocol> *)request
                                           withConfig:(id<JSNetworkRequestConfigProtocol>)config downloadProgress:(nullable void (^)(NSProgress *downloadProgress))downloadProgress {
    return [JSNetworkProvider promiseRequest:request withConfig:config uploadProgress:nil downloadProgress:downloadProgress];
}

+ (FBLPromise<id<JSNetworkRequestProtocol>> *)promiseRequest:(__kindof NSOperation<JSNetworkRequestProtocol> *)request
                                           withConfig:(id<JSNetworkRequestConfigProtocol>)config uploadProgress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress {
    return [JSNetworkProvider promiseRequest:request withConfig:config uploadProgress:uploadProgress downloadProgress:nil];
}

+ (FBLPromise<id<JSNetworkRequestProtocol>> *)promiseRequest:(__kindof NSOperation<JSNetworkRequestProtocol> *)request
                                           withConfig:(id<JSNetworkRequestConfigProtocol>)config uploadProgress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress downloadProgress:(nullable void (^)(NSProgress *downloadProgress))downloadProgress {
    FBLPromise *promise = [FBLPromise pendingPromise];
    [JSNetworkProvider request:request withConfig:config uploadProgress:uploadProgress downloadProgress:downloadProgress completed:^(id<JSNetworkRequestProtocol> aRequest) {
        [promise fulfill:aRequest];
    }];
    return promise;
}

@end
