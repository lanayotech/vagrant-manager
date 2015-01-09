//
//  CustomCommandManager.m
//  Vagrant Manager
//
//  Copyright (c) 2015 Lanayo. All rights reserved.
//

#import "ManageCustomCommandsWindow.h"
#import "CustomCommandManager.h"

@implementation ManageCustomCommandsWindow

- (void)windowDidLoad {
    [super windowDidLoad];
    
    _commands = [[CustomCommandManager sharedManager] getCustomCommands];
    [self.commandsTableView registerForDraggedTypes:[NSArray arrayWithObjects:NSPasteboardTypeString, nil]];
    
    [self.commandsTableView reloadData];
}

- (void)addCommandButtonClicked:(id)sender {
    CustomCommand *customCommand = [[CustomCommand alloc] init];
    customCommand.displayName = @"New Command";
    
    [_commands addObject:customCommand];
    [self saveCustomCommands];
    
    [self.commandsTableView reloadData];
}

- (IBAction)removeCommandButtonClicked:(id)sender {
    [_commands removeObjectsAtIndexes:[self.commandsTableView selectedRowIndexes]];
    
    [self saveCustomCommands];
    
    [self.commandsTableView reloadData];
}

- (void)saveCustomCommands {
    [[CustomCommandManager sharedManager] setCustomCommands:_commands];
    [[CustomCommandManager sharedManager] saveCustomCommands];
    _commands = [[CustomCommandManager sharedManager] getCustomCommands];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"vagrant-manager.custom-commands-updated" object:nil];
}

- (BOOL)tableView:(NSTableView *)tableView acceptDrop:(id < NSDraggingInfo >)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)operation {
    NSIndexSet *rowIndexes = [NSKeyedUnarchiver unarchiveObjectWithData:[[info draggingPasteboard] dataForType:NSPasteboardTypeString]];

    NSArray *commandsToMove = [_commands objectsAtIndexes:rowIndexes];
    [_commands removeObjectsAtIndexes:rowIndexes];
    
    [_commands insertObjects:commandsToMove atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(row, [commandsToMove count])]];
    
    [tableView reloadData];
    
    [self saveCustomCommands];
    
    return YES;
}

- (NSDragOperation)tableView:(NSTableView *)tableView validateDrop:(id <NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)operation {
    
    NSIndexSet *rowIndexes = [NSKeyedUnarchiver unarchiveObjectWithData:[[info draggingPasteboard] dataForType:NSPasteboardTypeString]];
    
    if ([info draggingSource] == self.commandsTableView && operation == NSTableViewDropAbove && ![rowIndexes containsIndex:row] && row < _commands.count) {
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
    return _commands.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    CustomCommand *customCommand = [_commands objectAtIndex:row];
    if([tableColumn.identifier isEqualToString:@"name"]) {
        return customCommand.displayName;
    } else if([tableColumn.identifier isEqualToString:@"command"]) {
        return customCommand.command;
    } else if([tableColumn.identifier isEqualToString:@"runInTerminal"]) {
        return [NSNumber numberWithBool:customCommand.runInTerminal];
    } else {
        return @"";
    }
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    CustomCommand *customCommand = [_commands objectAtIndex:row];

    if([tableColumn.identifier isEqualToString:@"name"]) {
        customCommand.displayName = object;
    } else if([tableColumn.identifier isEqualToString:@"command"]) {
        customCommand.command = object;
    } else if([tableColumn.identifier isEqualToString:@"runInTerminal"]) {
        customCommand.runInTerminal = [object boolValue];
    }

    [self saveCustomCommands];

    [self.commandsTableView reloadData];
}

-(void)windowWillClose:(NSNotification *)notification {
    //TODO: remove window reference
}

@end
