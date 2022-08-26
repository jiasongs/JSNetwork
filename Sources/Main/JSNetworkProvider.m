//
//  JSNetworkProvider.m
//  JSNetwork
//
//  Created by jiasong on 2020/4/17.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import "JSNetworkProvider.h"
#import "JSNetworkManager.h"
#import "JSNetworkConfig.h"
#import "JSNetworkRequestConfigProxy.h"
#import "JSNetworkRequestConfigProtocol.h"
#import "JSNetworkRequestCancellableProtocol.h"
#import "JSNetworkInterfaceProtocol.h"
#import <objc/runtime.h>

@interface JSNetworkProviderEntity : NSObject

@property (nonatomic, strong) id<JSNetworkRequestCancellableProtocol> cancellable;

@end

@implementation JSNetworkProviderEntity

- (instancetype)initWithCancellable:(id<JSNetworkRequestCancellableProtocol>)cancellable {
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

- (void)js_bindCancellable:(id<JSNetworkRequestCancellableProtocol>)cancellable {
    @synchronized (self) {
        [self.jsnet_providerEntitys addObject:[[JSNetworkProviderEntity alloc] initWithCancellable:cancellable]];
    }
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
                                                   completed:(nullable void (^)(id<JSNetworkInterfaceProtocol> aInterface))completed {
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
                                                   completed:(nullable void (^)(id<JSNetworkInterfaceProtocol> aInterface))completed {
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
                                                   completed:(nullable void (^)(id<JSNetworkInterfaceProtocol> aInterface))completed {
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
                                                   completed:(nullable void (^)(id<JSNetworkInterfaceProtocol> aInterface))completed {
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

    JSNetworkConfig *sharedConfig = JSNetworkConfig.sharedConfig;
    id<JSNetworkInterfaceProtocol> interface = sharedConfig.networkInterface(config);
    NSAssert(interface, @"请设置interface");
    
    interface.config = (id<JSNetworkRequestConfigProtocol>)[JSNetworkRequestConfigProxy proxyWithTarget:config];

    if ([interface.config respondsToSelector:@selector(request)]) {
        interface.request = interface.config.request;
    }
    NSAssert(interface.request, @"请设置request");
    
    if ([interface.config respondsToSelector:@selector(requestCancellable)]) {
        interface.requestCancellable = interface.config.requestCancellable;
    }
    NSAssert(interface.requestCancellable, @"请设置requestCancellable");

    if ([interface.config respondsToSelector:@selector(response)]) {
        interface.response = interface.config.response;
    }
    NSAssert(interface.response, @"请设置response");
    
    if (interface.config.cachePolicy == JSRequestCachePolicyUseCacheDataElseLoad) {
        if ([config respondsToSelector:@selector(diskCache)]) {
            interface.diskCache = config.diskCache;
        }
        NSAssert(interface.diskCache, @"请设置diskCache");
    }
    
    interface.uploadProgress = uploadProgress;
    
    interface.downloadProgress = downloadProgress;
    
    __weak __typeof(target) weakTarget = target;
    interface.completionHandler = ^(id<JSNetworkInterfaceProtocol> aInterface) {
        if (completed) {
            completed(weakTarget, aInterface);
        }
    };
    
    /// 生成任务ID
    static NSUInteger jsNetworkRequestTaskIdentifier = 0;
    static dispatch_queue_t identifierQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        identifierQueue = dispatch_queue_create("com.jsnetwork.task.identifier.queue", DISPATCH_QUEUE_SERIAL);
    });
    dispatch_sync(identifierQueue, ^{
        jsNetworkRequestTaskIdentifier = jsNetworkRequestTaskIdentifier + 1;
    });
    interface.taskIdentifier = [NSString stringWithFormat:@"%@_%@", @"task", @(jsNetworkRequestTaskIdentifier)];

    JSNetworkManager *defaultManager = JSNetworkManager.defaultManager;
    [defaultManager performRequestForInterface:interface];
    
    interface.requestCancellable.networkManager = defaultManager;
    interface.requestCancellable.taskIdentifier = interface.taskIdentifier;
   
    [target js_bindCancellable:interface.requestCancellable];
    return interface.requestCancellable;
}

@end
