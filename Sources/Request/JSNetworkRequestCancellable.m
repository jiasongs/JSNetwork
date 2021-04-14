//
//  JSNetworkRequestCancellable.m
//  JSNetwork
//
//  Created by jiasong on 2021/4/14.
//

#import "JSNetworkRequestCancellable.h"
#import "JSNetworkAgent.h"
#import "JSNetworkInterfaceProtocol.h"

@interface JSNetworkRequestCancellable ()

@property (nonatomic, copy, readwrite) NSString *taskIdentifier;

@end

@implementation JSNetworkRequestCancellable
@synthesize taskIdentifier = _taskIdentifier;

- (instancetype)initWithTaskIdentifier:(NSString *)taskIdentifier {
    if (self = [super init]) {
        NSParameterAssert(taskIdentifier);
        _taskIdentifier = taskIdentifier;
    }
    return self;
}

- (BOOL)isCancelled {
    if (self.taskIdentifier.length > 0) {
        id<JSNetworkInterfaceProtocol> interface = [JSNetworkAgent.sharedAgent interfaceForTaskIdentifier:self.taskIdentifier];
        return interface.request.isCancelled;
    }
    return NO;
}

- (void)cancel {
    if (self.taskIdentifier.length > 0 && !self.isCancelled) {
        [JSNetworkAgent.sharedAgent cancelRequestForTaskIdentifier:self.taskIdentifier];
    }
}

@end
