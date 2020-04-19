//
//  JSNetworkConfig.h
//  JSNetwork
//
//  Created by jiasong on 2020/4/17.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol JSNetworkPluginProtocol;

NS_ASSUME_NONNULL_BEGIN

@interface JSNetworkConfig : NSObject

@property (nonatomic, assign) BOOL debugLogEnabled;
@property (nonatomic, strong) NSString *baseUrl;
@property (nonatomic, strong, readonly) NSDictionary *HTTPHeaderFields;
@property (nonatomic, strong, readonly) NSDictionary *urlFilterArguments;
@property (nonatomic, assign, readonly) NSArray *plugins;

+ (instancetype)sharedInstance;

- (void)addUrlFilterArguments:(NSDictionary *)filter;
- (void)clearUrlFilterArguments;

- (void)addHTTPHeaderFields:(NSDictionary *)headerFields;
- (void)clearHTTPHeaderFields;

- (void)addPlugins:(id<JSNetworkPluginProtocol>)plugin;
- (void)clearPlugins;

@end

NS_ASSUME_NONNULL_END
