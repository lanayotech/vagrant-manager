//
//  Licensing.h
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Licensing : NSObject

@property (strong, nonatomic) NSDate *firstRunDate;

+ (Licensing*)sharedInstance;

- (BOOL)isRegistered;
- (BOOL)isExpired;
- (NSDateComponents*)getTrialLength;
- (NSDate*)getExpirationDate;
- (BOOL)validateLicense:(NSString*)licenseKey;

@end
