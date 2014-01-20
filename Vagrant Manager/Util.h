//
//  Util.h
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"

@interface Util : NSObject

+ (AppDelegate*)getApp;
+ (NSString*)escapeShellArg:(NSString*)arg;

+ (BOOL)isRegistered;

@end
