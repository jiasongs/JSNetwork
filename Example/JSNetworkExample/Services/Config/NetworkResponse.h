//
//  NetworkResponse.h
//  JSNetwork
//
//  Created by jiasong on 2020/4/19.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import <JSNetworkResponse.h>

NS_ASSUME_NONNULL_BEGIN

@interface NetworkResponse : JSNetworkResponse

/**
 请求成功与否
 */
@property (nonatomic, assign) BOOL successful;
/**
 message值
 */
@property (nonatomic, copy) NSString *message;
/**
 返回处理后的数据
 */
@property (nonatomic, copy) id contentData;

@end

NS_ASSUME_NONNULL_END
