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
 *  @param taskCompleted 参数为空时表示没有有效的缓存
 *
 */
- (void)buildTaskWithRequestConfig:(id<JSNetworkRequestConfigProtocol>)config taskCompleted:(JSNetworkDiskCacheCompleted)taskCompleted;

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

/**
 *  @brief 任务ID
 *
 * @return NSString
 */
- (NSString *)taskIdentifier;

/**
 *  @brief 得到缓存文件的完整路径
 *
 *  @param config 遵循<JSNetworkRequestConfigProtocol>的接口类
 *
 * @return path
 */
- (NSString *)cacheFilePathWithRequestConfig:(id<JSNetworkRequestConfigProtocol>)config;


@end

NS_ASSUME_NONNULL_END
