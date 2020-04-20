//
//  JSNetworkUtil.h
//  ITHomeClient
//
//  Created by jiasong on 2020/4/20.
//  Copyright © 2020 ruanmei. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JSNetworkUtil : NSObject

@end

@interface JSNetworkUtil (FilterURL)

+ (NSString *)filterURL:(NSString *)URL withParameter:(NSDictionary<NSString *, id> *)parameter;

@end

@interface JSNetworkUtil (Logger)

FOUNDATION_EXPORT void JSNetworkLog(NSString *format, ...);

@end

NS_ASSUME_NONNULL_END
