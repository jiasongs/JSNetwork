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
#import "JSNetworkRequestTokenProtocol.h"
#import "JSNetworkInterfaceProtocol.h"
#import <objc/runtime.h>

@interface JSNetworkProviderEntity : NSObject

@property (nonatomic, strong) id<JSNetworkRequestTokenProtocol> requestToken;

@end

@implementation JSNetworkProviderEntity

- (instancetype)initWithToken:(id<JSNetworkRequestTokenProtocol>)requestToken {
    if (self = [super init]) {
        _requestToken = requestToken;
    }
    return self;
}

- (void)dealloc {
    if (_requestToken) {
        [_requestToken cancel];
    }
}

@end

@interface NSObject (__JSNetworkProvider)

@property (nonatomic, strong, readonly) NSMutableArray<JSNetworkProviderEntity *> *jsnet_providerEntitys;

@end

@implementation NSObject (__JSNetworkProvider)

- (void)js_bindToken:(id<JSNetworkRequestTokenProtocol>)requestToken {
    @synchronized (self) {
        [self.jsnet_providerEntitys addObject:[[JSNetworkProviderEntity alloc] initWithToken:requestToken]];
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

+ (id<JSNetworkRequestTokenProtocol>)requestWithConfig:(id<JSNetworkRequestConfigProtocol>)config
                                             completed:(nullable void (^)(id<JSNetworkInterfaceProtocol> aInterface))completed {
    return [self requestWithConfig:config
                    uploadProgress:nil
                  downloadProgress:nil
                         completed:completed];
}

+ (id<JSNetworkRequestTokenProtocol>)requestWithConfig:(id<JSNetworkRequestConfigProtocol>)config
                                              onTarget:(nullable __kindof NSObject *)target
                                             completed:(nullable void (^)(__kindof NSObject *_Nullable target, id<JSNetworkInterfaceProtocol> aInterface))completed {
    return [self requestWithConfig:config
                          onTarget:target
                    uploadProgress:nil
                  downloadProgress:nil
                         completed:completed];
}

+ (id<JSNetworkRequestTokenProtocol>)requestWithConfig:(id<JSNetworkRequestConfigProtocol>)config
                                        uploadProgress:(nullable JSNetworkProgressBlock)uploadProgress
                                             completed:(nullable void (^)(id<JSNetworkInterfaceProtocol> aInterface))completed {
    return [self requestWithConfig:config
                    uploadProgress:uploadProgress
                  downloadProgress:nil
                         completed:completed];
}

+ (id<JSNetworkRequestTokenProtocol>)requestWithConfig:(id<JSNetworkRequestConfigProtocol>)config
                                              onTarget:(nullable __kindof NSObject *)target
                                        uploadProgress:(nullable JSNetworkProgressBlock)uploadProgress
                                             completed:(nullable void (^)(__kindof NSObject *_Nullable target, id<JSNetworkInterfaceProtocol> aInterface))completed {
    return [self requestWithConfig:config
                          onTarget:target
                    uploadProgress:uploadProgress
                  downloadProgress:nil
                         completed:completed];
}

+ (id<JSNetworkRequestTokenProtocol>)requestWithConfig:(id<JSNetworkRequestConfigProtocol>)config
                                      downloadProgress:(nullable JSNetworkProgressBlock)downloadProgress
                                             completed:(nullable void (^)(id<JSNetworkInterfaceProtocol> aInterface))completed {
    return [self requestWithConfig:config
                    uploadProgress:nil
                  downloadProgress:downloadProgress
                         completed:completed];
}

+ (id<JSNetworkRequestTokenProtocol>)requestWithConfig:(id<JSNetworkRequestConfigProtocol>)config
                                              onTarget:(nullable __kindof NSObject *)target
                                      downloadProgress:(nullable JSNetworkProgressBlock)downloadProgress
                                             completed:(nullable void (^)(__kindof NSObject *_Nullable target, id<JSNetworkInterfaceProtocol> aInterface))completed {
    return [self requestWithConfig:config
                          onTarget:target
                    uploadProgress:nil
                  downloadProgress:downloadProgress
                         completed:completed];
}

+ (id<JSNetworkRequestTokenProtocol>)requestWithConfig:(id<JSNetworkRequestConfigProtocol>)config
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

+ (id<JSNetworkRequestTokenProtocol>)requestWithConfig:(id<JSNetworkRequestConfigProtocol>)config
                                              onTarget:(nullable __kindof NSObject *)target
                                        uploadProgress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress
                                      downloadProgress:(nullable void (^)(NSProgress *downloadProgress))downloadProgress
                                             completed:(nullable void (^)(__kindof NSObject *_Nullable target, id<JSNetworkInterfaceProtocol> aInterface))completed {
    NSParameterAssert(config);
    id<JSNetworkRequestConfigProtocol> configProxy = [JSNetworkRequestConfigProxy proxyWithTarget:config];
    
    id<JSNetworkInterfaceProtocol> interface = [JSNetworkConfig.sharedConfig.interfaceBuilder buildWithConfig:configProxy];
    NSAssert(interface, @"请设置interface");
    
    if (!interface.config) {
        interface.config = configProxy;
    }
    
    if ([interface.config respondsToSelector:@selector(request)]) {
        interface.request = interface.config.request;
    }
    NSAssert(interface.request, @"请设置request");
    
    if ([interface.config respondsToSelector:@selector(requestToken)]) {
        interface.requestToken = interface.config.requestToken;
    }
    NSAssert(interface.requestToken, @"请设置requestToken");
    
    if ([interface.config respondsToSelector:@selector(response)]) {
        interface.response = interface.config.response;
    }
    NSAssert(interface.response, @"请设置response");
    
    if ([interface.config respondsToSelector:@selector(cachePolicy)] && interface.config.cachePolicy == JSRequestCachePolicyUseCacheDataElseLoad) {
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
    
    interface.requestToken.networkManager = defaultManager;
    interface.requestToken.taskIdentifier = interface.taskIdentifier;
    
    [target js_bindToken:interface.requestToken];
    return interface.requestToken;
}

@end
