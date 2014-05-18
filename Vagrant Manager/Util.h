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
+ (NSString*)trimTrailingSlash:(NSString*)path;
+ (NSComparisonResult)compareVersion:(NSString*)version1 toVersion:(NSString*)version2;
+ (void)redirectConsoleLogToDocumentFolder;
+ (void)log:(NSObject*)message;
+ (NSString*)getMachineId;
+ (NSString*)getUpdateStability;
+ (NSString*)getVersionStability:(NSString*)version;
+ (int)getUpdateStabilityScore:(NSString*)updateStability;
+ (BOOL)shouldSendProfileData;
@end
