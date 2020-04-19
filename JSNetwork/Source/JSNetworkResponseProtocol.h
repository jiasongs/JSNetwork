//
//  JSNetworkResponseProtocol.h
//  JSNetwork
//
//  Created by jiasong on 2020/4/17.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol JSNetworkResponseProtocol <NSObject>

- (void)handleRequestResult:(NSURLSessionTask *)task responseObject:(nullable id)responseObject error:(nullable NSError *)error;
- (NSHTTPURLResponse *)originalResponse;
- (NSInteger)responseStatusCode;
- (NSDictionary *)responseHeaders;
- (id)responseObject;
- (NSError *)error;

@end

NS_ASSUME_NONNULL_END
