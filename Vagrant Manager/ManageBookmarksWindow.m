//
//  ManageBookmarksWindow.m
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import "ManageBookmarksWindow.h"
#import "BookmarkManager.h"

@interface ManageBookmarksWindow ()

@end

@implementation ManageBookmarksWindow

- (id)initWithWindow:(NSWindow *)window {
    self = [super initWithWindow:window];

    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    bookmarks = [[NSMutableArray alloc] initWithArray:[[BookmarkManager sharedManager] getBookmarks] copyItems:YES];
    
    self.bookmarkTableView.delegate = self;
    self.bookmarkTableView.dataSource = self;
    
    [self.recursiveScanCheckbox setState:[[NSUserDefaults standardUserDefaults] integerForKey:@"recursiveBookmarkScan"] ? NSOnState : NSOffState];
    
    for (NSTableColumn *tableColumn in self.bookmarkTableView.tableColumns ) {
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:tableColumn.identifier ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
        [tableColumn setSortDescriptorPrototype:sortDescriptor];
    }
    
    [self.bookmarkTableView registerForDraggedTypes:[NSArray arrayWithObjects:NSPasteboardTypeString, nil]];
}

- (void)tableView:(NSTableView *)tableView sortDescriptorsDidChange:(NSArray *)oldDescriptors {
    bookmarks = [NSMutableArray arrayWithArray:[bookmarks sortedArrayUsingDescriptors:self.bookmarkTableView.sortDescriptors]];
    [self.bookmarkTableView reloadData];
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

- (BOOL)tableView:(NSTableView *)tableView acceptDrop:(id < NSDraggingInfo >)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)operation {
    NSIndexSet *rowIndexes = [NSKeyedUnarchiver unarchiveObjectWithData:[[info draggingPasteboard] dataForType:NSPasteboardTypeString]];
    Bookmark *targetObject = [bookmarks objectAtIndex:row];
    
	NSArray *bookmarksToMove = [bookmarks objectsAtIndexes:rowIndexes];
    [bookmarks removeObjectsAtIndexes:rowIndexes];
    
    NSUInteger targetIndex = [bookmarks indexOfObjectIdenticalTo:targetObject];
    
    [bookmarksToMove enumerateObjectsUsingBlock:^(Bookmark *bookmark, NSUInteger idx, BOOL *stop) {
        [bookmarks insertObject:bookmark atIndex:targetIndex+idx];
    }];
    
	[tableView reloadData];
    return YES;
}

- (NSDragOperation)tableView:(NSTableView *)tableView validateDrop:(id <NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)operation {
    
    NSIndexSet *rowIndexes = [NSKeyedUnarchiver unarchiveObjectWithData:[[info draggingPasteboard] dataForType:NSPasteboardTypeString]];
 
    if ([info draggingSource] == self.bookmarkTableView && operation == NSTableViewDropAbove && ![rowIndexes containsIndex:row] && row < bookmarks.count) {
        return operation;
    }
    
    return NSDragOperationNone;
}

- (BOOL)tableView:(NSTableView *)tableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pasteboard {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes];
    [pasteboard declareTypes:[NSArray arrayWithObject:NSPasteboardTypeString] owner:self];
    [pasteboard setData:data forType:NSPasteboardTypeString];
    return YES;
}

- (void)addBookmarkWithPath:(NSString*)path displayName:(NSString*)displayName {
    Bookmark *bookmark = [[Bookmark alloc] init];
    bookmark.displayName = displayName;
    bookmark.path = [Util trimTrailingSlash:path];
    bookmark.providerIdentifier = [[VagrantManager sharedManager] detectVagrantProvider:path];
    
    [bookmarks addObject:bookmark];
}

- (void)controlTextDidEndEditing:(NSNotification *)notification {
    NSTextField *textField = notification.object;
    if(![textField isKindOfClass:[NSComboBox class]]) {
        Bookmark *bookmark = [bookmarks objectAtIndex:textField.tag];
        bookmark.displayName = textField.stringValue;
    }
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
    [[BookmarkManager sharedManager] clearBookmarks];
    for(Bookmark *bookmark in bookmarks) {
        [[BookmarkManager sharedManager] addBookmark:bookmark];
    }
    [[BookmarkManager sharedManager] saveBookmarks];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"vagrant-manager.bookmarks-updated" object:nil];
    [self close];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    Bookmark *bookmark = [bookmarks objectAtIndex:row];
    
    if([tableColumn.identifier isEqualToString:@"providerIdentifier"]) {
        NSComboBox *view = [tableView makeViewWithIdentifier:@"ProviderCellView" owner:self];
        
        if(!view) {
            view = [[NSComboBox alloc] initWithFrame:CGRectMake(0, 0, tableColumn.width, 24)];
            NSArray *providerIdentifiers = [[VagrantManager sharedManager] getProviderIdentifiers];
            for(NSString *providerIdentifier in providerIdentifiers) {
                [view addItemWithObjectValue:providerIdentifier];
            }
            view.identifier = @"ProviderCellView";
        }
        view.tag = row;
        view.delegate = self;
        [view setStringValue:bookmark.providerIdentifier];
        
        return view;
    }
    
    NSTextField *view = [tableView makeViewWithIdentifier:@"TableCellView" owner:self];
    if(!view) {
        view = [[NSTextField alloc] initWithFrame:CGRectMake(0, 0, tableColumn.width, 24)];
        [view setBezeled:NO];
        [view setDrawsBackground:NO];
        view.delegate = self;
        [view.cell setLineBreakMode:NSLineBreakByTruncatingTail];
        view.identifier = @"TableCellView";
    }
    
    [view.cell setEditable:NO];
    view.tag = row;
    
    
    if ([tableColumn.identifier isEqualToString:@"path"]) {
        view.stringValue = bookmark.path;
    } else if ([tableColumn.identifier isEqualToString:@"displayName"]) {
        [view.cell setEditable:YES];
        view.stringValue = bookmark.displayName;
    }
    
    return view;
}

- (void)comboBoxSelectionDidChange:(NSNotification *)notification {
    NSComboBox *comboBox = notification.object;
    Bookmark *bookmark = [bookmarks objectAtIndex:comboBox.tag];
    bookmark.providerIdentifier = [comboBox objectValueOfSelectedItem];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return bookmarks.count;
}

@end
