//
//  JSNetworkRequestConfigProtocol.h
//  JSNetwork
//
//  Created by jiasong on 2020/4/17.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol JSNetworkPluginProtocol;
@protocol JSNetworkRequestProtocol;

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

@required

- (NSString *)requestUrl;

@optional

- (NSString *)baseUrl;

- (nullable NSDictionary *)requestArgument;

- (nullable id)requestBody;

- (JSRequestMethod)requestMethod;

- (JSRequestSerializerType)requestSerializerType;

- (JSResponseSerializerType)responseSerializerType;

- (NSTimeInterval)requestTimeoutInterval;

- (nullable NSDictionary<NSString *, NSString *> *)requestHeaderFieldValueDictionary;

- (NSString *)urlFilterWithURL:(NSString *)URL;

- (NSArray<id<JSNetworkPluginProtocol>> *)requestPlugins;


@end

NS_ASSUME_NONNULL_END
