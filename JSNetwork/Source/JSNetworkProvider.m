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

+ (id<JSNetworkRequestProtocol>)request:(id<JSNetworkRequestProtocol>)request
                             withConfig:(id<JSNetworkRequestConfigProtocol>)config
                              completed:(nullable JSNetworkRequestCompletedFilter)completed {
    return [self request:request withConfig:config uploadProgress:nil downloadProgress:nil completed:completed];
}

+ (id<JSNetworkRequestProtocol>)request:(id<JSNetworkRequestProtocol>)request
                             withConfig:(id<JSNetworkRequestConfigProtocol>)config
                         uploadProgress:(nullable JSNetworkProgressBlock)uploadProgress
                              completed:(nullable JSNetworkRequestCompletedFilter)completed {
    return [self request:request withConfig:config uploadProgress:uploadProgress downloadProgress:nil completed:completed];
}

+ (id<JSNetworkRequestProtocol>)request:(id<JSNetworkRequestProtocol>)request
                             withConfig:(id<JSNetworkRequestConfigProtocol>)config
                       downloadProgress:(nullable JSNetworkProgressBlock)downloadProgress
                              completed:(nullable JSNetworkRequestCompletedFilter)completed {
    return [self request:request withConfig:config uploadProgress:nil downloadProgress:downloadProgress completed:completed];
}

+ (id<JSNetworkRequestProtocol>)request:(id<JSNetworkRequestProtocol>)request
                             withConfig:(id<JSNetworkRequestConfigProtocol>)config
                         uploadProgress:(nullable JSNetworkProgressBlock)uploadProgress
                       downloadProgress:(nullable JSNetworkProgressBlock)downloadProgress
                              completed:(nullable JSNetworkRequestCompletedFilter)completed {
    NSParameterAssert(request);
    NSParameterAssert(config);
    JSNetworkInterface *interface = [[JSNetworkInterface alloc] initWithRequestConfig:config];
    [request buildTaskWithInterface:interface taskCompleted:^(id<JSNetworkRequestProtocol> aRequest, id responseObject, NSError *error) {
        [JSNetworkAgent.sharedInstance handleTaskWithRequest:aRequest responseObject:responseObject error:error];
        [JSNetworkAgent.sharedInstance removeRequest:aRequest];
    }];
    [request requestUploadProgress:uploadProgress];
    [request requestDownloadProgress:downloadProgress];
    [request requestCompletedFilter:completed];
    [JSNetworkAgent.sharedInstance addRequest:request];
    return request;
}

@end
