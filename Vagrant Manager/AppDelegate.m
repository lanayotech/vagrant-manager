//
//  AppDelegate.m
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import "AppDelegate.h"

#define MENU_ITEM_VAGRANT_SSH 7
#define MENU_ITEM_VAGRANT_UP 1
#define MENU_ITEM_VAGRANT_HALT 2
#define MENU_ITEM_VAGRANT_DESTROY 3
#define MENU_ITEM_OPEN_IN_FINDER 8
#define MENU_ITEM_OPEN_IN_TERMINAL 9
#define MENU_ITEM_DETAILS 4
#define MENU_ITEM_ADD_BOOKMARK 5
#define MENU_ITEM_REMOVE_BOOKMARK 6

@implementation AppDelegate

#pragma mark - Application events

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSBundle *bundle = [NSBundle mainBundle];
    
    //initialize data
    taskOutputWindows = [[NSMutableArray alloc] init];
    infoWindows = [[NSMutableArray alloc] init];
    detectedVagrantMachines = [[NSMutableArray alloc] init];
    bookmarks = [self getSavedBookmarks];
    
    //create status bar menu item
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setImage:[[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"vagrant_logo" ofType:@"png"]]];
    [statusItem setAlternateImage:[[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"vagrant_logo_highlighted" ofType:@"png"]]];
    [statusItem setMenu:statusMenu];
    [statusItem setHighlightMode:YES];
    
    [statusMenu setDelegate:self];
    
    [self rebuildMenu];
    [self detectVagrantMachines];
}

- (void)menuWillOpen:(NSMenu *)menu {
    if(menu == statusMenu) {
        @synchronized(detectedVagrantMachines) {
            detectedVagrantMachines = [self sortVirtualMachines:detectedVagrantMachines];
        }
        [self rebuildMenu];
    }
}

#pragma mark - Bookmarks

- (NSMutableArray*)getSavedBookmarks {
    NSMutableArray *bookmarksArray = [[NSMutableArray alloc] init];
    
    NSArray *savedBookmarks = [[NSUserDefaults standardUserDefaults] arrayForKey:@"bookmarks"];
    if(savedBookmarks) {
        for(NSDictionary *savedBookmark in savedBookmarks) {
            Bookmark *bookmark = [[Bookmark alloc] init];
            bookmark.displayName = [savedBookmark objectForKey:@"displayName"];
            bookmark.path = [savedBookmark objectForKey:@"path"];
            
            if(bookmark.displayName && bookmark.path) {
                [bookmarksArray addObject:bookmark];
            }
        }
    }
    
    return bookmarksArray;
}

- (void)saveBookmarks:(NSMutableArray*)bm {
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for(Bookmark *b in bm) {
        [arr addObject:@{@"displayName":b.displayName, @"path":b.path}];
    }
    [[NSUserDefaults standardUserDefaults] setObject:arr forKey:@"bookmarks"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)addBookmarkForVirtualMachine:(VirtualMachineInfo*)machine {
    for(Bookmark *b in bookmarks) {
        if([b.path isEqualToString:[machine getSharedFolderPathWithName:@"/vagrant"]]) {
            return;
        }
    }
    
    Bookmark *bookmark = [[Bookmark alloc] init];
    bookmark.displayName = machine.name;
    bookmark.path = [machine getSharedFolderPathWithName:@"/vagrant"];
    [bookmarks addObject:bookmark];
    
    machine.bookmark = bookmark;
    
    [self saveBookmarks:bookmarks];
}

- (void)removeBookmark:(Bookmark*)bookmark {
    VirtualMachineInfo *machine = [self getVirtualMachineForBookmark:bookmark];
    if(machine) {
        machine.bookmark = nil;
    }
    [bookmarks removeObject:bookmark];
    [self saveBookmarks:bookmarks];
}

- (Bookmark*)getBookmarkByPath:(NSString*)path {
    for(Bookmark *bookmark in bookmarks) {
        if([bookmark.path isEqualToString:path]) {
            return bookmark;
        }
    }
    
    return nil;
}

- (void)updateBookmarkState:(Bookmark*)bookmark {
    VirtualMachineInfo *machine = [self getVirtualMachineForBookmark:bookmark];
    if(machine) {
        [self updateVirtualMachineState:machine];
    } else {
        [self detectVagrantMachines];
    }
}


#pragma mark - Vagrant machine control
- (void)runTerminalCommand:(NSString*)command {
    NSString *terminalName = [[NSUserDefaults standardUserDefaults] valueForKey:@"terminalName"];

    NSString *s = @"";
    if ([terminalName isEqualToString:@"iTerm"]) {
        s = [NSString stringWithFormat:@"tell application \"iTerm\"\n"
                       "tell current terminal\n"
                       "launch session \"Default Session\"\n"
                       "delay .15\n"
                       "activate\n"
                       "tell the last session\n"
                       "write text \"%@\"\n"
                       "end tell\n"
                       "end tell\n"
                       "end tell\n", command];
    } else {
        s = [NSString stringWithFormat:@"tell application \"Terminal\"\n"
                       "activate\n"
                       "do script \"%@\"\n"
                       "end tell\n", command];
    }
    
    NSAppleScript *as = [[NSAppleScript alloc] initWithSource: s];
    [as executeAndReturnError:nil];
}

- (void)runVagrantAction:(NSString*)action withObject:(id)obj {
    NSString *command;
    
    if ([action isEqualToString:@"ssh"]) {
        command = @"vagrant ssh";
    } else if([action isEqualToString:@"up"]) {
        command = @"vagrant up";
    } else if([action isEqualToString:@"halt"]) {
        command = @"vagrant halt";
    } else if([action isEqualToString:@"destroy"]) {
        command = @"vagrant destroy -f";
    }
    
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/sh"];
    
    VirtualMachineInfo *machine;
    Bookmark *bookmark;
    
    if([obj isKindOfClass:[VirtualMachineInfo class]]) {
        machine = obj;
    } else if([obj isKindOfClass:[Bookmark class]]) {
        bookmark = obj;
    }
    
    NSString *taskCommand = [NSString stringWithFormat:@"cd %@ && %@", bookmark ? [Util escapeShellArg:bookmark.path] : [Util escapeShellArg:[machine getSharedFolderPathWithName:@"/vagrant"]], command];
    
    [task setArguments:@[@"-c", taskCommand]];
    
    TaskOutputWindow *outputWindow = [[TaskOutputWindow alloc] initWithWindowNibName:@"TaskOutputWindow"];
    outputWindow.task = task;
    outputWindow.taskCommand = taskCommand;
    outputWindow.machine = machine;
    outputWindow.bookmark = bookmark;
    outputWindow.taskAction = command;
    
    [NSApp activateIgnoringOtherApps:YES];
    [outputWindow showWindow:self];
    
    [taskOutputWindows addObject:outputWindow];
}

#pragma mark - Menu management

- (void)rebuildMenu {
    NSBundle *bundle = [NSBundle mainBundle];
    
    [statusMenu removeAllItems];
    
    @synchronized(detectedVagrantMachines) {
        //add refresh button
        if(!refreshDetectedMenuItem) {
            refreshDetectedMenuItem = [[NSMenuItem alloc] init];
            [refreshDetectedMenuItem setTitle:@"Detect Vagrant Machines"];
            [refreshDetectedMenuItem setAction:@selector(refreshDetectedMenuItemClicked:)];
        }
        [statusMenu addItem:refreshDetectedMenuItem];
        
        [statusMenu addItem:[NSMenuItem separatorItem]];
        
        //add bookmarks
        if(bookmarks.count == 0) {
            NSMenuItem *i = [[NSMenuItem alloc] init];
            [i setTitle:@"No Bookmarks Added"];
            [i setEnabled:NO];
            [statusMenu addItem:i];
        } else {
            for(Bookmark *bookmark in bookmarks) {
                VirtualMachineInfo *machine = [self getVirtualMachineForBookmark:bookmark];
                NSMenuItem *i = [[NSMenuItem alloc] init];
                [i setTitle:bookmark.displayName];
                
                [i setEnabled:YES];
                [i setImage:[[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:[machine isRunning]?@"on":@"off" ofType:@"png"]]];
                [i setTag:MenuItemDetected];
                [i setRepresentedObject:bookmark];
                
                [statusMenu addItem:i];
                
                NSMenu *submenu = [statusSubMenuTemplate copy];
                
                if(machine.isRunning) {
                    NSMenuItem *vagrantSsh = [submenu itemWithTag:MENU_ITEM_VAGRANT_SSH];
                    [vagrantSsh setAction:@selector(vagrantSshMenuItemClicked:)];
                    
                    NSMenuItem *vagrantUp = [submenu itemWithTag:MENU_ITEM_VAGRANT_UP];
                    [vagrantUp setEnabled:NO];
                    
                    NSMenuItem *vagrantHalt = [submenu itemWithTag:MENU_ITEM_VAGRANT_HALT];
                    [vagrantHalt setAction:@selector(vagrantHaltMenuItemClicked:)];
                } else {
                    NSMenuItem *vagrantSsh = [submenu itemWithTag:MENU_ITEM_VAGRANT_SSH];
                    [vagrantSsh setEnabled:NO];
                    
                    NSMenuItem *vagrantUp = [submenu itemWithTag:MENU_ITEM_VAGRANT_UP];
                    [vagrantUp setAction:@selector(vagrantUpMenuItemClicked:)];
                    
                    NSMenuItem *vagrantHalt = [submenu itemWithTag:MENU_ITEM_VAGRANT_HALT];
                    [vagrantHalt setEnabled:NO];
                }
                
                NSMenuItem *vagrantDestroy = [submenu itemWithTag:MENU_ITEM_VAGRANT_DESTROY];
                if(!machine) {
                    [vagrantDestroy setEnabled:NO];
                } else {
                    [vagrantDestroy setAction:@selector(vagrantDestroyMenuItemClicked:)];
                }
                
                NSMenuItem *virtualMachineDetails = [submenu itemWithTag:MENU_ITEM_DETAILS];
                if(!machine) {
                    [virtualMachineDetails setEnabled:NO];
                } else {
                    [virtualMachineDetails setAction:@selector(virtualMachineDetailsMenuItemClicked:)];
                }
                
                NSMenuItem *openInFinder = [submenu itemWithTag:MENU_ITEM_OPEN_IN_FINDER];
                [openInFinder setAction:@selector(vagrantOpenInFinderMenuItemClicked:)];
                
                NSMenuItem *openInTerminal = [submenu itemWithTag:MENU_ITEM_OPEN_IN_TERMINAL];
                [openInTerminal setAction:@selector(vagrantOpenInTerminalMenuItemClicked:)];
                
                NSMenuItem *removeBookmark = [submenu itemWithTag:MENU_ITEM_REMOVE_BOOKMARK];
                [removeBookmark setAction:@selector(removeBookmarkMenuItemClicked:)];
                
                [statusMenu setSubmenu:submenu forItem:i];
            }
        }
        
        if(!bookmarksSeparatorMenuItem) {
            bookmarksSeparatorMenuItem = [NSMenuItem separatorItem];
        }
        [statusMenu addItem:bookmarksSeparatorMenuItem];
        
        if(detectedVagrantMachines.count == 0) {
            NSMenuItem *i = [[NSMenuItem alloc] init];
            [i setTitle:@"No detected VMs"];
            [i setTag:MenuItemDetected];
            [i setEnabled:NO];
            [statusMenu addItem:i];
        }
        
        for(VirtualMachineInfo *machine in detectedVagrantMachines) {
            if(machine.bookmark) {
                continue;
            }
            
            NSMenuItem *i = [[NSMenuItem alloc] init];
            [i setTitle:machine.name];
            
            [i setEnabled:YES];
            [i setImage:[[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:[machine isRunning]?@"on":@"off" ofType:@"png"]]];
            [i setTag:MenuItemDetected];
            [i setRepresentedObject:machine];
            
            [statusMenu addItem:i];
            
            NSMenu *submenu = [statusSubMenuTemplate copy];
            
            if(machine.isRunning) {
                NSMenuItem *vagrantSsh = [submenu itemWithTag:MENU_ITEM_VAGRANT_SSH];
                [vagrantSsh setAction:@selector(vagrantSshMenuItemClicked:)];
                
                NSMenuItem *vagrantUp = [submenu itemWithTag:MENU_ITEM_VAGRANT_UP];
                [vagrantUp setEnabled:NO];
                
                NSMenuItem *vagrantHalt = [submenu itemWithTag:MENU_ITEM_VAGRANT_HALT];
                [vagrantHalt setAction:@selector(vagrantHaltMenuItemClicked:)];
            } else {
                NSMenuItem *vagrantSsh = [submenu itemWithTag:MENU_ITEM_VAGRANT_SSH];
                [vagrantSsh setEnabled:NO];
                
                NSMenuItem *vagrantUp = [submenu itemWithTag:MENU_ITEM_VAGRANT_UP];
                [vagrantUp setAction:@selector(vagrantUpMenuItemClicked:)];
                
                NSMenuItem *vagrantHalt = [submenu itemWithTag:MENU_ITEM_VAGRANT_HALT];
                [vagrantHalt setEnabled:NO];
            }
            
            NSMenuItem *vagrantDestroy = [submenu itemWithTag:MENU_ITEM_VAGRANT_DESTROY];
            [vagrantDestroy setAction:@selector(vagrantDestroyMenuItemClicked:)];
            
            NSMenuItem *openInFinder = [submenu itemWithTag:MENU_ITEM_OPEN_IN_FINDER];
            [openInFinder setAction:@selector(vagrantOpenInFinderMenuItemClicked:)];
            
            NSMenuItem *openInTerminal = [submenu itemWithTag:MENU_ITEM_OPEN_IN_TERMINAL];
            [openInTerminal setAction:@selector(vagrantOpenInTerminalMenuItemClicked:)];
            
            NSMenuItem *virtualMachineDetails = [submenu itemWithTag:MENU_ITEM_DETAILS];
            [virtualMachineDetails setAction:@selector(virtualMachineDetailsMenuItemClicked:)];
            
            NSMenuItem *addBookmark = [submenu itemWithTag:MENU_ITEM_ADD_BOOKMARK];
            [addBookmark setAction:@selector(addBookmarkMenuItemClicked:)];
            
            [statusMenu setSubmenu:submenu forItem:i];
        }
    }
    
    if(!detectedSeparatorMenuItem) {
        detectedSeparatorMenuItem = [NSMenuItem separatorItem];
    }
    [statusMenu addItem:detectedSeparatorMenuItem];
    
    //add static items
    if(!windowMenuItem) {
        windowMenuItem = [[NSMenuItem alloc] init];
        [windowMenuItem setTitle:@"Windows"];
        [statusMenu setSubmenu:self.windowMenu forItem:windowMenuItem];
    }
    [statusMenu addItem:windowMenuItem];
    
    //TODO: implement this eventually
    /*
    if(!preferencesMenuItem) {
        preferencesMenuItem = [[NSMenuItem alloc] init];
        [preferencesMenuItem setTitle:@"Preferences"];
    }
    [statusMenu addItem:preferencesMenuItem];
     */
    
    if(!aboutMenuItem) {
        aboutMenuItem = [[NSMenuItem alloc] init];
        [aboutMenuItem setTitle:@"About"];
        [aboutMenuItem setAction:@selector(aboutMenuItemClicked:)];
    }
    [statusMenu addItem:aboutMenuItem];
    
    if(!quitMenuItem) {
        quitMenuItem = [[NSMenuItem alloc] init];
        [quitMenuItem setTitle:@"Quit"];
        [quitMenuItem setAction:@selector(terminate:)];
    }
    [statusMenu addItem:quitMenuItem];
    
    int runningCount = [self getRunningVmCount];
    if(runningCount > 0 ) {
        [statusItem setTitle:[NSString stringWithFormat:@"%d", runningCount]];
    } else {
        [statusItem setTitle:@""];
    }
}

- (void)removeDetectedMenuItems {
    while(true) {
        NSMenuItem *i = [statusMenu itemWithTag:MenuItemDetected];
        if(!i) {
            break;
        }
        [statusMenu removeItem:i];
    };
}

- (void)removeBookmarkedMenuItems {
    while(true) {
        NSMenuItem *i = [statusMenu itemWithTag:MenuItemBookmarked];
        if(!i) {
            break;
        }
        [statusMenu removeItem:i];
    };
}

#pragma mark - Menu Item Handlers

- (IBAction)refreshDetectedMenuItemClicked:(id)sender {
    [self detectVagrantMachines];
}

- (IBAction)aboutMenuItemClicked:(id)sender {
    aboutWindow = [[AboutWindow alloc] initWithWindowNibName:@"AboutWindow"];
    [aboutWindow showWindow:self];
}

- (void)vagrantSshMenuItemClicked:(NSMenuItem*)menuItem {
    VirtualMachineInfo* machine = [self getMachineFromObject:menuItem.parentItem.representedObject];
    if(machine) {
        NSString *action = [NSString stringWithFormat:@"cd %@ && vagrant ssh", [Util escapeShellArg:[machine getSharedFolderPathWithName:@"/vagrant"]]];
        [self runTerminalCommand:action];
    }
}

- (void)vagrantUpMenuItemClicked:(NSMenuItem*)menuItem {
    [self runVagrantAction:@"up" withObject:menuItem.parentItem.representedObject];
}

- (void)vagrantHaltMenuItemClicked:(NSMenuItem*)menuItem {
    [self runVagrantAction:@"halt" withObject:menuItem.parentItem.representedObject];
}

- (void)vagrantDestroyMenuItemClicked:(NSMenuItem*)menuItem {
    NSString *name;
    if([menuItem.parentItem.representedObject isKindOfClass:[VirtualMachineInfo class]]) {
        name = ((VirtualMachineInfo*)menuItem.parentItem.representedObject).name;
    } else if([menuItem.parentItem.representedObject isKindOfClass:[Bookmark class]]) {
        name = ((Bookmark*)menuItem.parentItem.representedObject).displayName;
    }
    
    NSAlert *confirmAlert = [NSAlert alertWithMessageText:[NSString stringWithFormat:@"Are you sure you want to destroy \"%@\"?", name] defaultButton:@"Confirm" alternateButton:@"Cancel" otherButton:nil informativeTextWithFormat:@""];
    NSInteger button = [confirmAlert runModal];
    
    if(button == NSAlertDefaultReturn) {
        [self runVagrantAction:@"destroy" withObject:menuItem.parentItem.representedObject];
    }
}

- (void)virtualMachineDetailsMenuItemClicked:(NSMenuItem*)menuItem {
    VirtualMachineInfo *machine = [self getMachineFromObject:menuItem.parentItem.representedObject];
    
    if(machine) {
        VirtualMachineInfoWindow *infoWindow = [[VirtualMachineInfoWindow alloc] initWithWindowNibName:@"VirtualMachineInfoWindow"];
        infoWindow.machine = machine;
        [NSApp activateIgnoringOtherApps:YES];
        [infoWindow showWindow:self];
        
        [infoWindows addObject:infoWindow];
    }
}

- (void)vagrantOpenInFinderMenuItemClicked:(NSMenuItem*)menuItem {
    NSString *path = nil;
    if([menuItem.parentItem.representedObject isKindOfClass:[VirtualMachineInfo class]]) {
        VirtualMachineInfo *machine = [menuItem parentItem].representedObject;
        path = [machine getSharedFolderPathWithName:@"/vagrant"];
    } else if([menuItem.parentItem.representedObject isKindOfClass:[Bookmark class]]) {
        Bookmark *bookmark = menuItem.parentItem.representedObject;
        path = bookmark.path;
    }
    
    if(path) {
        NSURL *fileURL = [NSURL fileURLWithPath:path];
        [[NSWorkspace sharedWorkspace] openURL:fileURL];
    } else {
        [[NSAlert alertWithMessageText:@"Path not found." defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@""] runModal];
    }
}

- (void)vagrantOpenInTerminalMenuItemClicked:(NSMenuItem*)menuItem {
    NSString *path = nil;
    if([menuItem.parentItem.representedObject isKindOfClass:[VirtualMachineInfo class]]) {
        VirtualMachineInfo *machine = [menuItem parentItem].representedObject;
        path = [machine getSharedFolderPathWithName:@"/vagrant"];
    } else if([menuItem.parentItem.representedObject isKindOfClass:[Bookmark class]]) {
        Bookmark *bookmark = menuItem.parentItem.representedObject;
        path = bookmark.path;
    }
    
    if(path) {
        [self runTerminalCommand:[NSString stringWithFormat:@"cd %@", [Util escapeShellArg:path]]];
    } else {
        [[NSAlert alertWithMessageText:@"Path not found." defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@""] runModal];
    }
}

- (void)addBookmarkMenuItemClicked:(NSMenuItem*)menuItem {
    VirtualMachineInfo *machine = [menuItem parentItem].representedObject;
    
    [self addBookmarkForVirtualMachine:machine];
    [self rebuildMenu];
}

- (void)removeBookmarkMenuItemClicked:(NSMenuItem*)menuItem {
    
    if([menuItem.parentItem.representedObject isKindOfClass:[VirtualMachineInfo class]]) {
        VirtualMachineInfo *machine = menuItem.parentItem.representedObject;
        
        if(machine.bookmark) {
            [self removeBookmark:machine.bookmark];
            [self rebuildMenu];
        }
    } else if([menuItem.parentItem.representedObject isKindOfClass:[Bookmark class]]) {
        Bookmark *bookmark = menuItem.parentItem.representedObject;
        
        [self removeBookmark:bookmark];
        [self rebuildMenu];
    }
}

#pragma mark - General Functions

- (VirtualMachineInfo*)getMachineFromObject:(id)obj {
    if([obj isKindOfClass:[VirtualMachineInfo class]]) {
        return obj;
    } else if([obj isKindOfClass:[Bookmark class]]) {
        return [self getVirtualMachineForBookmark:obj];
    }
    
    return nil;
}

- (void)removeOutputWindow:(TaskOutputWindow*)outputWindow {
    [taskOutputWindows removeObject:outputWindow];
}

- (void)removeInfoWindow:(VirtualMachineInfoWindow*)infoWindow {
    [infoWindows removeObject:infoWindow];
}

#pragma mark - Virtual Machines

- (VirtualMachineInfo*)getVirtualMachineForBookmark:(Bookmark*)bookmark {
    for(VirtualMachineInfo *machine in detectedVagrantMachines) {
        if(machine.bookmark == bookmark) {
            return machine;
        }
    }
    
    return nil;
}

- (VirtualMachineInfo*)getVirtualMachineInfo:(NSString*)uuid {
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/sh"];
    [task setArguments:@[@"-c", [NSString stringWithFormat:@"vboxmanage showvminfo %@ --machinereadable", uuid]]];
    
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardInput:[NSPipe pipe]];
    [task setStandardOutput:pipe];
    
    [task launch];
    [task waitUntilExit];
    
    NSData *outputData = [[pipe fileHandleForReading] readDataToEndOfFile];
    NSString *outputString = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
    
    if(task.terminationStatus != 0) {
        return nil;
    }
    
    VirtualMachineInfo *vmInfo = [VirtualMachineInfo fromInfo:outputString];
    
    return vmInfo;
}

- (NSArray*)getAllVirtualMachinesInfo {
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/sh"];
    [task setArguments:@[@"-c", @"vboxmanage list vms | awk '{ print $NF }' | sed -e 's/[{}]//g'"]];
    
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardInput:[NSPipe pipe]];
    [task setStandardOutput:pipe];
    
    [task launch];
    [task waitUntilExit];
    
    NSData *outputData = [[pipe fileHandleForReading] readDataToEndOfFile];
    NSString *outputString = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
    
    NSMutableArray *vmUuids = [[outputString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] mutableCopy];
    [vmUuids removeObject:@""];
    
    NSMutableArray *virtualMachines = [[NSMutableArray alloc] init];
    
    for(NSString *uuid in vmUuids) {
        VirtualMachineInfo *vmInfo = [self getVirtualMachineInfo:uuid];
        if(vmInfo) {
            [virtualMachines addObject:vmInfo];
        }
    }
    
    return [NSArray arrayWithArray:virtualMachines];
}

- (void)updateVirtualMachineState:(VirtualMachineInfo*)machine {
    VirtualMachineInfo *info = [self getVirtualMachineInfo:machine.uuid];
    
    if(!info) {
        [self detectVagrantMachines];
    } else {
        machine.state = info.state;
        [self rebuildMenu];
    }
}

- (int)getRunningVmCount {
    int runningCount = 0;
    for(VirtualMachineInfo *machine in detectedVagrantMachines) {
        if(machine.isRunning) {
            ++runningCount;
        }
    }
    
    return runningCount;
}

- (NSMutableArray*)sortVirtualMachines:(NSArray*)virtualMachines {
    //sort alphabetically with running machines at the top
    return [[virtualMachines sortedArrayUsingComparator:^(id obj1, id obj2) {
        if ([obj1 isKindOfClass:[VirtualMachineInfo class]] && [obj2 isKindOfClass:[VirtualMachineInfo class]]) {
            VirtualMachineInfo *m1 = obj1;
            VirtualMachineInfo *m2 = obj2;
            
            if ([m1 isRunning] && ![m2 isRunning]) {
                return (NSComparisonResult)NSOrderedAscending;
            } else if (m2.isRunning && !m1.isRunning) {
                return (NSComparisonResult)NSOrderedDescending;
            }
            
            return [m1.name caseInsensitiveCompare:m2.name];
        }
        
        return NSOrderedSame;
    }] mutableCopy];
}

- (void)detectVagrantMachines {
    [self removeDetectedMenuItems];
    
    NSMenuItem *i = [[NSMenuItem alloc] init];
    [i setTitle:@"Refreshing..."];
    [i setEnabled:NO];
    [i setTag:MenuItemDetected];
    [statusMenu insertItem:i atIndex:[statusMenu indexOfItem:refreshDetectedMenuItem]];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //detect all VMs
        NSArray *virtualMachines = [self getAllVirtualMachinesInfo];
        
        //filter only vagrant machines
        NSMutableArray *vagrantMachines = [[NSMutableArray alloc] init];
        for(VirtualMachineInfo *vmInfo in virtualMachines) {
            if([vmInfo getSharedFolderPathWithName:@"/vagrant"]) {
                vmInfo.bookmark = [self getBookmarkByPath:[vmInfo getSharedFolderPathWithName:@"/vagrant"]];
                [vagrantMachines addObject:vmInfo];
            }
        }
        
        vagrantMachines = [self sortVirtualMachines:vagrantMachines];
        
        @synchronized(detectedVagrantMachines) {
            detectedVagrantMachines = vagrantMachines;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self rebuildMenu];
        });
    });
}

@end
