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
#import "JSNetworkInterface.h"
#import "JSNetworkRequest.h"
#import "JSNetworkResponse.h"
#import "JSNetworkRequestToken.h"
#import "JSNetworkDiskCache.h"
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
    
    /// interface
    id<JSNetworkInterfaceProtocol> interface = [JSNetworkConfig.sharedConfig.interfaceBuilder buildWithConfig:configProxy];
    if (interface == nil) {
        interface = [[JSNetworkInterface alloc] init];
    }
    /// config
    if (interface.config == nil) {
        interface.config = configProxy;
    }
    /// request
    if ([interface.config respondsToSelector:@selector(request)]) {
        interface.request = interface.config.request;
    }
    if (interface.request == nil) {
        interface.request = [[JSNetworkRequest alloc] init];
    }
    /// requestToken
    if ([interface.config respondsToSelector:@selector(requestToken)]) {
        interface.requestToken = interface.config.requestToken;
    }
    if (interface.requestToken == nil) {
        interface.requestToken = [[JSNetworkRequestToken alloc] init];
    }
    /// response
    if ([interface.config respondsToSelector:@selector(response)]) {
        interface.response = interface.config.response;
    }
    if (interface.response == nil) {
        interface.response = [[JSNetworkResponse alloc] init];
    }
    /// diskCache
    if ([interface.config respondsToSelector:@selector(cachePolicy)] && interface.config.cachePolicy == JSRequestCachePolicyUseCacheDataElseLoad) {
        if ([config respondsToSelector:@selector(diskCache)]) {
            interface.diskCache = config.diskCache;
        }
        if (interface.diskCache == nil) {
            interface.diskCache = [[JSNetworkDiskCache alloc] init];
        }
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
