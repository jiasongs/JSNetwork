//
//  JSNetworkMutexLock.m
//  JSNetworkExample
//
//  Created by jiasong on 2020/7/31.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import "JSNetworkMutexLock.h"

@interface JSNetworkMutexLock ()

@property (nonatomic, strong) dispatch_semaphore_t lock;

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
        _lock = dispatch_semaphore_create(1);
    }
    return self;
}

- (void)addLock {
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
}

- (void)unLock {
    dispatch_semaphore_signal(_lock);
}

@end
