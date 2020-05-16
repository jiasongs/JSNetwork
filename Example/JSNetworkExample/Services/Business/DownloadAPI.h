//
//  DownloadAPI.h
//  JSNetworkExample
//
//  Created by jiasong on 2020/5/16.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import "BaseAPI.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, DownloadURLType) {
    DownloadURLTypeTypeCachefly,
    DownloadURLTypeTypeCnblogs
};

@interface DownloadAPI : BaseAPI

+ (instancetype)apiWithDownloadURLType:(DownloadURLType)downloadURLType;

@end

NS_ASSUME_NONNULL_END
