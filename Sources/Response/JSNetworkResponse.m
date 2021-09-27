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

- (nullable NSString *)responseURLString {
    return self.originalResponse.URL.absoluteString;
}

- (nullable NSDictionary<NSString *, NSString *> *)responseHeaders {
    return self.originalResponse.allHeaderFields;
}

- (NSInteger)responseStatusCode {
    return self.originalResponse.statusCode;
}

- (nullable id)responseObject  {
    return _responseObject;
}

- (nullable NSError *)error  {
    return _error;
}

- (nullable NSHTTPURLResponse *)originalResponse {
    if ([_requestTask.response isKindOfClass:NSHTTPURLResponse.class]) {
        return (NSHTTPURLResponse *)_requestTask.response;
    } else {
        return nil;
    }
}

- (BOOL)networkingAbnormal {
    return self.error.code == -1009 || self.error.code == -1001;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@: <%p>", NSStringFromClass(self.class), self];
}

- (void)dealloc {
    JSNetworkLog(@"%@ - 已经释放", NSStringFromClass([self class]));
}

@end
