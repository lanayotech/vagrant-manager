//
//  MachineMenuItem.h
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "VagrantMachine.h"

@class MachineMenuItem;

@protocol MachineMenuItemDelegate <NSObject>

- (void)machineMenuItem:(MachineMenuItem*)menuItem vagrantAction:(NSString*)action;

@end

@interface MachineMenuItem : NSView

@property (weak) IBOutlet NSImageView *stateImageView;
@property (weak) IBOutlet NSTextField *nameTextField;

@property (strong, nonatomic) VagrantMachine *machine;
@property (weak) id<MachineMenuItemDelegate> delegate;

@property (weak) IBOutlet NSButton *sshButton;
@property (weak) IBOutlet NSButton *upButton;
@property (weak) IBOutlet NSButton *reloadButton;
@property (weak) IBOutlet NSButton *suspendButton;
@property (weak) IBOutlet NSButton *haltButton;
@property (weak) IBOutlet NSButton *provisionButton;
@property (weak) IBOutlet NSButton *destroyButton;

- (IBAction)sshButtonClicked:(id)sender;
- (IBAction)upButtonClicked:(id)sender;
- (IBAction)reloadButtonClicked:(id)sender;
- (IBAction)suspendButtonClicked:(id)sender;
- (IBAction)haltButtonClicked:(id)sender;
- (IBAction)provisionButtonClicked:(id)sender;
- (IBAction)destroyButtonClicked:(id)sender;

@end
