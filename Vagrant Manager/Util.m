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
                        @"a"
                       ];
    
    for(int i=0; i<alphas.count; ++i) {
        part1 = [part1 stringByReplacingOccurrencesOfString:[alphas objectAtIndex:i] withString:[NSString stringWithFormat:@".%d.", -(i+1)]];
        part2 = [part2 stringByReplacingOccurrencesOfString:[alphas objectAtIndex:i] withString:[NSString stringWithFormat:@".%d.", -(i+1)]];
    }
    
    return [self compareVersion:part1 toVersion:part2 skipExpansion:YES];
}

@end
