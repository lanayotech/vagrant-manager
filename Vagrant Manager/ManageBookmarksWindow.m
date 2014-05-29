//
//  ManageBookmarksWindow.m
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import "ManageBookmarksWindow.h"

@interface ManageBookmarksWindow ()

@end

@implementation ManageBookmarksWindow

- (id)initWithWindow:(NSWindow *)window {
    self = [super initWithWindow:window];

    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    bookmarks = [NSMutableArray arrayWithArray:[[Util getApp] getSavedBookmarks]];
    
    self.bookmarkTableView.delegate = self;
    self.bookmarkTableView.dataSource = self;
    
    [self.recursiveScanCheckbox setState:[[NSUserDefaults standardUserDefaults] integerForKey:@"recursiveBookmarkScan"] ? NSOnState : NSOffState];
}

- (IBAction)addBookmarksButtonClicked:(id)sender {
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    
    [openDlg setCanChooseFiles:NO];
    [openDlg setCanChooseDirectories:YES];
    [openDlg setAllowsMultipleSelection:YES];
    
    [openDlg beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if(result == NSFileHandlingPanelOKButton) {
            NSArray *urls = [openDlg URLs];
            
            NSFileManager *fileManager = [[NSFileManager alloc] init];
            
            NSMutableArray *bookmarkPaths = [[NSMutableArray alloc] init];
            for(Bookmark *b in bookmarks) {
                [bookmarkPaths addObject:b.path];
            }
            
            for(NSURL *directoryURL in urls) {
                if ([[NSUserDefaults standardUserDefaults] integerForKey:@"recursiveBookmarkScan"] == NSOnState) {
                    NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtURL:directoryURL includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles errorHandler:nil];
                    
                    for (NSURL *url in enumerator) {
                        NSString *path = [url.path stringByDeletingLastPathComponent];
                        if ([[url.path lastPathComponent] isEqualToString:@"Vagrantfile"] && ![bookmarkPaths containsObject:path]) {
                            [self addBookmarkWithPath:path displayName:[path lastPathComponent]];
                        }
                    }
                } else {
                    if ([fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@/Vagrantfile", directoryURL.path]] && ![bookmarkPaths containsObject:directoryURL.path]) {
                        [self addBookmarkWithPath:directoryURL.path displayName:[directoryURL.path lastPathComponent]];
                    }
                }
            }
            
            [self.bookmarkTableView reloadData];
        }
    }];
}

- (void)addBookmarkWithPath:(NSString*)path displayName:(NSString*)displayName {
    Bookmark *bookmark = [[Bookmark alloc] init];
    bookmark.displayName = displayName;
    bookmark.path = path;
    
    [bookmarks addObject:bookmark];
}

- (IBAction)removeBookmarksButtonClicked:(id)sender {
    [bookmarks removeObjectsAtIndexes:[self.bookmarkTableView selectedRowIndexes]];
    [self.bookmarkTableView reloadData];
}

- (IBAction)recursiveScanCheckboxClicked:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:self.recursiveScanCheckbox.state forKey:@"recursiveBookmarkScan"];
}

- (IBAction)cancelButtonClicked:(id)sender {
    [self close];
}

- (IBAction)saveButtonClicked:(id)sender {
    for(int i = 0; i < bookmarks.count; i++) {
        NSTextField *textField = [self.bookmarkTableView viewAtColumn:1 row:i makeIfNecessary:FALSE];
        Bookmark *bookmark = [bookmarks objectAtIndex:i];
        bookmark.displayName = textField.stringValue;
    }
    
    [[Util getApp] saveBookmarks:bookmarks];
    [[Util getApp] reloadBookmarks];
    [[Util getApp] detectVagrantMachines];
    [self close];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSTextField *view = [tableView makeViewWithIdentifier:@"TableCellView" owner:self];
    if(!view) {
        view = [[NSTextField alloc] initWithFrame:CGRectMake(0, 0, tableColumn.width, 22)];
        [view setBezeled:NO];
        [view setDrawsBackground:NO];
        [view setEditable:NO];
        view.delegate = self;
        [view.cell setLineBreakMode:NSLineBreakByTruncatingTail];
        view.identifier = @"TableCellView";
    }
    
    Bookmark *bookmark = [bookmarks objectAtIndex:row];
    
    if ([tableColumn.identifier isEqualToString:@"path"]) {
        view.stringValue = bookmark.path;
    }
    if ([tableColumn.identifier isEqualToString:@"displayName"]) {
        [view.cell setEditable:YES];
        view.stringValue = bookmark.displayName;
    }
    
    return view;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return bookmarks.count;
}

@end
