//
//  JSNetworkDiskCacheProtocol.h
//  JSNetwork
//
//  Created by jiasong on 2020/4/22.
//

#import <Foundation/Foundation.h>

@protocol JSNetworkRequestConfigProtocol;
@protocol JSNetworkDiskCacheMetadataProtocol;

NS_ASSUME_NONNULL_BEGIN

typedef void (^JSNetworkDiskCacheCompleted)(id<JSNetworkDiskCacheMetadataProtocol> _Nullable metadata);

@protocol JSNetworkDiskCacheProtocol <NSObject>

@required

/**
 *  @brief 判断缓存是否有效
 *
 *  @param config 遵循<JSNetworkRequestConfigProtocol>的配置类
 *  @param didCompletedBlock 参数为空时表示没有有效的缓存
 *
 */
- (void)buildTaskWithConfig:(id<JSNetworkRequestConfigProtocol>)config
               didCompleted:(JSNetworkDiskCacheCompleted)didCompletedBlock;

/**
 *  @brief 得到缓存
 *
 *  @param config 遵循<JSNetworkRequestConfigProtocol>的配置类
 *  @param completed 参数为空时表示没有有效的缓存
 *
 */
- (void)cacheForRequestConfig:(id<JSNetworkRequestConfigProtocol>)config
                    completed:(nullable JSNetworkDiskCacheCompleted)completed;

/**
 *  @brief 设置缓存
 *
 *  @param cacheData 要缓存的数据
 *  @param config 遵循<JSNetworkRequestConfigProtocol>的配置类
 *  @param completed 参数为空时表示没有有效的缓存
 *
 */
- (void)setCacheData:(id)cacheData
    forRequestConfig:(id<JSNetworkRequestConfigProtocol>)config
           completed:(nullable JSNetworkDiskCacheCompleted)completed;

@end

NS_ASSUME_NONNULL_END
