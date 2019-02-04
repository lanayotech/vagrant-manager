//
//  CustomProviderManager.h
//  Vagrant Manager
//
//  Copyright (c) 2015 Lanayo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CustomProvider.h"

@interface CustomProviderManager : NSObject {
    NSMutableArray *_providers;
}

+ (CustomProviderManager*)sharedManager;

- (void)loadCustomProviders;
- (void)saveCustomProviders;
- (void)clearCustomProviders;
- (NSMutableArray*)getCustomProviders;
- (CustomProvider*)addCustomProvider:(CustomProvider*)provider;
- (CustomProvider*)addCustomProviderWithName:(NSString*)name;
- (void)removeCustomProvider:(CustomProvider*)provider;
- (void)setCustomProviders:(NSArray*)CustomProviders;

@end
