//
//  VirtualMachineInfoWindow.h
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "VirtualMachineInfo.h"

@interface VirtualMachineInfoWindow : NSWindowController <NSTableViewDataSource, NSTableViewDelegate, NSWindowDelegate> {
    NSMutableArray *properties;
    NSMutableArray *sharedFolders;
}

@property (strong, nonatomic) VirtualMachineInfo *machine;

@property (weak) IBOutlet NSTableView *propertiesTableView;
@property (weak) IBOutlet NSTableView *sharedFoldersTableView;

@property (weak) IBOutlet NSTextField *nameTextField;
@property (weak) IBOutlet NSTextField *osTextField;
@property (weak) IBOutlet NSTextField *uuidTextField;
@property (weak) IBOutlet NSTextField *stateTextField;

- (IBAction)closeWindowButtonClicked:(id)sender;

@end
