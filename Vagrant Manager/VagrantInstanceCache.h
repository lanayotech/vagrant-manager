//
//  VagrantInstanceCache.h
//  Vagrant Manager
//
//  Copyright © 2019 Lanayo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VagrantInstanceCache : NSObject

+ (void)cacheInstance:(VagrantInstance*)instance;
+ (VagrantInstance*)restoreCachedInstance:(VagrantInstance*)instance;

@end

NS_ASSUME_NONNULL_END
