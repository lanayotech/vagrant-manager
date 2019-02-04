//
//  ManageCustomProvidersWindow.m
//  Vagrant Manager
//
//  Copyright (c) 2019 Lanayo. All rights reserved.
//

#import "ManageCustomProvidersWindow.h"
#import "CustomProviderManager.h"

@implementation ManageCustomProvidersWindow

- (void)windowDidLoad {
    [super windowDidLoad];
    
    _providers = [[CustomProviderManager sharedManager] getCustomProviders];
    [self.providersTableView registerForDraggedTypes:[NSArray arrayWithObjects:NSPasteboardTypeString, nil]];
    
    [self.providersTableView reloadData];
}

- (void)addProviderButtonClicked:(id)sender {
    CustomProvider *customProvider = [[CustomProvider alloc] init];
    customProvider.name = @"New Provider";
    
    [_providers addObject:customProvider];
    [self saveCustomProviders];
    
    [self.providersTableView reloadData];
}

- (IBAction)removeProviderButtonClicked:(id)sender {
    [_providers removeObjectsAtIndexes:[self.providersTableView selectedRowIndexes]];
    
    [self saveCustomProviders];
    
    [self.providersTableView reloadData];
}

- (void)saveCustomProviders {
    [[CustomProviderManager sharedManager] setCustomProviders:_providers];
    [[CustomProviderManager sharedManager] saveCustomProviders];
    _providers = [[CustomProviderManager sharedManager] getCustomProviders];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"vagrant-manager.custom-providers-updated" object:nil];
}

- (BOOL)tableView:(NSTableView *)tableView acceptDrop:(id < NSDraggingInfo >)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)operation {
    NSIndexSet *rowIndexes = [NSKeyedUnarchiver unarchiveObjectWithData:[[info draggingPasteboard] dataForType:NSPasteboardTypeString]];

    NSArray *providersToMove = [_providers objectsAtIndexes:rowIndexes];
    [_providers removeObjectsAtIndexes:rowIndexes];
    
    [_providers insertObjects:providersToMove atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(row, [providersToMove count])]];
    
    [tableView reloadData];
    
    [self saveCustomProviders];
    
    return YES;
}

- (NSDragOperation)tableView:(NSTableView *)tableView validateDrop:(id <NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)operation {
    
    NSIndexSet *rowIndexes = [NSKeyedUnarchiver unarchiveObjectWithData:[[info draggingPasteboard] dataForType:NSPasteboardTypeString]];
    
    if ([info draggingSource] == self.providersTableView && operation == NSTableViewDropAbove && ![rowIndexes containsIndex:row] && row < _providers.count) {
        return (NSDragOperation)operation;
    }
    
    return NSDragOperationNone;
}

- (BOOL)tableView:(NSTableView *)tableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pasteboard {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes];
    [pasteboard declareTypes:[NSArray arrayWithObject:NSPasteboardTypeString] owner:self];
    [pasteboard setData:data forType:NSPasteboardTypeString];
    return YES;
}


- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return _providers.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    CustomProvider *customProvider = [_providers objectAtIndex:row];
    if([tableColumn.identifier isEqualToString:@"name"]) {
        return customProvider.name;
    } else {
        return @"";
    }
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    CustomProvider *customProvider = [_providers objectAtIndex:row];

    if([tableColumn.identifier isEqualToString:@"name"]) {
        customProvider.name = object;
    }

    [self saveCustomProviders];

    [self.providersTableView reloadData];
}

@end
