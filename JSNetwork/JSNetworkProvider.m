//
//  JSNetworkProvider.m
//  JSNetwork
//
//  Created by jiasong on 2020/4/17.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import "JSNetworkProvider.h"
#import "JSNetworkAgent.h"
#import "JSNetworkRequest.h"
#import "JSNetworkInterface.h"
#import "JSNetworkRequestProtocol.h"

@implementation JSNetworkProvider

+ (id<JSNetworkInterfaceProtocol>)requestWithConfig:(id<JSNetworkRequestConfigProtocol>)config {
    return [self requestWithConfig:config uploadProgress:nil downloadProgress:nil completed:nil];
}

+ (id<JSNetworkInterfaceProtocol>)requestWithConfig:(id<JSNetworkRequestConfigProtocol>)config
                                        completed:(nullable JSNetworkRequestCompletedFilter)completed {
    return [self requestWithConfig:config uploadProgress:nil downloadProgress:nil completed:completed];
}

+ (id<JSNetworkInterfaceProtocol>)requestWithConfig:(id<JSNetworkRequestConfigProtocol>)config
                                   uploadProgress:(nullable JSNetworkProgressBlock)uploadProgress
                                        completed:(nullable JSNetworkRequestCompletedFilter)completed {
    return [self requestWithConfig:config uploadProgress:uploadProgress downloadProgress:nil completed:completed];
}

+ (id<JSNetworkInterfaceProtocol>)requestWithConfig:(id<JSNetworkRequestConfigProtocol>)config
                                 downloadProgress:(nullable JSNetworkProgressBlock)downloadProgress
                                        completed:(nullable JSNetworkRequestCompletedFilter)completed {
    return [self requestWithConfig:config uploadProgress:nil downloadProgress:downloadProgress completed:completed];
}

+ (id<JSNetworkInterfaceProtocol>)requestWithConfig:(id<JSNetworkRequestConfigProtocol>)config
                                   uploadProgress:(nullable JSNetworkProgressBlock)uploadProgress
                                 downloadProgress:(nullable JSNetworkProgressBlock)downloadProgress
                                        completed:(nullable JSNetworkRequestCompletedFilter)completed {
    NSParameterAssert(config);
    /// 生成接口
    JSNetworkInterface *interface = [[JSNetworkInterface alloc] initWithRequestConfig:config];
    /// 设置请求回调
    [interface.request requestUploadProgress:uploadProgress];
    [interface.request requestDownloadProgress:downloadProgress];
    [interface.request requestCompletedFilter:completed];
    /// 处理接口
    [JSNetworkAgent.sharedAgent processingInterface:interface];
    return interface;
}

@end
