//
//  VagrantInstanceCache.m
//  Vagrant Manager
//
//  Copyright © 2019 Lanayo. All rights reserved.
//

#import "VagrantInstanceCache.h"

NSString * const USER_DEFAULTS_CACHE_KEY = @"vagrant-instance-cache";
NSString * const VAGRANT_INSTANCE_PROVIDER_IDENTIFIER_KEY = @"providerIdentifier";

@implementation VagrantInstanceCache

+ (void)cacheInstance:(VagrantInstance*)instance {
    @synchronized(self) {
        NSMutableDictionary *cache = [[[NSUserDefaults standardUserDefaults] dictionaryForKey:USER_DEFAULTS_CACHE_KEY] mutableCopy] ?: [@{} mutableCopy];
        NSMutableDictionary *existingCache = [[self cacheForPath:instance.path] mutableCopy] ?: [@{} mutableCopy];
        
        existingCache[VAGRANT_INSTANCE_PROVIDER_IDENTIFIER_KEY] = instance.providerIdentifier;
        [cache setObject:existingCache forKey:instance.path];
        
        [[NSUserDefaults standardUserDefaults] setObject:cache forKey:USER_DEFAULTS_CACHE_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (NSDictionary * _Nullable)cacheForPath:(NSString*)path {
    NSDictionary *cache = [[NSUserDefaults standardUserDefaults] dictionaryForKey:USER_DEFAULTS_CACHE_KEY];
    return [cache objectForKey:path];
}

+ (VagrantInstance*)restoreCachedInstance:(VagrantInstance*)instance {
    NSDictionary *cache = [[NSUserDefaults standardUserDefaults] dictionaryForKey:USER_DEFAULTS_CACHE_KEY];
    NSDictionary *instanceCache = [cache objectForKey:instance.path];
    
    instance.providerIdentifier = [instanceCache objectForKey:VAGRANT_INSTANCE_PROVIDER_IDENTIFIER_KEY] ?: instance.providerIdentifier;
    
    return instance;
}

@end
