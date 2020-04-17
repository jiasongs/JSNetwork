//
//  JSNetworkAgent.h
//  JSNetwork
//
//  Created by jiasong on 2020/4/17.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSRequestProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface JSNetworkAgent : NSObject

+ (instancetype)sharedInstance;

- (void)addRequest:(id<JSRequestProtocol>)request;

- (void)cancelRequest:(id<JSRequestProtocol>)request;

- (void)cancelAllRequests;

@end

NS_ASSUME_NONNULL_END
