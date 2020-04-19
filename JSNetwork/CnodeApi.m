//
//  CnodeApi.m
//  JSNetwork
//
//  Created by jiasong on 2020/4/18.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import "CnodeApi.h"

@implementation CnodeApi

- (NSString *)baseUrl {
    return @"https://cnodejs.org/api/v1";
}

- (NSString *)requestUrl {
  return @"/topics?test=1111&zzz={zzz}";
}

@end
