//
//  JSNetworkDiskCacheMetadata.m
//  JSNetwork
//
//  Created by jiasong on 2020/4/22.
//

#import "JSNetworkDiskCacheMetadata.h"

@implementation JSNetworkDiskCacheMetadata

@synthesize appVersionString = _appVersionString;
@synthesize cacheData = _cacheData;
@synthesize creationDate = _creationDate;
@synthesize version = _version;

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:@(_version) forKey:NSStringFromSelector(@selector(version))];
    [aCoder encodeObject:_creationDate forKey:NSStringFromSelector(@selector(creationDate))];
    [aCoder encodeObject:_appVersionString forKey:NSStringFromSelector(@selector(appVersionString))];
    [aCoder encodeObject:_cacheData forKey:NSStringFromSelector(@selector(cacheData))];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _version = [[aDecoder decodeObjectOfClass:[NSNumber class] forKey:NSStringFromSelector(@selector(version))] integerValue];
        _creationDate = [aDecoder decodeObjectOfClass:[NSDate class] forKey:NSStringFromSelector(@selector(creationDate))];
        _appVersionString = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(appVersionString))];
        _cacheData = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(cacheData))];
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return true;
}

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"JSNetworkDiskCacheMetadata - 已经释放");
#endif
}

@end
