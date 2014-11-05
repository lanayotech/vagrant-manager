//
//  ManageBookmarksWindow.h
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ManageBookmarksWindow : NSWindowController <NSTableViewDataSource, NSTableViewDelegate, NSWindowDelegate, NSTextFieldDelegate, NSComboBoxDelegate> {
    NSMutableArray *bookmarks;
}

@property (weak) IBOutlet NSButton *recursiveScanCheckbox;
@property (weak) IBOutlet NSTableView *bookmarkTableView;
@property (weak) IBOutlet NSButton *cancelScanButton;
@property (weak) IBOutlet NSTextField *directoryLabelTextField;
@property (weak) IBOutlet NSButton *addBookmarksButton;
@property (weak) IBOutlet NSButton *removeBookmarksButton;
@property (weak) IBOutlet NSButton *cancelButton;
@property (weak) IBOutlet NSButton *saveButton;

- (IBAction)cancelButtonClicked:(id)sender;
- (IBAction)saveButtonClicked:(id)sender;
- (IBAction)addBookmarksButtonClicked:(id)sender;
- (IBAction)removeBookmarksButtonClicked:(id)sender;
- (IBAction)recursiveScanCheckboxClicked:(id)sender;
- (IBAction)cancelScanButtonClicked:(id)sender;

@end
