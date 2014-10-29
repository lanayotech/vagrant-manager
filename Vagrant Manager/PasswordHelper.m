//
//  PasswordHelper.m
//
//  Created by Ira Cooke on 27/07/2009.
//  Copyright 2009 Mudflat Software. 
//

#import "PasswordHelper.h"

@implementation PasswordHelper

+ (NSArray*) promptForPassword {
	CFUserNotificationRef passwordDialog;
	SInt32 error;
	CFOptionFlags responseFlags;
	int button;
	CFStringRef passwordRef;
	
	NSMutableArray *returnArray = [NSMutableArray arrayWithObjects:@"PasswordString", [NSNumber numberWithInt:0], [NSNumber numberWithInt:1], nil];
	
    NSURL * iconUrl =
    [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@",
                            [[[NSBundle mainBundle] executablePath] stringByDeletingLastPathComponent],
                            @"appicon_128.png"
                            ]];

    NSDictionary *panelDict = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"Enter Your Password", kCFUserNotificationAlertHeaderKey,
                               @"Vagrant Requested Administrator Privileges", kCFUserNotificationAlertMessageKey,
							   @"", kCFUserNotificationTextFieldTitlesKey,
							   @"Cancel", kCFUserNotificationAlternateButtonTitleKey,
                               (__bridge CFURLRef)iconUrl, kCFUserNotificationIconURLKey,
							   nil];

    passwordDialog = CFUserNotificationCreate(kCFAllocatorDefault,
											  0,
											  kCFUserNotificationPlainAlertLevel
											  |
											  CFUserNotificationSecureTextField(0),
											  &error,
											  (__bridge CFDictionaryRef)panelDict);
	
	
	if (error) {
		// There was an error creating the password dialog
		CFRelease(passwordDialog);
		[returnArray replaceObjectAtIndex:1 withObject:[NSNumber numberWithInt:error]];
		return returnArray;
	}
	
	error = CFUserNotificationReceiveResponse(passwordDialog,
											  0,
											  &responseFlags);

	if (error) {
		CFRelease(passwordDialog);
		[returnArray replaceObjectAtIndex:1 withObject:[NSNumber numberWithInt:error]];
		return returnArray;
	}
	
	
	button = responseFlags & 0x3;
	if (button == kCFUserNotificationAlternateResponse) {
		CFRelease(passwordDialog);
		[returnArray replaceObjectAtIndex:1 withObject:[NSNumber numberWithInt:1]];
		return returnArray;		
	}
	
	passwordRef = CFUserNotificationGetResponseValue(passwordDialog,
													 kCFUserNotificationTextFieldValuesKey,
													 0);
	
	
	[returnArray replaceObjectAtIndex:0 withObject:(__bridge NSString*)passwordRef];
	CFRelease(passwordDialog);
	return returnArray;	
}

@end
