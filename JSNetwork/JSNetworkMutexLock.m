//
//  JSNetworkMutexLock.m
//  JSNetworkExample
//
//  Created by jiasong on 2020/7/31.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import "JSNetworkMutexLock.h"

@interface JSNetworkMutexLock ()

@property (nonatomic, strong) dispatch_semaphore_t semaphore;

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
        _semaphore = dispatch_semaphore_create(1);
    }
    return self;
}

- (void)lock {
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
}

- (void)unLock {
    dispatch_semaphore_signal(_semaphore);
}

+ (void)execute:(void (NS_NOESCAPE ^)(void))block {
    [self.sharedLock lock];
    block();
    [self.sharedLock unLock];
}

+ (id)executeWithReturnValue:(id (NS_NOESCAPE ^)(void))block {
    [self.sharedLock lock];
    id returnValue = block();
    [self.sharedLock unLock];
    return returnValue;
}

@end
