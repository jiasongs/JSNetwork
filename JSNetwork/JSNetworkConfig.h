//
//  JSNetworkConfig.h
//  JSNetwork
//
//  Created by jiasong on 2020/4/17.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol JSNetworkPluginProtocol;
@protocol JSNetworkResponseProtocol;
@protocol JSNetworkRequestProtocol;
@protocol JSNetworkDiskCacheProtocol;

NS_ASSUME_NONNULL_BEGIN

@interface JSNetworkConfig : NSObject

/**
 *  @brief 输出DEBUG信息
 */
@property (nonatomic, assign) BOOL debugLogEnabled;
/**
 *  @brief 全局的任务处理所在的队列
 */
@property (nonatomic, strong) dispatch_queue_t processingQueue;
/**
 *  @brief 全局的回调处理所在的队列，默认主队列
 */
@property (nonatomic, strong) dispatch_queue_t completionQueue;
/**
 *  @brief 全局BaseURL
 */
@property (nonatomic, strong) NSString *baseURL;
/**
 *  @brief 全局请求头，只读
 */
@property (nonatomic, strong, readonly) NSDictionary *HTTPHeaderFields;
/**
 *  @brief 全局用于URL筛选的字典，只读
 */
@property (nonatomic, strong, readonly) NSDictionary *urlFilterArguments;
/**
 *  @brief 全局超时时间
 */
@property (nonatomic, assign) NSTimeInterval timeoutInterval;
/**
 *  @brief 全局的请求Class, 默认JSNetworkRequest, 继承于NSOperation
 */
@property (nonatomic, assign) Class<JSNetworkRequestProtocol> requestClass;
/**
 *  @brief 全局的响应Class, 默认JSNetworkResponse
 */
@property (nonatomic, assign) Class<JSNetworkResponseProtocol> responseClass;

/**
 *  @brief 磁盘缓存的Class
 */
@property (nonatomic, assign) Class<JSNetworkDiskCacheProtocol> diskCache;
/**
 *  @brief 磁盘缓存的文件夹路径
 */
@property (nonatomic, strong) NSString *cacheDirectoryPath;
/**
 *  @brief 全局的插件
 */
@property (nonatomic, assign, readonly) NSArray *plugins;

+ (instancetype)sharedConfig;

/**
 *  @brief 添加一个用于URL筛选的字典
 *
 *  @param filter 字典
 */
- (void)addUrlFilterArguments:(NSDictionary *)filter;
/**
 *  @brief 清除全部URL筛选的字典
 */
- (void)clearUrlFilterArguments;

/**
 *  @brief 添加一个HTTPHeaderField
 *
 *  @param headerFields headerFields
 */
- (void)addHTTPHeaderFields:(NSDictionary *)headerFields;
/**
 *  @brief 清除HTTPHeaderField
 */
- (void)clearHTTPHeaderFields;

/**
 *  @brief 添加一个插件
 *
 *  @param plugin 遵循<JSNetworkPluginProtocol>的插件
 */
- (void)addPlugin:(id<JSNetworkPluginProtocol>)plugin;
/**
 *  @brief 清除所有插件
 */
- (void)clearPlugins;

@end

NS_ASSUME_NONNULL_END
