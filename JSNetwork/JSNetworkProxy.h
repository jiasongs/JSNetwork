//
//  JSNetworkProxy.h
//  JSNetwork
//
//  Created by jiasong on 2020/5/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JSNetworkProxy : NSProxy

@property (nonatomic, weak, readonly) id target;

+ (instancetype)proxyWithTarget:(id)target;
- (instancetype)initWithTarget:(id)target;

@end

NS_ASSUME_NONNULL_END
