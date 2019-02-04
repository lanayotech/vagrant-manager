//
//  CustomProviderManager.m
//  Vagrant Manager
//
//  Copyright (c) 2015 Lanayo. All rights reserved.
//

#import "CustomProviderManager.h"

@implementation CustomProviderManager

+ (CustomProviderManager*)sharedManager {
    static CustomProviderManager *manager;
    @synchronized(self) {
        if(manager == nil) {
            manager = [[CustomProviderManager alloc] init];
        }
    }
    
    return manager;
}

- (id)init {
    self = [super init];
    
    if(self) {
        _providers = [[NSMutableArray alloc] init];
    }
    
    return self;
}

//load providers from shared preferences
- (void)loadCustomProviders {
    @synchronized(_providers) {
        [_providers removeAllObjects];
        
        NSArray *savedProviders = [[NSUserDefaults standardUserDefaults] arrayForKey:@"CustomProviders"];
        
        if(savedProviders) {
            for(NSDictionary *savedProvider in savedProviders) {
                [self addCustomProviderWithName:[savedProvider objectForKey:@"name"]];
            }
        }
    }
}

//save providers to shared preferences
- (void)saveCustomProviders {
    @synchronized(_providers) {
        NSMutableArray *providers = [self getCustomProviders];
        
        if(providers) {
            NSMutableArray *arr = [[NSMutableArray alloc] init];
            for(CustomProvider *cp in providers) {
                [arr addObject:@{@"name":cp.name}];
            }
            
            [[NSUserDefaults standardUserDefaults] setObject:arr forKey:@"CustomProviders"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}

- (void)clearCustomProviders {
    @synchronized(_providers) {
        [_providers removeAllObjects];
    }
}

- (CustomProvider*)addCustomProvider:(CustomProvider *)provider {
    @synchronized(_providers) {
        [_providers addObject:provider];
    }
    
    return provider;
}

- (void)setCustomProviders:(NSArray*)CustomProviders {
    @synchronized(_providers) {
        [_providers removeAllObjects];
        for(id provider in CustomProviders) {
            if([provider isKindOfClass:[CustomProvider class]]) {
                [_providers addObject:provider];
            }
        }
    }
}

- (NSMutableArray*)getCustomProviders {
    NSMutableArray *providers;
    @synchronized(_providers) {
        providers = [NSMutableArray arrayWithArray:_providers];
    }
    return providers;
}

- (CustomProvider*)addCustomProviderWithName:(NSString*)name {
    CustomProvider *provider = [[CustomProvider alloc] init];
    provider.name = name;
    
    @synchronized(_providers) {
        [_providers addObject:provider];
    }
    
    return provider;
}

- (void)removeCustomProvider:(CustomProvider *)provider {
    @synchronized(_providers) {
        [_providers removeObject:provider];
    }
}

@end
