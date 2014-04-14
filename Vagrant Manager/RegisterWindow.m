//
//  RegisterWindow.m
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import "RegisterWindow.h"
#import "Environment.h"

@interface RegisterWindow ()

@end

@implementation RegisterWindow

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
}

- (IBAction)validateButtonClicked:(id)sender {
    Licensing *lic = [Licensing sharedInstance];
    
    NSString *licenseKey = [self.licenseKeyTextField stringValue];

    licenseKey = [licenseKey stringByReplacingOccurrencesOfString:@"-" withString:@""];
    licenseKey = [licenseKey stringByReplacingOccurrencesOfString:@" " withString:@""];
    licenseKey = [licenseKey stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    
    if([licenseKey length] > 32) {
        [arr addObject:[licenseKey substringWithRange:NSMakeRange(0, [licenseKey length] - 32)]];
        [arr addObject:[licenseKey substringWithRange:NSMakeRange([licenseKey length] - 32, 8)]];
        [arr addObject:[licenseKey substringWithRange:NSMakeRange([licenseKey length] - 32 + 8, 8)]];
        [arr addObject:[licenseKey substringWithRange:NSMakeRange([licenseKey length] - 32 + 16, 8)]];
        [arr addObject:[licenseKey substringWithRange:NSMakeRange([licenseKey length] - 32 + 24, 8)]];
    }
    
    NSString *formattedLicenseKey = [arr componentsJoinedByString:@"-"];
    
    if([lic validateLicense:formattedLicenseKey]) {
        [lic storeLicenseKey:formattedLicenseKey];        
        
        NSAlert *alert = [NSAlert alertWithMessageText:@"Thank you for registering!" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@""];
        [alert runModal];
        
        [[Util getApp] rebuildMenu:YES];
        
        [self close];
    } else {
        NSAlert *alert = [NSAlert alertWithMessageText:@"The license key you have entered is invalid." defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@""];
        [alert runModal];
    }
}

- (IBAction)purchaseLicenseButtonClicked:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[[Environment sharedInstance] buyURL]]];
}

@end
