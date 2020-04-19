//
//  JSNetworkAgent.h
//  JSNetwork
//
//  Created by jiasong on 2020/4/17.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol JSNetworkRequestProtocol;
@protocol JSNetworkRequestConfigProtocol;

NS_ASSUME_NONNULL_BEGIN

@interface JSNetworkAgent : NSObject

+ (instancetype)sharedInstance;

- (void)addRequest:(id<JSNetworkRequestProtocol>)request;

- (void)removeRequest:(id<JSNetworkRequestProtocol>)request;

- (void)cancelAllRequests;

@end

NS_ASSUME_NONNULL_END
