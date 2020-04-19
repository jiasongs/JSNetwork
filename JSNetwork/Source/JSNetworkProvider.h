//
//  JSNetworkProvider.h
//  JSNetwork
//
//  Created by jiasong on 2020/4/17.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol JSNetworkRequestConfigProtocol;
@protocol JSNetworkRequestProtocol;

NS_ASSUME_NONNULL_BEGIN

@interface JSNetworkProvider : NSObject

+ (id<JSNetworkRequestProtocol>)requestWithConfig:(id<JSNetworkRequestConfigProtocol>)config;

+ (id<JSNetworkRequestProtocol>)requestwithConfig:(id<JSNetworkRequestConfigProtocol>)config
                                        completed:(nullable void (^)(id<JSNetworkRequestProtocol> aRequest))completed;

+ (id<JSNetworkRequestProtocol>)requestWithConfig:(id<JSNetworkRequestConfigProtocol>)config
                         uploadProgress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress
                                        completed:(nullable void (^)(id<JSNetworkRequestProtocol> aRequest))completed;

+ (id<JSNetworkRequestProtocol>)requestWithConfig:(id<JSNetworkRequestConfigProtocol>)config
                         downloadProgress:(nullable void (^)(NSProgress *downloadProgress))downloadProgress
                                        completed:(nullable void (^)(id<JSNetworkRequestProtocol> aRequest))completed;

+ (id<JSNetworkRequestProtocol>)requestWithConfig:(id<JSNetworkRequestConfigProtocol>)config
                                   uploadProgress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress
                         downloadProgress:(nullable void (^)(NSProgress *downloadProgress))downloadProgress
                                        completed:(nullable void (^)(id<JSNetworkRequestProtocol> aRequest))completed;

+ (id<JSNetworkRequestProtocol>)request:(id<JSNetworkRequestProtocol>)request
                             withConfig:(id<JSNetworkRequestConfigProtocol>)config
                              completed:(nullable void (^)(id<JSNetworkRequestProtocol> aRequest))completed;

+ (id<JSNetworkRequestProtocol>)request:(id<JSNetworkRequestProtocol>)request
                             withConfig:(id<JSNetworkRequestConfigProtocol>)config
                         uploadProgress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress
                              completed:(nullable void (^)(id<JSNetworkRequestProtocol> aRequest))completed;

+ (id<JSNetworkRequestProtocol>)request:(id<JSNetworkRequestProtocol>)request
                             withConfig:(id<JSNetworkRequestConfigProtocol>)config
                         downloadProgress:(nullable void (^)(NSProgress *downloadProgress))downloadProgress
                              completed:(nullable void (^)(id<JSNetworkRequestProtocol> aRequest))completed;

+ (id<JSNetworkRequestProtocol>)request:(id<JSNetworkRequestProtocol>)request
                             withConfig:(id<JSNetworkRequestConfigProtocol>)config
                         uploadProgress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress
                       downloadProgress:(nullable void (^)(NSProgress *downloadProgress))downloadProgress
                              completed:(nullable void (^)(id<JSNetworkRequestProtocol> aRequest))completed;


@end

NS_ASSUME_NONNULL_END
