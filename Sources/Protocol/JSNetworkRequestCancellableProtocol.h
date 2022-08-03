//
//  JSNetworkRequestCancellableProtocol.h
//  JSNetwork
//
//  Created by jiasong on 2021/4/14.
//

#import <Foundation/Foundation.h>

@class JSNetworkAgent;

NS_ASSUME_NONNULL_BEGIN

@protocol JSNetworkRequestCancellableProtocol <NSObject>

@required
/**
 *  @brief 请求代理类
 */
@property (nonatomic, weak) JSNetworkAgent *agent;
/**
 *  @brief 任务id
 */
@property (nonatomic, copy) NSString *taskIdentifier;
/**
 *  @brief 请求是否已经取消
 */
@property (nonatomic, readonly) BOOL isCancelled;

/**
 *  @brief 取消请求
 */
- (void)cancel;

@end

NS_ASSUME_NONNULL_END
