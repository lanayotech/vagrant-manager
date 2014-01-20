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

+ (BOOL)isRegistered {
    return NO;
}

@end
