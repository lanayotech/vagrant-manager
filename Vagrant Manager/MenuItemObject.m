//
//  MenuItemObject.m
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import "MenuItemObject.h"

@implementation MenuItemObject

- initWithTarget:(id)target {
    self = [super init];
    
    if(self) {
        self.target = target;
    }
    
    return self;
}

@end
