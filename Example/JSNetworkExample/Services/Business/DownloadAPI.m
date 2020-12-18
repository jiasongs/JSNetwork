//
//  DownloadAPI.m
//  JSNetworkExample
//
//  Created by jiasong on 2020/5/16.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import "DownloadAPI.h"
#import "NetworkResponse.h"

@interface DownloadAPI ()

@property (nonatomic, assign) DownloadURLType downloadURLType;

@end

@implementation DownloadAPI

+ (instancetype)apiWithDownloadURLType:(DownloadURLType)downloadURLType {
    DownloadAPI *api = [[DownloadAPI alloc] init];
    api.downloadURLType = downloadURLType;
    return api;
}

- (NSString *)baseUrl {
    if (self.downloadURLType == DownloadURLTypeTypeCnblogs) {
        return @"https://files-cdn.cnblogs.com";
    }
    return @"http://cachefly.cachefly.net";
}

- (NSString *)requestUrl {
    if (self.downloadURLType == DownloadURLTypeTypeCnblogs) {
        return @"/files/MolbyHome/%E6%83%B3%E6%B3%95.rar";
    }
    return @"/100mb.test";
}

- (JSResponseSerializerType)responseSerializerType {
    return JSResponseSerializerTypeHTTP;
}

- (nullable NSSet<NSString *> *)responseAcceptableContentTypes {
    if (self.downloadURLType == DownloadURLTypeTypeCnblogs) {
        return [NSSet setWithObjects:@"application/x-rar-compressed", nil];
    }
    return [NSSet setWithObjects:@"application/octet-stream", nil];
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
