//
//  JSNetworkResponse.m
//  JSNetwork
//
//  Created by jiasong on 2020/4/17.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import "JSNetworkResponse.h"
#import "JSNetworkResponseProtocol.h"
#import "JSNetworkRequestConfigProtocol.h"
#import "JSNetworkRequestProtocol.h"
#import "JSNetworkUtil.h"

@interface JSNetworkResponse () {
    NSURLSessionTask *_requestTask;
    NSError *_error;
    id _responseObject;
}

@end

@implementation JSNetworkResponse

- (void)processingTask:(NSURLSessionTask *)task
        responseObject:(nullable id)responseObject
                 error:(nullable NSError *)error {
    _requestTask = task;
    _error = error;
    _responseObject = responseObject;
}

- (NSHTTPURLResponse *)originalResponse {
    return (NSHTTPURLResponse *)_requestTask.response;
}

- (NSInteger)responseStatusCode {
    return self.originalResponse.statusCode;
}

- (NSDictionary<NSString *, NSString *> *)responseHeaders {
    return self.originalResponse.allHeaderFields;
}

- (id)responseObject  {
    return _responseObject;
}

- (NSError *)error  {
    return _error;
}

- (BOOL)abnormalNetworking {
    return self.error.code == -1009 || self.error.code == -1001;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@: <%p>", NSStringFromClass(self.class), self];
}

- (void)dealloc {
    JSNetworkLog(@"%@ - 已经释放", NSStringFromClass([self class]));
}

@end
