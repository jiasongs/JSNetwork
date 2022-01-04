//
//  JSNetworkSerialQueue.m
//  JSNetworkExample
//
//  Created by jiasong on 2020/7/31.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import "JSNetworkSerialQueue.h"

@interface JSNetworkSerialQueue ()

@property (nonatomic) dispatch_queue_t queue;

@end

@implementation JSNetworkSerialQueue

+ (instancetype)shared {
    static dispatch_once_t onceToken;
    static JSNetworkSerialQueue *instance = nil;
    dispatch_once(&onceToken,^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return [self shared];
}

- (instancetype)init {
    if (self = [super init]) {
        _queue = dispatch_queue_create([[NSString stringWithFormat:@"com.jsnetwork.%@", NSStringFromClass(self.class)] UTF8String], DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

+ (void)execute:(void (NS_NOESCAPE ^)(void))block {
    dispatch_sync(JSNetworkSerialQueue.shared.queue, ^{
        block();
    });
}

+ (id)executeWithReturnValue:(id (NS_NOESCAPE ^)(void))block {
    __block id returnValue = nil;
    dispatch_sync(JSNetworkSerialQueue.shared.queue, ^{
        returnValue = block();
    });
    return returnValue;
}

@end
