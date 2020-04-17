//
//  JSNetworkResponse.m
//  JSNetwork
//
//  Created by jiasong on 2020/4/17.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import "JSNetworkResponse.h"

@implementation JSNetworkResponse

@synthesize successful = _successful;
@synthesize contentData = _contentData;
@synthesize message = _message;

#pragma mark - setter

- (void)setSuccessful:(BOOL)successful {
    _successful = successful;
}

- (void)setContentData:(id)contentData {
    _contentData = contentData;
}

- (void)setMessage:(NSString *)message {
    _message = message;
}

#pragma mark - getter

- (BOOL)successful {
    return _successful;
}

- (id)contentData {
    return _contentData;
}

- (NSString *)message {
    return _message;
}

@end
