//
//  InstanceActionsMenuItem.h
//  Vagrant Manager
//
//  Created by Chris Ayoub on 5/23/14.
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface InstanceActionsMenuItem : NSView

@property (weak) IBOutlet NSButton *terminalButton;
@property (weak) IBOutlet NSButton *finderButton;
@property (weak) IBOutlet NSButton *bookmarkButton;

@end
