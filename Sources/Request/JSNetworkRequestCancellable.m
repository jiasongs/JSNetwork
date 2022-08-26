//
//  JSNetworkRequestCancellable.m
//  JSNetwork
//
//  Created by jiasong on 2021/4/14.
//

#import "JSNetworkRequestCancellable.h"
#import "JSNetworkManager.h"
#import "JSNetworkInterfaceProtocol.h"

@implementation JSNetworkRequestCancellable
@synthesize networkManager = _networkManager;
@synthesize taskIdentifier = _taskIdentifier;

- (BOOL)isCancelled {
    if (self.taskIdentifier.length > 0) {
        id<JSNetworkInterfaceProtocol> interface = [self.networkManager interfaceForTaskIdentifier:self.taskIdentifier];
        return interface.request.isCancelled;
    }
    return NO;
}

- (void)cancel {
    if (self.taskIdentifier.length > 0 && !self.isCancelled) {
        [self.networkManager cancelRequestForTaskIdentifier:self.taskIdentifier];
    }
}

@end
