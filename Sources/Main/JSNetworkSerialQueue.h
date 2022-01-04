//
//  JSNetworkSerialQueue.h
//  JSNetworkExample
//
//  Created by jiasong on 2020/7/31.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JSNetworkSerialQueue : NSObject

+ (void)execute:(void (NS_NOESCAPE ^)(void))block;
+ (id)executeWithReturnValue:(id (NS_NOESCAPE ^)(void))block;

@end

NS_ASSUME_NONNULL_END
