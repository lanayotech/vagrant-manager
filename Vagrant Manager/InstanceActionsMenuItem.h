//
//  InstanceActionsMenuItem.h
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class InstanceActionsMenuItem;

@protocol InstanceActionsMenuItemDelegate <NSObject>

- (void)instanceActionsMenuItem:(InstanceActionsMenuItem*)menuItem vagrantAction:(NSString*)action;

@end

@interface InstanceActionsMenuItem : NSView

@property (strong, nonatomic) VagrantInstance *instance;
@property (weak) id<InstanceActionsMenuItemDelegate> delegate;

@property (weak) IBOutlet NSButton *upButton;
@property (weak) IBOutlet NSButton *reloadButton;
@property (weak) IBOutlet NSButton *suspendButton;
@property (weak) IBOutlet NSButton *haltButton;
@property (weak) IBOutlet NSButton *provisionButton;
@property (weak) IBOutlet NSButton *destroyButton;

@property (weak) IBOutlet NSButton *terminalButton;
@property (weak) IBOutlet NSButton *finderButton;
@property (weak) IBOutlet NSButton *bookmarkButton;

- (IBAction)upButtonClicked:(id)sender;
- (IBAction)reloadButtonClicked:(id)sender;
- (IBAction)suspendButtonClicked:(id)sender;
- (IBAction)haltButtonClicked:(id)sender;
- (IBAction)provisionButtonClicked:(id)sender;
- (IBAction)destroyButtonClicked:(id)sender;

@end
