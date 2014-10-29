//
//  NativeMenuItem.h
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NativeMenuItem : NSObject

@property (strong) VagrantInstance *instance;
@property (strong) NSMenuItem *menuItem;

@end
