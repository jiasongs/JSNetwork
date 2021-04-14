//
//  JSNetworkCancellableProtocol.h
//  JSNetwork
//
//  Created by jiasong on 2021/4/14.
//

#import <Foundation/Foundation.h>

@protocol JSNetworkInterfaceProtocol;

NS_ASSUME_NONNULL_BEGIN

@protocol JSNetworkCancellableProtocol <NSObject>

@required

/**
 *  @brief 接口
 *  @warn  务必使用弱引用!
 */
@property (nullable, nonatomic, weak, readonly) id<JSNetworkInterfaceProtocol> interface;
/**
 *  @brief 请求是否已经取消
 */
@property (nonatomic, readonly) BOOL isCancelled;

/**
 *  @brief 初始化
 *
 *  @param interface JSNetworkInterfaceProtocol
 */
- (instancetype)initWithInterface:(id<JSNetworkInterfaceProtocol>)interface NS_SWIFT_NAME(init(interface:));

/**
 *  @brief 取消请求
 */
- (void)cancel;

@end

NS_ASSUME_NONNULL_END
