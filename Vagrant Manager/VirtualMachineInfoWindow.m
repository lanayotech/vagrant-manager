//
//  VirtualMachineInfoWindow.m
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import "VirtualMachineInfoWindow.h"
#import "AppDelegate.h"

@interface VirtualMachineInfoWindow ()

@end

@implementation VirtualMachineInfoWindow

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    properties = [[NSMutableArray alloc] init];
    sharedFolders = [[NSMutableArray alloc] init];
    
    for(NSString *name in self.machine.properties) {
        [properties addObject:@{@"name": name, @"value":[self.machine.properties objectForKey:name]}];
    }
    
    for(NSString *name in self.machine.sharedFolders) {
        [sharedFolders addObject:@{@"name": name, @"path":[self.machine.sharedFolders objectForKey:name]}];
    }
    
    self.window.title = [NSString stringWithFormat:@"%@ Details", self.machine.name];

    self.propertiesTableView.delegate = self;
    self.propertiesTableView.dataSource = self;
    
    self.sharedFoldersTableView.delegate = self;
    self.sharedFoldersTableView.dataSource = self;
    
    self.nameTextField.stringValue = self.machine.name;
    self.osTextField.stringValue = self.machine.os;
    self.uuidTextField.stringValue = self.machine.uuid;
    self.stateTextField.stringValue = self.machine.state;
}

- (void)windowWillClose:(NSNotification *)notification {
    AppDelegate *app = [Util getApp];
    
    [app removeInfoWindow:self];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    if(tableView == self.propertiesTableView) {
        return properties.count;
    } else if(tableView == self.sharedFoldersTableView) {
        return sharedFolders.count;
    } else {
        return 0;
    }
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSTextField *view = [tableView makeViewWithIdentifier:@"TableCellView" owner:self];
    if(!view) {
        view = [[NSTextField alloc] initWithFrame:CGRectMake(0, 0, tableColumn.width, 22)];
        [view setBezeled:NO];
        [view setDrawsBackground:NO];
        [view setEditable:NO];
        [view setSelectable:NO];
        view.identifier = @"TableCellView";
    }
    
    NSString *val;
    
    if(tableView == self.propertiesTableView) {
        val = [[properties objectAtIndex:row] objectForKey:tableColumn.identifier];
    } else if(tableView == self.sharedFoldersTableView) {
        val = [[sharedFolders objectAtIndex:row] objectForKey:tableColumn.identifier];
    }
    
    view.stringValue = val ?: @"N/A";
    
    return view;
}

- (IBAction)closeWindowButtonClicked:(id)sender {
    [self close];
}

@end
