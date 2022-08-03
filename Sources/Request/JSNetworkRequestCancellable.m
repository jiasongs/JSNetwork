//
//  JSNetworkRequestCancellable.m
//  JSNetwork
//
//  Created by jiasong on 2021/4/14.
//

#import "JSNetworkRequestCancellable.h"
#import "JSNetworkAgent.h"
#import "JSNetworkInterfaceProtocol.h"

@implementation JSNetworkRequestCancellable
@synthesize agent = _agent;
@synthesize taskIdentifier = _taskIdentifier;

- (BOOL)isCancelled {
    if (self.taskIdentifier.length > 0) {
        id<JSNetworkInterfaceProtocol> interface = [self.agent interfaceForTaskIdentifier:self.taskIdentifier];
        return interface.request.isCancelled;
    }
    return NO;
}

- (void)cancel {
    if (self.taskIdentifier.length > 0 && !self.isCancelled) {
        [self.agent cancelRequestForTaskIdentifier:self.taskIdentifier];
    }
}

@end
