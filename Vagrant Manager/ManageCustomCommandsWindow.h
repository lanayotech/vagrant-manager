//
//  CustomCommandManager.m
//  Vagrant Manager
//
//  Copyright (c) 2015 Lanayo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ManageCustomCommandsWindow : NSWindowController <NSTableViewDataSource, NSTableViewDelegate, NSWindowDelegate, NSTextFieldDelegate> {
    NSMutableArray *_commands;
}

@property (weak) IBOutlet NSButton *addCommandButton;
@property (weak) IBOutlet NSButton *removeCommandButton;
@property (weak) IBOutlet NSTableView *commandsTableView;

- (IBAction)addCommandButtonClicked:(id)sender;
- (IBAction)removeCommandButtonClicked:(id)sender;

@end
