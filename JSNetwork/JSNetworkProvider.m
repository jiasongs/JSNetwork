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
#import "JSNetworkConfig.h"

@implementation JSNetworkProvider

+ (id<JSNetworkInterfaceProtocol>)requestWithConfig:(id<JSNetworkRequestConfigProtocol>)config
                                          completed:(nullable JSNetworkRequestCompletedFilter)completed {
    return [self requestWithConfig:config
                    uploadProgress:nil
                  downloadProgress:nil
                         completed:completed];
}

+ (id<JSNetworkInterfaceProtocol>)requestWithConfig:(id<JSNetworkRequestConfigProtocol>)config
                                     uploadProgress:(nullable JSNetworkProgressBlock)uploadProgress
                                          completed:(nullable JSNetworkRequestCompletedFilter)completed {
    return [self requestWithConfig:config
                    uploadProgress:uploadProgress
                  downloadProgress:nil
                         completed:completed];
}

+ (id<JSNetworkInterfaceProtocol>)requestWithConfig:(id<JSNetworkRequestConfigProtocol>)config
                                   downloadProgress:(nullable JSNetworkProgressBlock)downloadProgress
                                          completed:(nullable JSNetworkRequestCompletedFilter)completed {
    return [self requestWithConfig:config
                    uploadProgress:nil
                  downloadProgress:downloadProgress
                         completed:completed];
}

+ (id<JSNetworkInterfaceProtocol>)requestWithConfig:(id<JSNetworkRequestConfigProtocol>)config
                                     uploadProgress:(nullable JSNetworkProgressBlock)uploadProgress
                                   downloadProgress:(nullable JSNetworkProgressBlock)downloadProgress
                                          completed:(nullable JSNetworkRequestCompletedFilter)completed {
    NSParameterAssert(config);
    /// 生成接口
    JSNetworkInterface *interface = [[JSNetworkInterface alloc] initWithRequestConfig:config];
    /// 设置请求回调
    [interface requestUploadProgress:uploadProgress];
    [interface requestDownloadProgress:downloadProgress];
    [interface requestCompletedFilter:completed];
    /// 处理接口
    [JSNetworkAgent.sharedAgent addRequestForInterface:interface];
    return interface;
}

@end

#pragma mark - TODO

@interface JSNetworkProvider (TODO)

@end

@implementation JSNetworkProvider (TODO)

+ (void)_batchRequestWithConfigs:(NSArray<id<JSNetworkRequestConfigProtocol>> *)configs
                       completed:(nullable void(^)(NSArray<id<JSNetworkInterfaceProtocol>> *aInterfaces))completed {
    dispatch_group_t group = dispatch_group_create();
    NSMutableArray<id<JSNetworkInterfaceProtocol>> *resultArray = [NSMutableArray arrayWithCapacity:configs.count];
    [configs enumerateObjectsUsingBlock:^(id<JSNetworkRequestConfigProtocol> config, NSUInteger idx, BOOL *stop) {
        dispatch_group_enter(group);
        [self requestWithConfig:config
                 uploadProgress:nil
               downloadProgress:nil
                      completed:^(id<JSNetworkInterfaceProtocol> aInterface) {
            [resultArray insertObject:aInterface atIndex:idx];
            dispatch_group_leave(group);
        }];
    }];
    dispatch_group_notify(group, JSNetworkConfig.sharedConfig.completionQueue, ^{
        completed(resultArray);
    });
}

+ (void)_chainRequestWithConfig:(id<JSNetworkRequestConfigProtocol>)config
                      nextBlock:(nullable id<JSNetworkRequestConfigProtocol>(^)(id<JSNetworkInterfaceProtocol> aInterface))nextBlock {
    [self requestWithConfig:config
             uploadProgress:nil
           downloadProgress:nil
                  completed:^(id<JSNetworkInterfaceProtocol> aInterface) {
        id<JSNetworkRequestConfigProtocol> nextConfig = nextBlock(aInterface);
        if (nextConfig) {
            [self _chainRequestWithConfig:nextConfig nextBlock:nextBlock];
        }
    }];
}

+ (void)onPressTest {
    [JSNetworkProvider _batchRequestWithConfigs:@[]
                                      completed:^(NSArray<id<JSNetworkInterfaceProtocol>> *aInterfaces) {
        
    }];
    [JSNetworkProvider _chainRequestWithConfig:nil
                                     nextBlock:^id<JSNetworkRequestConfigProtocol>(id<JSNetworkInterfaceProtocol> aInterface) {
        return nil;
    }];
}

@end
