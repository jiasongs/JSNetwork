//
//  JSNetworkResponse.m
//  JSNetwork
//
//  Created by jiasong on 2020/4/17.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import "JSNetworkResponse.h"
#import "JSNetworkResponseProtocol.h"
#import "JSNetworkInterfaceProtocol.h"
#import "JSNetworkRequestProtocol.h"

@interface JSNetworkResponse () {
    NSURLSessionTask *_requestTask;
    NSError *_error;
    id _responseObject;
}

@end

@implementation JSNetworkResponse

- (void)processingTaskWithInterface:(id<JSNetworkInterfaceProtocol>)interface responseObject:(nullable id)responseObject error:(nullable NSError *)error {
    _requestTask = interface.request.requestTask;
    _error = error;
    _responseObject = responseObject;
}

- (NSHTTPURLResponse *)originalResponse {
    return (NSHTTPURLResponse *)_requestTask.response;
}

- (NSInteger)responseStatusCode {
    return self.originalResponse.statusCode;
}

- (NSDictionary *)responseHeaders {
    return self.originalResponse.allHeaderFields;
}

- (id)responseObject  {
    return _responseObject;
}

- (NSError *)error  {
    return _error;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p> { responseStatusCode: %@ } { error: %@ }", NSStringFromClass([self class]), self, @(self.responseStatusCode), self.error];
}

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"JSNetworkResponse - 已经释放");
#endif
}

@end
