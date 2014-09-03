//
//  Util.m
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import "Util.h"

@implementation Util

+ (AppDelegate*)getApp {
    return (AppDelegate*)[[NSApplication sharedApplication] delegate];
}

+ (NSString*)escapeShellArg:(NSString*)arg {
    NSMutableString *result = [NSMutableString stringWithString:arg];
    [result replaceOccurrencesOfString:@"'" withString:@"'\\''" options:0 range:NSMakeRange(0, [result length])];
    [result insertString:@"'" atIndex:0];
    [result appendString:@"'"];
    return result;
}

+ (NSString*)trimTrailingSlash:(NSString*)path {
    if(path.length > 1 && [[path substringFromIndex:path.length-1] isEqualToString:@"/"]) {
        return [path substringToIndex:path.length-1];
    } else {
        return path;
    }
}

+ (NSComparisonResult)compareVersion:(NSString*)version1 toVersion:(NSString*)version2 {
    return [self compareVersion:version1 toVersion:version2 skipExpansion:NO];
}

+ (NSComparisonResult)compareVersion:(NSString*)version1 toVersion:(NSString*)version2 skipExpansion:(BOOL)skipExpansion {
    NSMutableArray *version1parts = [[version1 componentsSeparatedByString:@"."] mutableCopy];
    NSMutableArray *version2parts = [[version2 componentsSeparatedByString:@"."] mutableCopy];
    
    int partsCount = (version1parts.count > version2parts.count) ? (int)version1parts.count : (int)version2parts.count;
    
    while(version1parts.count < partsCount) {
        [version1parts addObject:@"0"];
    }
    
    while(version2parts.count < partsCount) {
        [version2parts addObject:@"0"];
    }
    
    for(int i=0; i<partsCount; ++i) {
        NSComparisonResult res;
        
        if(skipExpansion) {
            int p1 = [[version1parts objectAtIndex:i] intValue];
            int p2 = [[version2parts objectAtIndex:i] intValue];
            if(p1 > p2) {
                res = NSOrderedDescending;
            } else if(p1 < p2) {
                res = NSOrderedAscending;
            } else {
                res = NSOrderedSame;
            }
        } else {
            res = [self compareVersionPart:[version1parts objectAtIndex:i] toVersionPart:[version2parts objectAtIndex:i]];
        }
        
        if(res != NSOrderedSame) {
            return res;
        }
    }
    
    return NSOrderedSame;
}

+ (NSComparisonResult)compareVersionPart:(NSString*)part1 toVersionPart:(NSString*)part2 {
    NSArray *alphas = @[
                        @"RC",
                        @"beta",
                        @"b",
                        @"alpha",
                        @"a",
                        @"debug",
                        @"d"
                       ];
    
    for(int i=0; i<alphas.count; ++i) {
        part1 = [part1 stringByReplacingOccurrencesOfString:[alphas objectAtIndex:i] withString:[NSString stringWithFormat:@".%d.", -(i+1)]];
        part2 = [part2 stringByReplacingOccurrencesOfString:[alphas objectAtIndex:i] withString:[NSString stringWithFormat:@".%d.", -(i+1)]];
    }
    
    return [self compareVersion:part1 toVersion:part2 skipExpansion:YES];
}

+ (NSString*)getVersionStability:(NSString*)version {
    NSDictionary *classes = @{
                         @"rc": @[@"RC"],
                         @"beta": @[@"beta", @"b"],
                         @"alpha": @[@"alpha", @"a"],
                         @"debug": @[@"debug", @"d"]
                        };

    for(NSString *class in [classes allKeys]) {
        for(NSString *string in [classes objectForKey:class]) {
            if([version rangeOfString:string].location != NSNotFound) {
                return class;
            }
        }
    }
    
    return @"stable";
};

+ (void)redirectConsoleLogToDocumentFolder {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd-HHmmss"];
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *logPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"vagrant-manager-%@.log", [formatter stringFromDate:[NSDate date]]]];
    freopen([logPath fileSystemRepresentation],"a+",stderr);
}

+ (void)log:(NSObject*)message {
    NSLog(@"%@", message);
}

+ (NSString*)getMachineId {
    NSString *uuid = [[NSUserDefaults standardUserDefaults] stringForKey:@"machineId"];
    if(!uuid) {
        uuid = [[NSUUID UUID] UUIDString];
        [[NSUserDefaults standardUserDefaults] setObject:uuid forKey:@"machineId"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    return uuid;
}

+ (NSString*)getUpdateStability {
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"updateStability"] ?: @"stable";
}

+ (int)getUpdateStabilityScore:(NSString*)updateStability {
    if([updateStability isEqualToString:@"stable"]) {
        return 0;
    } else if([updateStability isEqualToString:@"rc"]) {
        return 1;
    } else if([updateStability isEqualToString:@"beta"]) {
        return 2;
    } else if([updateStability isEqualToString:@"alpha"]) {
        return 3;
    } else if([updateStability isEqualToString:@"debug"]) {
        return 4;
    } else {
        return 5;
    }
}

+ (BOOL)shouldSendProfileData {
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"sendProfileData"] == nil) {
        return YES;
    }
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"sendProfileData"];
}

@end
