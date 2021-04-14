//
//  JSNetworkCancellable.m
//  JSNetwork
//
//  Created by jiasong on 2021/4/14.
//

#import "JSNetworkCancellable.h"
#import "JSNetworkAgent.h"
#import "JSNetworkInterfaceProtocol.h"

@interface JSNetworkCancellable ()

@property (nonatomic, weak, readwrite) id<JSNetworkInterfaceProtocol> interface;

@end

@implementation JSNetworkCancellable
@synthesize interface = _interface;

- (instancetype)initWithInterface:(nonnull id<JSNetworkInterfaceProtocol>)interface {
    if (self = [super init]) {
        NSParameterAssert(interface);
        _interface = interface;
    }
    return self;
}

- (BOOL)isCancelled {
    if (self.interface) {
        return self.interface.request.isCancelled;
    }
    return NO;
}

- (void)cancel {
    if (self.interface && !self.isCancelled) {
        [JSNetworkAgent.sharedAgent cancelRequestForTaskIdentifier:self.interface.taskIdentifier];
    }
}

@end
