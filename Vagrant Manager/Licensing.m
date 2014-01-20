//
//  Licensing.m
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import "Licensing.h"

@implementation Licensing

static Licensing *_sharedInstance;

+ (Licensing*)sharedInstance {
    if(!_sharedInstance) {
        _sharedInstance = [[Licensing alloc] init];
        NSDate *firstRunDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"firstRunDate"];
        if(!firstRunDate) {
            firstRunDate = [NSDate date];
            [[NSUserDefaults standardUserDefaults] setObject:firstRunDate forKey:@"firstRunDate"];
        }
        
        _sharedInstance.firstRunDate = firstRunDate;
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    
    return _sharedInstance;
}

- (BOOL)isRegistered {
    return NO;
}

- (NSDate*)getExpirationDate {
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    return [cal dateByAddingComponents:[self getTrialLength] toDate:self.firstRunDate options:0];
}

- (BOOL)isExpired {
    if([self isRegistered]) {
        return NO;
    }
    
    NSDate *expirationDate = [self getExpirationDate];
    
    return [[NSDate date] compare:expirationDate] == NSOrderedDescending;
}

- (NSDateComponents*)getTrialLength {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:14];
    return components;
}

@end
