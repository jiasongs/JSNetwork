//
//  JSNetwork.h
//  JSNetwork
//
//  Created by jiasong on 2020/4/18.
//  Copyright © 2020 jiasong. All rights reserved.
//

#ifndef JSNetwork_h
#define JSNetwork_h

#if __has_include(<JSNetwork/JSNetwork.h>)

#import <JSNetwork/JSNetworkRequestProtocol.h>
#import <JSNetwork/JSNetworkRequestConfigProtocol.h>
#import <JSNetwork/JSNetworkInterfaceProtocol.h>
#import <JSNetwork/JSNetworkResponseProtocol.h>
#import <JSNetwork/JSNetworkPluginProtocol.h>
#import <JSNetwork/JSNetworkDiskCacheProtocol.h>
#import <JSNetwork/JSNetworkDiskCacheMetadataProtocol.h>
#import <JSNetwork/JSNetworkProvider.h>
#import <JSNetwork/JSNetworkAgent.h>
#import <JSNetwork/JSNetworkInterface.h>
#import <JSNetwork/JSNetworkConfig.h>
#import <JSNetwork/JSNetworkRequest.h>
#import <JSNetwork/JSNetworkResponse.h>
#import <JSNetwork/JSNetworkDiskCache.h>
#import <JSNetwork/JSNetworkDiskCacheMetadata.h>
#import <JSNetwork/JSNetworkProxy.h>
#import <JSNetwork/JSNetworkRequestConfigProxy.h>
#import <JSNetwork/JSNetworkUtil.h>
#import <JSNetwork/NSDictionary+JSURL.h>
#import <JSNetwork/NSString+JSURLCode.h>

#else

#import "JSNetworkRequestProtocol.h"
#import "JSNetworkRequestConfigProtocol.h"
#import "JSNetworkInterfaceProtocol.h"
#import "JSNetworkResponseProtocol.h"
#import "JSNetworkPluginProtocol.h"
#import "JSNetworkDiskCacheProtocol.h"
#import "JSNetworkDiskCacheMetadataProtocol.h"
#import "JSNetworkProvider.h"
#import "JSNetworkAgent.h"
#import "JSNetworkInterface.h"
#import "JSNetworkConfig.h"
#import "JSNetworkRequest.h"
#import "JSNetworkResponse.h"
#import "JSNetworkDiskCache.h"
#import "JSNetworkDiskCacheMetadata.h"
#import "JSNetworkProxy.h"
#import "JSNetworkRequestConfigProxy.h"
#import "JSNetworkUtil.h"
#import "NSDictionary+JSURL.h"
#import "NSString+JSURLCode.h"

#endif /* __has_include */

#endif /* JSNetwork_h */
