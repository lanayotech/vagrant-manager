//
//  MachineMenuItem.h
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MachineMenuItem : NSView

@property (weak) IBOutlet NSImageView *stateImageView;
@property (weak) IBOutlet NSTextField *nameTextField;

@property (weak) IBOutlet NSButton *sshButton;
@property (weak) IBOutlet NSButton *upButton;
@property (weak) IBOutlet NSButton *reloadButton;
@property (weak) IBOutlet NSButton *suspendButton;
@property (weak) IBOutlet NSButton *haltButton;
@property (weak) IBOutlet NSButton *provisionButton;
@property (weak) IBOutlet NSButton *destroyButton;

@end
