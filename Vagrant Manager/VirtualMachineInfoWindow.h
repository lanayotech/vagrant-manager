//
//  VirtualMachineInfoWindow.h
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "VirtualMachineInfo.h"
#import "Bookmark.h"

@interface VirtualMachineInfoWindow : NSWindowController <NSTableViewDataSource, NSTableViewDelegate, NSWindowDelegate, NSTextFieldDelegate> {
    NSMutableArray *properties;
    NSMutableArray *sharedFolders;
}

@property (strong, nonatomic) Bookmark *bookmark;
@property (strong, nonatomic) VirtualMachineInfo *machine;

@property (weak) IBOutlet NSTableView *propertiesTableView;
@property (weak) IBOutlet NSTableView *sharedFoldersTableView;

@property (weak) IBOutlet NSTextField *nameEditTextField;
@property (weak) IBOutlet NSTextField *nameTextField;
@property (weak) IBOutlet NSTextField *osTextField;
@property (weak) IBOutlet NSTextField *uuidTextField;
@property (weak) IBOutlet NSTextField *stateTextField;
@property (weak) IBOutlet NSButton *updateNameButton;

- (IBAction)closeWindowButtonClicked:(id)sender;
- (IBAction)updateNameButtonClicked:(id)sender;

@end
