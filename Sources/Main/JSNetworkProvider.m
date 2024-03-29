//
//  JSNetworkProvider.m
//  JSNetwork
//
//  Created by jiasong on 2020/4/17.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import "JSNetworkProvider.h"
#import "JSNetworkAgent.h"
#import "JSNetworkInterface.h"
#import "JSNetworkRequestProtocol.h"
#import "JSNetworkConfig.h"
#import "JSNetworkRequestCancellable.h"
#import <objc/runtime.h>

@interface JSNetworkProviderEntity : NSObject

@property (nonatomic, strong) JSNetworkRequestCancellable *cancellable;

@end

@implementation JSNetworkProviderEntity

- (instancetype)initWithCancellable:(JSNetworkRequestCancellable *)cancellable {
    if (self = [super init]) {
        _cancellable = cancellable;
    }
    return self;
}

- (void)dealloc {
    if (_cancellable) {
        [_cancellable cancel];
    }
}

@end

@interface NSObject (__JSNetworkProvider)

@property (nonatomic, strong, readonly) NSMutableArray<JSNetworkProviderEntity *> *jsnet_providerEntitys;

@end

@implementation NSObject (__JSNetworkProvider)

- (void)js_bindCancellable:(JSNetworkRequestCancellable *)cancellable {
    [self.jsnet_providerEntitys addObject:[[JSNetworkProviderEntity alloc] initWithCancellable:cancellable]];
}

- (NSMutableArray<JSNetworkProviderEntity *> *)jsnet_providerEntitys {
    NSMutableArray *providerEntitys = objc_getAssociatedObject(self, _cmd);
    if (!providerEntitys) {
        providerEntitys = [NSMutableArray array];
        objc_setAssociatedObject(self, _cmd, providerEntitys, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return providerEntitys;
}

@end

@implementation JSNetworkProvider

+ (id<JSNetworkRequestCancellableProtocol>)requestWithConfig:(id<JSNetworkRequestConfigProtocol>)config
                                                   completed:(nullable JSNetworkRequestCompletedBlock)completed {
    return [self requestWithConfig:config
                    uploadProgress:nil
                  downloadProgress:nil
                         completed:completed];
}

+ (id<JSNetworkRequestCancellableProtocol>)requestWithConfig:(id<JSNetworkRequestConfigProtocol>)config
                                                    onTarget:(nullable __kindof NSObject *)target
                                                   completed:(nullable void (^)(__kindof NSObject *_Nullable target, id<JSNetworkInterfaceProtocol> aInterface))completed {
    return [self requestWithConfig:config
                          onTarget:target
                    uploadProgress:nil
                  downloadProgress:nil
                         completed:completed];
}

+ (id<JSNetworkRequestCancellableProtocol>)requestWithConfig:(id<JSNetworkRequestConfigProtocol>)config
                                              uploadProgress:(nullable JSNetworkProgressBlock)uploadProgress
                                                   completed:(nullable JSNetworkRequestCompletedBlock)completed {
    return [self requestWithConfig:config
                    uploadProgress:uploadProgress
                  downloadProgress:nil
                         completed:completed];
}

+ (id<JSNetworkRequestCancellableProtocol>)requestWithConfig:(id<JSNetworkRequestConfigProtocol>)config
                                                    onTarget:(nullable __kindof NSObject *)target
                                              uploadProgress:(nullable JSNetworkProgressBlock)uploadProgress
                                                   completed:(nullable void (^)(__kindof NSObject *_Nullable target, id<JSNetworkInterfaceProtocol> aInterface))completed {
    return [self requestWithConfig:config
                          onTarget:target
                    uploadProgress:uploadProgress
                  downloadProgress:nil
                         completed:completed];
}

+ (id<JSNetworkRequestCancellableProtocol>)requestWithConfig:(id<JSNetworkRequestConfigProtocol>)config
                                            downloadProgress:(nullable JSNetworkProgressBlock)downloadProgress
                                                   completed:(nullable JSNetworkRequestCompletedBlock)completed {
    return [self requestWithConfig:config
                    uploadProgress:nil
                  downloadProgress:downloadProgress
                         completed:completed];
}

+ (id<JSNetworkRequestCancellableProtocol>)requestWithConfig:(id<JSNetworkRequestConfigProtocol>)config
                                                    onTarget:(nullable __kindof NSObject *)target
                                            downloadProgress:(nullable JSNetworkProgressBlock)downloadProgress
                                                   completed:(nullable void (^)(__kindof NSObject *_Nullable target, id<JSNetworkInterfaceProtocol> aInterface))completed {
    return [self requestWithConfig:config
                          onTarget:target
                    uploadProgress:nil
                  downloadProgress:downloadProgress
                         completed:completed];
}

+ (id<JSNetworkRequestCancellableProtocol>)requestWithConfig:(id<JSNetworkRequestConfigProtocol>)config
                                              uploadProgress:(nullable JSNetworkProgressBlock)uploadProgress
                                            downloadProgress:(nullable JSNetworkProgressBlock)downloadProgress
                                                   completed:(nullable JSNetworkRequestCompletedBlock)completed {
    return [self requestWithConfig:config
                          onTarget:nil
                    uploadProgress:uploadProgress
                  downloadProgress:downloadProgress
                         completed:^(__kindof NSObject *_Nullable target, id<JSNetworkInterfaceProtocol> aInterface) {
        if (completed) {
            completed(aInterface);
        }
    }];
}

+ (id<JSNetworkRequestCancellableProtocol>)requestWithConfig:(id<JSNetworkRequestConfigProtocol>)config
                                                    onTarget:(nullable __kindof NSObject *)target
                                              uploadProgress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress
                                            downloadProgress:(nullable void (^)(NSProgress *downloadProgress))downloadProgress
                                                   completed:(nullable void (^)(__kindof NSObject *_Nullable target, id<JSNetworkInterfaceProtocol> aInterface))completed {
    NSParameterAssert(config);
    __weak __typeof(target) weakTarget = target;
    JSNetworkInterface *interface = [[JSNetworkInterface alloc] initWithRequestConfig:config
                                                                       uploadProgress:uploadProgress
                                                                     downloadProgress:downloadProgress
                                                                       completedBlock:^(id<JSNetworkInterfaceProtocol> aInterface) {
        if (completed) {
            completed(weakTarget, aInterface);
        }
    }];
    [JSNetworkAgent.defaultAgent performRequestForInterface:interface];
    
    JSNetworkRequestCancellable *cancellable = [[JSNetworkRequestCancellable alloc] initWithTaskIdentifier:interface.taskIdentifier];
    @synchronized (self) {
        [target js_bindCancellable:cancellable];
    }
    return cancellable;
}

@end

#pragma mark - TODO

@interface JSNetworkProvider (TODO)

@end

@implementation JSNetworkProvider (TODO)

+ (void)_batchRequestWithConfigs:(NSArray<id<JSNetworkRequestConfigProtocol>> *)configs
                       completed:(nullable void(^)(NSArray<id<JSNetworkInterfaceProtocol>> *aInterfaces))completed {
    dispatch_group_t group = dispatch_group_create();
    NSMutableArray<id<JSNetworkInterfaceProtocol>> *resultArray = [NSMutableArray arrayWithCapacity:configs.count];
    [configs enumerateObjectsUsingBlock:^(id<JSNetworkRequestConfigProtocol> config, NSUInteger idx, BOOL *stop) {
        dispatch_group_enter(group);
        [self requestWithConfig:config
                 uploadProgress:nil
               downloadProgress:nil
                      completed:^(id<JSNetworkInterfaceProtocol> aInterface) {
            [resultArray insertObject:aInterface atIndex:idx];
            dispatch_group_leave(group);
        }];
    }];
    dispatch_group_notify(group, JSNetworkConfig.sharedConfig.completionQueue, ^{
        completed(resultArray);
    });
}

+ (void)_chainRequestWithConfig:(id<JSNetworkRequestConfigProtocol>)config
                      nextBlock:(nullable id<JSNetworkRequestConfigProtocol>(^)(id<JSNetworkInterfaceProtocol> aInterface))nextBlock {
    [self requestWithConfig:config
             uploadProgress:nil
           downloadProgress:nil
                  completed:^(id<JSNetworkInterfaceProtocol> aInterface) {
        id<JSNetworkRequestConfigProtocol> nextConfig = nextBlock(aInterface);
        if (nextConfig) {
            [self _chainRequestWithConfig:nextConfig nextBlock:nextBlock];
        }
    }];
}

+ (void)onPressTest {
    [JSNetworkProvider _batchRequestWithConfigs:@[]
                                      completed:^(NSArray<id<JSNetworkInterfaceProtocol>> *aInterfaces) {
        
    }];
    [JSNetworkProvider _chainRequestWithConfig:nil
                                     nextBlock:^id<JSNetworkRequestConfigProtocol>(id<JSNetworkInterfaceProtocol> aInterface) {
        return nil;
    }];
}

@end
