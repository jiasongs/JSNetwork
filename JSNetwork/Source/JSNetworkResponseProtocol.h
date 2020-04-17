//
//  JSNetworkResponseProtocol.h
//  JSNetwork
//
//  Created by jiasong on 2020/4/17.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol JSNetworkResponseProtocol <NSObject>

@property (nonatomic, assign) BOOL successful;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) id contentData;

@end

NS_ASSUME_NONNULL_END
