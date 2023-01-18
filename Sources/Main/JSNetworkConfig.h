//
//  JSNetworkConfig.h
//  JSNetwork
//
//  Created by jiasong on 2020/4/17.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JSNetworkInterfaceBuilder;
@protocol JSNetworkPluginProtocol;

NS_ASSUME_NONNULL_BEGIN

@interface JSNetworkConfig : NSObject

/**
 *  @brief 输出DEBUG信息
 */
@property (nonatomic, assign) BOOL debugLogEnabled;
/**
 *  @brief 全局的任务处理所在的队列
 */
@property (nonatomic) dispatch_queue_t processingQueue;
/**
 *  @brief 全局的回调处理所在的队列，默认主队列
 */
@property (nonatomic) dispatch_queue_t completionQueue;
/**
 *  @brief 全局BaseURL
 */
@property (nonatomic, copy) NSString *baseURLString NS_SWIFT_NAME(baseUrlString);
/**
 *  @brief 全局请求头，只读
 */
@property (nonatomic, readonly) NSDictionary<NSString *, NSString *> *HTTPHeaderFields NS_SWIFT_NAME(httpHeaderFields);
/**
 *  @brief 全局URL参数的字典，只读
 */
@property (nonatomic, readonly) NSDictionary<NSString *, id> *URLParameters NS_SWIFT_NAME(urlParameters);
/**
 *  @brief 全局超时时间
 */
@property (nonatomic, assign) NSTimeInterval timeoutInterval;
/**
 *  @brief 最大并发数, 默认是-1, 也即不限制
 *
 *  @note  仅支持request网络任务, 不支持cache任务
 */
@property (nonatomic, assign) NSInteger requestMaxConcurrentCount;
/**
 *  @brief 磁盘缓存的文件夹路径
 */
@property (nonatomic, copy) NSString *cacheDirectoryPath;
/**
 *  @brief 全局的插件
 */
@property (nonatomic, readonly) NSArray<id<JSNetworkPluginProtocol>> *plugins;
/**
 *  @brief JSNetworkInterface的响应类
 */
@property (nullable, nonatomic, strong) id<JSNetworkInterfaceBuilder> interfaceBuilder;

/**
 *  @brief 单例
 */
+ (instancetype)sharedConfig;

/**
 *  @brief 添加一个用于URL全局参数的字典
 *
 *  @param parameters 字典
 */
- (void)addURLParameters:(NSDictionary<NSString *, id> *)parameters NS_SWIFT_NAME(addUrlParameters(_:));
/**
 *  @brief 清除全部URL全局参数的字典
 */
- (void)clearURLParameters NS_SWIFT_NAME(clearUrlParameters());

/**
 *  @brief 添加一个HTTPHeaderField
 *
 *  @param headerFields headerFields
 */
- (void)addHTTPHeaderFields:(NSDictionary<NSString *, NSString *> *)headerFields NS_SWIFT_NAME(addHttpHeaderFields(_:));
/**
 *  @brief 清除HTTPHeaderField
 */
- (void)clearHTTPHeaderFields NS_SWIFT_NAME(clearHttpHeaderFields());

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
