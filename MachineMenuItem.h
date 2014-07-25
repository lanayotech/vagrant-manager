//
//  MachineMenuItem.h
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "VagrantMachine.h"

@class MachineMenuItem;

@interface MachineMenuItem : NSView

@property (weak) IBOutlet NSImageView *stateImageView;
@property (weak) IBOutlet NSTextField *nameTextField;

@property (strong, nonatomic) VagrantMachine *machine;

@end
