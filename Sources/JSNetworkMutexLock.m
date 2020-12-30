//
//  JSNetworkMutexLock.m
//  JSNetworkExample
//
//  Created by jiasong on 2020/7/31.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import "JSNetworkMutexLock.h"
#import <os/lock.h>

@interface JSNetworkMutexLock () {
    os_unfair_lock _lock;
}

@end

@implementation JSNetworkMutexLock

+ (instancetype)sharedLock {
    static dispatch_once_t onceToken;
    static JSNetworkMutexLock *instance = nil;
    dispatch_once(&onceToken,^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return [self sharedLock];
}

- (instancetype)init {
    if (self = [super init]) {
        _lock = OS_UNFAIR_LOCK_INIT;
    }
    return self;
}

- (void)addLock {
    os_unfair_lock_lock(&_lock);
}

- (void)unLock {
    os_unfair_lock_unlock(&_lock);
}

+ (void)execute:(void (NS_NOESCAPE ^)(void))block {
    [self.sharedLock addLock];
    block();
    [self.sharedLock unLock];
}

+ (id)executeWithReturnValue:(id (NS_NOESCAPE ^)(void))block {
    [self.sharedLock addLock];
    id returnValue = block();
    [self.sharedLock unLock];
    return returnValue;
}

@end
