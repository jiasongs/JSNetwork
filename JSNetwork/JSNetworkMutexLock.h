//
//  JSNetworkMutexLock.h
//  JSNetworkExample
//
//  Created by jiasong on 2020/7/31.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JSNetworkMutexLock : NSObject

+ (instancetype)sharedLock;

- (void)addLock;
- (void)unLock;

@end

NS_ASSUME_NONNULL_END
