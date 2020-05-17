//
//  JSNetworkProxy.m
//  JSNetwork
//
//  Created by jiasong on 2020/5/16.
//

#import "JSNetworkProxy.h"

@implementation JSNetworkProxy

+ (instancetype)proxyWithTarget:(id)target {
    return [[self.class alloc] initWithTarget:target];
}

- (instancetype)initWithTarget:(id)target {
    _target = target;
    return self;
}

#pragma mark - NSProxy

- (id)forwardingTargetForSelector:(SEL)aSelector {
    if ([_target respondsToSelector:aSelector]) {
        return _target;
    }
    return nil;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    return [_target methodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    [anInvocation invokeWithTarget:_target];
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    if ([_target respondsToSelector:aSelector]) {
        return YES;
    }
    return NO;
}

- (BOOL)isEqual:(id)object {
    return [_target isEqual:object];
}

- (NSUInteger)hash {
    return [_target hash];
}

- (Class)superclass {
    return [_target superclass];
}

- (Class)class {
    return [_target class];
}

- (BOOL)isKindOfClass:(Class)aClass {
    return [_target isKindOfClass:aClass];
}

- (BOOL)isMemberOfClass:(Class)aClass {
    return [_target isMemberOfClass:aClass];
}

- (BOOL)conformsToProtocol:(Protocol *)aProtocol {
    return [_target conformsToProtocol:aProtocol];
}

- (BOOL)isProxy {
    return YES;
}

- (NSString *)description {
    return [_target description];
}

- (NSString *)debugDescription {
    return [_target debugDescription];
}

@end
