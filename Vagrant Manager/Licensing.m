//
//  Licensing.m
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import "Licensing.h"

#import <CommonCrypto/CommonDigest.h>

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

- (BOOL)validateLicense:(NSString *)licenseKey {
    NSString *secretKey = @"497bf1451685d7832a87e86d1d5dec1a";
    
    NSArray *parts = [[licenseKey lowercaseString] componentsSeparatedByString:@"-"];
    
    NSString *checkKey = [parts objectAtIndex:0];
    
    const char *cStr = [[NSString stringWithFormat:@"%@:%@", checkKey, secretKey] UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (uint)strlen(cStr), digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2 + [licenseKey length] + 1];
    
    [output appendString:checkKey];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        if(i%4 == 0) {
            [output appendString:@"-"];
        }
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return [output isEqualToString:licenseKey];
}

@end
