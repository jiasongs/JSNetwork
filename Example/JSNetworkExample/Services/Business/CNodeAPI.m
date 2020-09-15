//
//  CNodeAPI.m
//  JSNetwork
//
//  Created by jiasong on 2020/4/18.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import "CNodeAPI.h"
#import "NetworkResponse.h"

@implementation CNodeAPI

- (NSString *)baseUrl {
    return @"https://cnodejs.org/api/v1";
}

- (NSString *)requestUrl {
  return @"?test=1111&zzz={中文}&xxxx=%E4%B8%AD%E6%96%87&yyyy=+86-186&mmm=@69875456";
}

- (NSArray<NSString *> *)requestPaths {
    return @[@"topics"];
}

- (NSArray<NSString *> *)filterGlobalArgumentForKeys {
    return @[@"other"];
}

- (BOOL)cacheIgnore {
    return true;
}

- (long long)cacheVersion {
    return 1;
}

- (BOOL)cacheIsSavedWithResponse:(id<JSNetworkResponseProtocol>)response {
    return [(NetworkResponse *)response successful];
}

@end
