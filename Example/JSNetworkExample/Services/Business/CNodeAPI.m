//
//  CNodeAPI.m
//  JSNetwork
//
//  Created by jiasong on 2020/4/18.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import "CNodeAPI.h"
#import "NetworkResponse.h"
#import <JSNetworkConfig.h>

@implementation CNodeAPI

- (NSString *)baseURLString {
    return @"https://cnodejs.org/api";
}

- (NSString *)requestURLString {
  return @"/v1?test=1111&zzz={中文}&xxxx=%E4%B8%AD%E6%96%87&yyyy=+86-186&mmm=@69875456";
}

- (NSArray<NSString *> *)requestPaths {
    return @[@"topics"];
}

- (NSArray<NSString *> *)ignoreGlobalArgumentForKeys {
    return @[@"other"];
}

- (JSRequestCachePolicy)cachePolicy {
    return JSRequestCachePolicyIgnoringCacheData;
}

- (long long)cacheVersion {
    return 1;
}

- (BOOL)cacheIsSavedWithResponse:(id<JSNetworkResponseProtocol>)response {
    return [(NetworkResponse *)response successful];
}

@end
