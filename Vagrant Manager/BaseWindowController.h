//
//  BaseWindowController.h
//  Vagrant Manager
//
//  Copyright (c) 2015 Lanayo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BaseWindowController : NSWindowController

@property BOOL isClosed;

- (void)windowWillClose:(NSNotification *)notification;

@end
