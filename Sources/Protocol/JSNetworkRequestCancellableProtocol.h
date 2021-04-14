//
//  JSNetworkRequestCancellableProtocol.h
//  JSNetwork
//
//  Created by jiasong on 2021/4/14.
//

#import <Foundation/Foundation.h>

@protocol JSNetworkInterfaceProtocol;

NS_ASSUME_NONNULL_BEGIN

@protocol JSNetworkRequestCancellableProtocol <NSObject>

@required

/**
 *  @brief 任务id
 */
@property (nonatomic, copy, readonly) NSString *taskIdentifier;
/**
 *  @brief 请求是否已经取消
 */
@property (nonatomic, readonly) BOOL isCancelled;

/**
 *  @brief 初始化
 *
 *  @param taskIdentifier 任务id
 */
- (instancetype)initWithTaskIdentifier:(NSString *)taskIdentifier NS_SWIFT_NAME(init(taskIdentifier:));

/**
 *  @brief 取消请求
 */
- (void)cancel;

@end

NS_ASSUME_NONNULL_END
