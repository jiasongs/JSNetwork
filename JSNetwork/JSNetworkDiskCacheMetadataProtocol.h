//
//  JSNetworkDiskCacheMetadataProtocol.h
//  JSNetwork
//
//  Created by jiasong on 2020/4/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol JSNetworkDiskCacheMetadataProtocol <NSSecureCoding>

@required
/**
 *  @brief 缓存版本
 */
@property (nonatomic, assign) long long version;
/**
 *  @brief 缓存的创建时间
 */
@property (nonatomic, strong) NSDate *creationDate;
/**
 *  @brief 缓存的APP版本
 */
@property (nonatomic, strong) NSString *appVersionString;
/**
 *  @brief 缓存的数据
 */
@property (nonatomic, strong) NSData *cacheData;

@end

NS_ASSUME_NONNULL_END
