//
//  UploadImageAPI.m
//  JSNetworkExample
//
//  Created by jiasong on 2020/5/16.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import "UploadImageAPI.h"
#import <AFNetworking/AFNetworking.h>

@implementation UploadImageAPI

- (NSString *)baseURLString {
    return @"https://cnodejs.org/api/v1";
}

- (NSString *)requestURLString {
  return @"/topics?test=1111&zzz={中文}";
}

- (id)requestBody {
    return @{@"testKey": @"testValue"};
}

- (JSRequestMethod)requestMethod {
    return JSRequestMethodPOST;
}

- (JSRequestSerializerType)requestSerializerType {
    return JSRequestSerializerTypeFormData;
}

- (void)requestConstructingMultipartFormData:(id<AFMultipartFormData>)multipartFormData {
    [multipartFormData appendPartWithFormData:NSData.data name:@"test"];
}

@end
