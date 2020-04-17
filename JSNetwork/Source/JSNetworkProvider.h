//
//  JSNetworkProvider.h
//  JSNetwork
//
//  Created by jiasong on 2020/4/17.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSNetworkRequestConfigProtocol.h"
#import "JSNetworkRequestProtocol.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^JSRequestCompletionBlock)(id<JSNetworkRequestProtocol>);

@interface JSNetworkProvider : NSObject

+ (void)requestConfig:(id<JSNetworkRequestConfigProtocol>)config complete:(JSRequestCompletionBlock)complete;

@end

NS_ASSUME_NONNULL_END
