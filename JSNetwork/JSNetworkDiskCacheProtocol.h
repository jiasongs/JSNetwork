//
//  JSNetworkDiskCacheProtocol.h
//  JSNetwork
//
//  Created by jiasong on 2020/4/22.
//

#import <Foundation/Foundation.h>
@protocol JSNetworkInterfaceProtocol;
@protocol JSNetworkDiskCacheMetadataProtocol;

NS_ASSUME_NONNULL_BEGIN

typedef void (^JSNetworkDiskCacheCompleted)(id<JSNetworkDiskCacheMetadataProtocol> _Nullable metadata);

@protocol JSNetworkDiskCacheProtocol <NSObject>

@required
/**
 *  @brief 判断缓存是否有效
 *
 *  @param interface 遵循<JSNetworkInterfaceProtocol>的接口类
 *  @param completed 参数为空时表示没有有效的缓存
 *
 */
- (void)validCacheForInterface:(id<JSNetworkInterfaceProtocol>)interface
                     completed:(nullable JSNetworkDiskCacheCompleted)completed;

/**
 *  @brief 得到缓存
 *
 *  @param interface 遵循<JSNetworkInterfaceProtocol>的接口类
 *  @param completed 参数为空时表示没有有效的缓存
 *
 */
- (void)cacheForInterface:(id<JSNetworkInterfaceProtocol>)interface
                completed:(nullable JSNetworkDiskCacheCompleted)completed;

/**
 *  @brief 设置缓存
 *
 *  @param cacheData 要缓存的数据
 *  @param interface 遵循<JSNetworkInterfaceProtocol>的接口类
 *  @param completed 参数为空时表示没有有效的缓存
 *
 */
- (void)setCacheData:(id)cacheData
        forInterface:(id<JSNetworkInterfaceProtocol>)interface
           completed:(nullable JSNetworkDiskCacheCompleted)completed;

/**
 *  @brief 得到缓存文件的完整路径
 *
 *  @param interface 遵循<JSNetworkInterfaceProtocol>的接口类
 *
 * @return path
 */
- (NSString *)cacheFilePathWithInterface:(id<JSNetworkInterfaceProtocol>)interface;

@end

NS_ASSUME_NONNULL_END
