//
//  JSNetworkInterface.h
//  JSNetwork
//
//  Created by jiasong on 2020/4/18.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol JSNetworkRequestConfigProtocol;

NS_ASSUME_NONNULL_BEGIN

@interface JSNetworkInterface : NSObject

@property (nonatomic, strong, readonly) NSString *finalURL;
@property (nonatomic, strong, readonly) id finalArguments;
@property (nonatomic, strong, readonly) id finalBody;
@property (nonatomic, strong, readonly) NSString *HTTPMethod;
@property (nonatomic, strong, readonly) NSDictionary *HTTPHeaderFields;
@property (nonatomic, strong, readonly) id<JSNetworkRequestConfigProtocol> config;

- (instancetype)initWithRequestConfig:(id<JSNetworkRequestConfigProtocol>)config;

@end

NS_ASSUME_NONNULL_END
