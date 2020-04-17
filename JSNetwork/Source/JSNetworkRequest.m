//
//  JSNetworkRequest.m
//  JSNetwork
//
//  Created by jiasong on 2020/4/17.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import "JSNetworkRequest.h"
#import <AFNetworking.h>
#import "JSNetworkResponse.h"

@implementation JSNetworkRequest

@synthesize requestConfig = _requestConfig;
@synthesize response = _response;

- (void)buildTaskWithRequestConfig:(id<JSNetworkRequestConfigProtocol>)config {
    _requestConfig = config;
}

- (void)start {
    
}

- (void)cancel {
    
}

/// 完成
- (void)requestCompleteFilter:(void(^)(void))completed {
    
}

/// 错误
- (void)requestFailedFilter:(void(^)(void))failed {
    
}

- (NSString *)taskIdentifier {
    return @"";
}

- (id<JSNetworkResponseProtocol>)response {
    if (!_response) {
        _response = JSNetworkResponse.new;
    }
    return _response;
}

- (id<JSNetworkRequestConfigProtocol>)requestConfig {
    return _requestConfig;
}

@end
