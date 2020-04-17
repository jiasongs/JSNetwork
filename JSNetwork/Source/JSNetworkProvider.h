//
//  JSNetworkProvider.h
//  JSNetwork
//
//  Created by jiasong on 2020/4/17.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSRequestProtocol.h"
#import <AFNetworking.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^JSRequestCompletionBlock)(void);

@interface JSNetworkProvider : NSObject

+ (void)request:(id<JSRequestProtocol>)request complete:(JSRequestCompletionBlock)complete;

@end

NS_ASSUME_NONNULL_END
