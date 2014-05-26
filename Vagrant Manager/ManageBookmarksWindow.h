//
//  ManageBookmarksWindow.h
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ManageBookmarksWindow : NSWindowController <NSTableViewDataSource, NSTableViewDelegate, NSWindowDelegate, NSTextFieldDelegate> {
    NSMutableArray *bookmarks;
}

@property (weak) IBOutlet NSTableView *bookmarkTableView;

- (IBAction)cancelButtonClicked:(id)sender;
- (IBAction)saveButtonClicked:(id)sender;
- (IBAction)addBookmarksButtonClicked:(id)sender;
- (IBAction)removeBookmarksButtonClicked:(id)sender;

@end
