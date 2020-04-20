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

+ (id<JSNetworkRequestProtocol>)requestWithConfig:(id<JSNetworkRequestConfigProtocol>)config {
    return [self request:JSNetworkRequest.new withConfig:config uploadProgress:nil downloadProgress:nil completed:nil];
}

+ (id<JSNetworkRequestProtocol>)requestwithConfig:(id<JSNetworkRequestConfigProtocol>)config
                                        completed:(nullable JSNetworkRequestCompletedFilter)completed {
    return [self request:JSNetworkRequest.new withConfig:config uploadProgress:nil downloadProgress:nil completed:completed];
}

+ (id<JSNetworkRequestProtocol>)requestWithConfig:(id<JSNetworkRequestConfigProtocol>)config
                                   uploadProgress:(nullable JSNetworkProgressBlock)uploadProgress
                                        completed:(nullable JSNetworkRequestCompletedFilter)completed {
    return [self request:JSNetworkRequest.new withConfig:config uploadProgress:uploadProgress downloadProgress:nil completed:completed];
}

+ (id<JSNetworkRequestProtocol>)requestWithConfig:(id<JSNetworkRequestConfigProtocol>)config
                                 downloadProgress:(nullable JSNetworkProgressBlock)downloadProgress
                                        completed:(nullable JSNetworkRequestCompletedFilter)completed {
    return [self request:JSNetworkRequest.new withConfig:config uploadProgress:nil downloadProgress:downloadProgress completed:completed];
}

+ (id<JSNetworkRequestProtocol>)requestWithConfig:(id<JSNetworkRequestConfigProtocol>)config
                                   uploadProgress:(nullable JSNetworkProgressBlock)uploadProgress
                                 downloadProgress:(nullable JSNetworkProgressBlock)downloadProgress
                                        completed:(nullable JSNetworkRequestCompletedFilter)completed {
    return [self request:JSNetworkRequest.new withConfig:config uploadProgress:uploadProgress downloadProgress:downloadProgress completed:completed];
}

+ (id<JSNetworkRequestProtocol>)request:(__kindof NSOperation<JSNetworkRequestProtocol> *)request
                             withConfig:(id<JSNetworkRequestConfigProtocol>)config
                              completed:(nullable JSNetworkRequestCompletedFilter)completed {
    return [self request:request withConfig:config uploadProgress:nil downloadProgress:nil completed:completed];
}

+ (id<JSNetworkRequestProtocol>)request:(__kindof NSOperation<JSNetworkRequestProtocol> *)request
                             withConfig:(id<JSNetworkRequestConfigProtocol>)config
                         uploadProgress:(nullable JSNetworkProgressBlock)uploadProgress
                              completed:(nullable JSNetworkRequestCompletedFilter)completed {
    return [self request:request withConfig:config uploadProgress:uploadProgress downloadProgress:nil completed:completed];
}

+ (id<JSNetworkRequestProtocol>)request:(__kindof NSOperation<JSNetworkRequestProtocol> *)request
                             withConfig:(id<JSNetworkRequestConfigProtocol>)config
                       downloadProgress:(nullable JSNetworkProgressBlock)downloadProgress
                              completed:(nullable JSNetworkRequestCompletedFilter)completed {
    return [self request:request withConfig:config uploadProgress:nil downloadProgress:downloadProgress completed:completed];
}

+ (id<JSNetworkRequestProtocol>)request:(__kindof NSOperation<JSNetworkRequestProtocol> *)request
                             withConfig:(id<JSNetworkRequestConfigProtocol>)config
                         uploadProgress:(nullable JSNetworkProgressBlock)uploadProgress
                       downloadProgress:(nullable JSNetworkProgressBlock)downloadProgress
                              completed:(nullable JSNetworkRequestCompletedFilter)completed {
    NSParameterAssert(request);
    NSParameterAssert(config);
    JSNetworkInterface *interface = [[JSNetworkInterface alloc] initWithRequestConfig:config];
    [request buildTaskWithInterface:interface taskCompleted:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
        /// 处理响应和回调之后移除
        [JSNetworkAgent.sharedInstance processingResponseWithTask:task responseObject:responseObject error:error];
    }];
    [request requestUploadProgress:uploadProgress];
    [request requestDownloadProgress:downloadProgress];
    [request requestCompletedFilter:completed];
    /// 处理请求
    [JSNetworkAgent.sharedInstance processingRequest:request];
    return request;
}

@end
