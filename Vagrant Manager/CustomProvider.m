//
//  CustomProvider.m
//  Vagrant Manager
//
//  Copyright (c) 2015 Lanayo. All rights reserved.
//

#import "CustomProvider.h"

@implementation CustomProvider

- (id)init {
    self = [super init];
    
    if(self) {
        self.name = @"";
    }
    
    return self;
}

- (id)copyWithZone:(NSZone*)zone {
    CustomProvider *provider = [[[self class] allocWithZone:zone] init];
    
    if(provider) {
        provider.name = self.name;
    }
    
    return provider;
}

@end
