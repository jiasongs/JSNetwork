//
//  JSNetworkRequestConfigProtocol.h
//  JSNetwork
//
//  Created by jiasong on 2020/4/17.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSNetworkPluginProtocol.h"

typedef NS_ENUM(NSInteger, JSRequestMethod) {
    JSRequestMethodGET = 0,
    JSRequestMethodPOST,
};

typedef NS_ENUM(NSInteger, JSRequestSerializerType) {
    JSRequestSerializerTypeHTTP = 0,
    JSRequestSerializerTypeJSON,
};

typedef NS_ENUM(NSInteger, JSResponseSerializerType) {
    JSResponseSerializerTypeHTTP,
    JSResponseSerializerTypeJSON,
    JSResponseSerializerTypeXMLParser,
};

NS_ASSUME_NONNULL_BEGIN

@protocol JSNetworkRequestConfigProtocol <NSObject>

- (NSString *)baseUrl;

- (NSString *)requestUrl;

- (NSTimeInterval)requestTimeoutInterval;

- (nullable id)requestArgument;

- (nullable id)requestBody;

- (JSRequestMethod)requestMethod;

- (JSRequestSerializerType)requestSerializerType;

- (JSResponseSerializerType)responseSerializerType;

- (nullable NSDictionary<NSString *, NSString *> *)requestHeaderFieldValueDictionary;

- (NSArray<id<JSNetworkPluginProtocol>> *)requestPlugins;

@end

NS_ASSUME_NONNULL_END
