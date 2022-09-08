
//
//  JSNetworkInterface.m
//  JSNetwork
//
//  Created by jiasong on 2020/4/18.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import "JSNetworkInterface.h"
#import "JSNetworkUtil.h"
#import "JSNetworkRequestConfigProtocol.h"

@implementation JSNetworkInterface
@synthesize config = _config;
@synthesize response = _response;
@synthesize request = _request;
@synthesize diskCache = _diskCache;
@synthesize uploadProgress = _uploadProgress;
@synthesize downloadProgress = _downloadProgress;
@synthesize completionHandler = _completionHandler;
@synthesize requestToken = _requestToken;
@synthesize taskIdentifier = _taskIdentifier;

- (void)dealloc {
    JSNetworkLog(@"%@ - 已经释放", NSStringFromClass([self class]));
    JSNetworkLog(@"%@ - 已经释放", NSStringFromClass([self.config class]));
}

@end
