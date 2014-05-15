//
//  AppDelegate.m
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import "AppDelegate.h"
#import "Environment.h"
#import "VersionComparison.h"

#define MENU_ITEM_VAGRANT_SSH 7
#define MENU_ITEM_VAGRANT_UP 1
#define MENU_ITEM_VAGRANT_RELOAD 10
#define MENU_ITEM_VAGRANT_HALT 2
#define MENU_ITEM_VAGRANT_SUSPEND 11
#define MENU_ITEM_VAGRANT_PROVISION 12
#define MENU_ITEM_VAGRANT_DESTROY 3
#define MENU_ITEM_OPEN_IN_FINDER 8
#define MENU_ITEM_OPEN_IN_TERMINAL 9
#define MENU_ITEM_DETAILS 4
#define MENU_ITEM_ADD_BOOKMARK 5
#define MENU_ITEM_REMOVE_BOOKMARK 6

@implementation AppDelegate

#pragma mark - Application events

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    //initialize data
    taskOutputWindows = [[NSMutableArray alloc] init];
    infoWindows = [[NSMutableArray alloc] init];
    detectedVagrantMachines = [[NSMutableArray alloc] init];
    bookmarks = [self getSavedBookmarks];

    //initialize service providers
    serviceProviders = [[NSMutableDictionary alloc] init];
    [serviceProviders setObject:[[VirtualBoxServiceProvider alloc] init] forKey:@"VirtualBoxServiceProvider"];

    for(Bookmark *bookmark in bookmarks) {
        [bookmark loadId];
    }

    //create status bar menu item
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setImage:[self getThemedImage:@"vagrant_logo_off"]];
    [statusItem setAlternateImage:[self getThemedImage:@"vagrant_logo_highlighted"]];
    [statusItem setMenu:statusMenu];
    [statusItem setHighlightMode:YES];

    [statusMenu setDelegate:self];

    [self rebuildMenu:NO];
    [self detectVagrantMachines];

    [[SUUpdater sharedUpdater] setDelegate:self];
    [[SUUpdater sharedUpdater] setSendsSystemProfile:[Util shouldSendProfileData]];
    [[SUUpdater sharedUpdater] checkForUpdateInformation];
}

- (id<SUVersionComparison>)versionComparatorForUpdater:(SUUpdater *)updater {
    return [[VersionComparison alloc] init];
}

- (SUAppcastItem *)bestValidUpdateInAppcast:(SUAppcast *)appcast forUpdater:(SUUpdater *)bundle {
    SUAppcastItem *bestItem = nil;

    NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];

    for(SUAppcastItem *item in [appcast items]) {
        if([Util compareVersion:appVersion toVersion:item.versionString] == NSOrderedAscending) {
            if([Util getUpdateStabilityScore:[Util getVersionStability:item.versionString]] <= [Util getUpdateStabilityScore:[Util getUpdateStability]]) {
                if(!bestItem || [Util compareVersion:bestItem.versionString toVersion:item.versionString] == NSOrderedAscending) {
                    bestItem = item;
                }
            }
        }
    }

    return bestItem;
}

- (void)menuWillOpen:(NSMenu *)menu {
    if(menu == statusMenu) {
        @synchronized(detectedVagrantMachines) {
            detectedVagrantMachines = [self sortVirtualMachines:detectedVagrantMachines];
        }
        [self rebuildMenu:NO];
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
            [bookmark loadId];

            if(bookmark.displayName && bookmark.path) {
                [bookmarksArray addObject:bookmark];
            }
        }
    }

    return bookmarksArray;
}

- (void)saveBookmarks:(NSMutableArray*)bm {
    if(!bm) {
        bm = bookmarks;
    }

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
    bookmark.uuid = machine.uuid;
    bookmark.machine = machine;
    [bookmarks addObject:bookmark];

    [self saveBookmarks:bookmarks];
}

- (void)addBookmarkWithPath:(NSString*)path withDisplayName:(NSString*)displayName {
    for(Bookmark *b in bookmarks) {
        if([b.path isEqualToString:path]) {
            return;
        }
    }

    Bookmark *bookmark = [[Bookmark alloc] init];
    bookmark.displayName = displayName;
    bookmark.path = path;
    [bookmark loadId];
    [bookmarks addObject:bookmark];

    [self saveBookmarks:bookmarks];
}

- (void)removeBookmark:(Bookmark*)bookmark {
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

- (Bookmark*)getBookmarkById:(NSString*)uuid {
    for(Bookmark *bookmark in bookmarks) {
        if([bookmark.uuid isEqualToString:uuid]) {
            return bookmark;
        }
    }

    return nil;
}

- (Bookmark*)getBookmarkForMachine:(VirtualMachineInfo*)machine {
    for(Bookmark *bookmark in bookmarks) {
        if(bookmark.machine == machine) {
            return bookmark;
        }
    }

    return nil;
}

- (void)updateBookmarkState:(Bookmark*)bookmark {
    if(bookmark.machine) {
        [self updateVirtualMachineState:bookmark.machine];
    } else {
        [self detectVagrantMachines];
    }
}


#pragma mark - Vagrant machine control
- (void)runTerminalCommand:(NSString*)command {
    NSString *terminalName = [[NSUserDefaults standardUserDefaults] valueForKey:@"terminalPreference"];

    NSString *s;
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

- (void)runVagrantAction:(NSString*)action withObjectArray:(NSArray*)objects {
    for (id obj in objects) {
        [self runVagrantAction:action withObject:obj];
    }
}

- (void)runVagrantAction:(NSString*)action withObject:(id)obj {
    NSString *command;

    if ([action isEqualToString:@"ssh"]) {
        command = @"vagrant ssh";
    } else if([action isEqualToString:@"up"]) {
        command = @"vagrant up";
    } else if([action isEqualToString:@"reload"]) {
        command = @"vagrant reload";
    } else if([action isEqualToString:@"suspend"]) {
        command = @"vagrant suspend";
    } else if([action isEqualToString:@"halt"]) {
        command = @"vagrant halt";
    } else if([action isEqualToString:@"provision"]) {
        command = @"vagrant provision";
    } else if([action isEqualToString:@"destroy"]) {
        command = @"vagrant destroy -f";
    } else {
        return;
    }

    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/bash"];

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

- (void)updateCheckUpdatesIcon:(BOOL)available {
    if (checkForUpdatesMenuItem && available) {
        checkForUpdatesMenuItem.title = @"Update Available";
        [checkForUpdatesMenuItem setImage:[NSImage imageNamed:@"problem"]];
    } else {
        checkForUpdatesMenuItem.title = @"Check For Updates";
        [checkForUpdatesMenuItem setImage:nil];
    }
}

- (NSMenu*)initializeSubmenuForAllMachines: (NSMenu*)submenu {

    [submenu removeItem:[submenu itemWithTag:MENU_ITEM_VAGRANT_SSH]];

    NSMenuItem *vagrantUp = [submenu itemWithTag:MENU_ITEM_VAGRANT_UP];
    [vagrantUp setAction:@selector(upAllMenuItemClicked:)];

    NSMenuItem *vagrantReload = [submenu itemWithTag:MENU_ITEM_VAGRANT_RELOAD];
    [vagrantReload setAction:@selector(reloadAllMenuItemClicked:)];

    NSMenuItem *vagrantSuspend = [submenu itemWithTag:MENU_ITEM_VAGRANT_SUSPEND];
    [vagrantSuspend setAction:@selector(suspendAllMenuItemClicked:)];

    NSMenuItem *vagrantHalt = [submenu itemWithTag:MENU_ITEM_VAGRANT_HALT];
    [vagrantHalt setAction:@selector(haltAllMenuItemClicked:)];

    NSMenuItem *vagrantProvision = [submenu itemWithTag:MENU_ITEM_VAGRANT_PROVISION];
    [vagrantProvision setAction:@selector(provisionAllMenuItemClicked:)];

    NSMenuItem *vagrantDestroy = [submenu itemWithTag:MENU_ITEM_VAGRANT_DESTROY];
    [vagrantDestroy setAction:@selector(destroyAllMenuItemClicked:)];

    [submenu removeItem:[submenu itemWithTag:MENU_ITEM_OPEN_IN_FINDER]];
    [submenu removeItem:[submenu itemWithTag:MENU_ITEM_OPEN_IN_TERMINAL]];
    [submenu removeItem:[submenu itemWithTag:MENU_ITEM_ADD_BOOKMARK]];
    [submenu removeItem:[submenu itemWithTag:MENU_ITEM_REMOVE_BOOKMARK]];
    [submenu removeItem:[submenu itemWithTag:MENU_ITEM_DETAILS]];

    [submenu removeItemAtIndex:submenu.numberOfItems-1];

    return submenu;
}

- (NSMenu*)initializeSubmenuForMachine:(NSMenu*)submenu :(VirtualMachineInfo*)machine :(BOOL)pathExists :(BOOL)isBookmarkedMachine {
    if(machine.isRunning) {
        NSMenuItem *vagrantSsh = [submenu itemWithTag:MENU_ITEM_VAGRANT_SSH];
        [vagrantSsh setAction:@selector(vagrantSshMenuItemClicked:)];

        NSMenuItem *vagrantUp = [submenu itemWithTag:MENU_ITEM_VAGRANT_UP];
        [vagrantUp setEnabled:NO];

        NSMenuItem *vagrantReload = [submenu itemWithTag:MENU_ITEM_VAGRANT_RELOAD];
        [vagrantReload setAction:@selector(vagrantReloadMenuItemClicked:)];

        NSMenuItem *vagrantSuspend = [submenu itemWithTag:MENU_ITEM_VAGRANT_SUSPEND];
        [vagrantSuspend setAction:@selector(vagrantSuspendMenuItemClicked:)];

        NSMenuItem *vagrantHalt = [submenu itemWithTag:MENU_ITEM_VAGRANT_HALT];
        [vagrantHalt setAction:@selector(vagrantHaltMenuItemClicked:)];

        NSMenuItem *vagrantProvision = [submenu itemWithTag:MENU_ITEM_VAGRANT_PROVISION];
        [vagrantProvision setAction:@selector(vagrantProvisionMenuItemClicked:)];
    } else {
        NSMenuItem *vagrantSsh = [submenu itemWithTag:MENU_ITEM_VAGRANT_SSH];
        [vagrantSsh setEnabled:NO];

        NSMenuItem *vagrantUp = [submenu itemWithTag:MENU_ITEM_VAGRANT_UP];
        [vagrantUp setAction:@selector(vagrantUpMenuItemClicked:)];

        NSMenuItem *vagrantReload = [submenu itemWithTag:MENU_ITEM_VAGRANT_RELOAD];
        [vagrantReload setEnabled:NO];

        NSMenuItem *vagrantSuspend = [submenu itemWithTag:MENU_ITEM_VAGRANT_SUSPEND];
        [vagrantSuspend setEnabled:NO];

        NSMenuItem *vagrantHalt = [submenu itemWithTag:MENU_ITEM_VAGRANT_HALT];
        [vagrantHalt setEnabled:NO];

        NSMenuItem *vagrantProvision = [submenu itemWithTag:MENU_ITEM_VAGRANT_PROVISION];
        [vagrantProvision setEnabled:NO];
    }

    NSMenuItem *vagrantDestroy = [submenu itemWithTag:MENU_ITEM_VAGRANT_DESTROY];
    if(!machine) {
        [vagrantDestroy setEnabled:NO];
    } else {
        [vagrantDestroy setAction:@selector(vagrantDestroyMenuItemClicked:)];
    }

    NSMenuItem *virtualMachineDetails = [submenu itemWithTag:MENU_ITEM_DETAILS];
    [virtualMachineDetails setAction:@selector(virtualMachineDetailsMenuItemClicked:)];

    NSMenuItem *openInFinder = [submenu itemWithTag:MENU_ITEM_OPEN_IN_FINDER];
    NSMenuItem *openInTerminal = [submenu itemWithTag:MENU_ITEM_OPEN_IN_TERMINAL];

    if (pathExists) {
        [openInFinder setAction:@selector(vagrantOpenInFinderMenuItemClicked:)];
        [openInTerminal setAction:@selector(vagrantOpenInTerminalMenuItemClicked:)];
    } else {
        [openInFinder setEnabled:NO];
        [openInTerminal setEnabled:NO];
    }

    if (isBookmarkedMachine) {
        NSMenuItem *addBookmark = [submenu itemWithTag:MENU_ITEM_ADD_BOOKMARK];
        [addBookmark setHidden:YES];

        NSMenuItem *removeBookmark = [submenu itemWithTag:MENU_ITEM_REMOVE_BOOKMARK];
        [removeBookmark setAction:@selector(removeBookmarkMenuItemClicked:)];
    } else {
        NSMenuItem *addBookmark = [submenu itemWithTag:MENU_ITEM_ADD_BOOKMARK];
        [addBookmark setAction:@selector(addBookmarkMenuItemClicked:)];

        NSMenuItem *removeBookmark = [submenu itemWithTag:MENU_ITEM_REMOVE_BOOKMARK];
        [removeBookmark setHidden:YES];
    }

    return submenu;
}

- (void)rebuildMenu:(BOOL)closeMenu {

    if(closeMenu) {
        [statusMenu cancelTracking];
    }

    [statusMenu removeAllItems];

    @synchronized(detectedVagrantMachines) {
        //add refresh button
        if(!refreshDetectedMenuItem) {
            refreshDetectedMenuItem = [[NSMenuItem alloc] init];
            [refreshDetectedMenuItem setTitle:@"Refresh List"];
            [refreshDetectedMenuItem setAction:@selector(refreshDetectedMenuItemClicked:)];
        }
        [statusMenu addItem:refreshDetectedMenuItem];

        [statusMenu addItem:[NSMenuItem separatorItem]];

        //add bookmarks
        if (bookmarks.count != 0) {
            for(Bookmark *bookmark in bookmarks) {
                VirtualMachineInfo *machine = bookmark.machine;
                NSMenuItem *i = [[NSMenuItem alloc] init];
                [i setTitle:bookmark.displayName];

                BOOL pathExists = [[NSFileManager defaultManager] fileExistsAtPath:bookmark.path];
                BOOL vagrantFileExists = [[NSFileManager defaultManager] fileExistsAtPath:[NSString pathWithComponents:@[bookmark.path, @"Vagrantfile"]]];

                if (!vagrantFileExists) {
                    [i setToolTip:[NSString stringWithFormat:@"Vagrantfile does not exist at %@", bookmark.path]];
                }

                [i setEnabled:YES];
                [i setImage:[NSImage imageNamed:vagrantFileExists?([machine isSuspended]?@"suspended":([machine isRunning]?@"on":@"off")):@"problem"]];
                [i setTag:MenuItemDetected];
                [i setRepresentedObject:bookmark];

                [statusMenu addItem:i];

                if (vagrantFileExists) {
                    [statusMenu setSubmenu:[self initializeSubmenuForMachine:[statusSubMenuTemplate copy] :machine :pathExists :YES] forItem:i];
                }
            }
        }

        if(!addBookmarkMenuItem) {
            addBookmarkMenuItem = [[NSMenuItem alloc] init];
            addBookmarkMenuItem.title = @"Add Bookmark";
            [addBookmarkMenuItem setAction:@selector(addCustomBookmarkMenuItemClicked:)];
        }
        [statusMenu addItem:addBookmarkMenuItem];

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
            if([self getBookmarkForMachine:machine]) {
                continue;
            }

            NSMenuItem *i = [[NSMenuItem alloc] init];
            [i setTitle:machine.name];

            BOOL pathExists = [[NSFileManager defaultManager] fileExistsAtPath:[machine getSharedFolderPathWithName:@"/vagrant"]];
            BOOL vagrantFileExists = [[NSFileManager defaultManager] fileExistsAtPath:[NSString pathWithComponents:@[[machine getSharedFolderPathWithName:@"/vagrant"], @"Vagrantfile"]]];

            if (!vagrantFileExists) {
                [i setToolTip:[NSString stringWithFormat:@"Vagrantfile does not exist at %@", [machine getSharedFolderPathWithName:@"/vagrant"]]];
            }

            [i setEnabled:YES];
            [i setImage:[NSImage imageNamed:vagrantFileExists?([machine isSuspended]?@"suspended":([machine isRunning]?@"on":@"off")):@"problem"]];
            [i setTag:MenuItemDetected];
            [i setRepresentedObject:machine];

            [statusMenu addItem:i];

            if (vagrantFileExists) {
                [statusMenu setSubmenu:[self initializeSubmenuForMachine:[statusSubMenuTemplate copy] :machine :pathExists :NO] forItem:i];
            }
        }
    }

    if(!detectedSeparatorMenuItem) {
        detectedSeparatorMenuItem = [NSMenuItem separatorItem];
    }

    [statusMenu addItem:detectedSeparatorMenuItem];

    NSMenu *allMachinesSubMenu = [self initializeSubmenuForAllMachines:[statusSubMenuTemplate copy]];
    if(!allMachinesMenuItem) {
        allMachinesMenuItem = [[NSMenuItem alloc] init];
        [allMachinesMenuItem setTitle:@"All Machines"];
        [allMachinesMenuItem setSubmenu:allMachinesSubMenu];
    }
    [statusMenu addItem:allMachinesMenuItem];

    if(!globalCommandsSeparatorMenuItem) {
        globalCommandsSeparatorMenuItem = [NSMenuItem separatorItem];
    }
    [statusMenu addItem:globalCommandsSeparatorMenuItem];

    //add static items
    if(!windowMenuItem) {
        windowMenuItem = [[NSMenuItem alloc] init];
        [windowMenuItem setTitle:@"Windows"];
        [statusMenu setSubmenu:self.windowMenu forItem:windowMenuItem];
    }
    [statusMenu addItem:windowMenuItem];

    if(!preferencesMenuItem) {
        preferencesMenuItem = [[NSMenuItem alloc] init];
        [preferencesMenuItem setTitle:@"Preferences"];
        [preferencesMenuItem setAction:@selector(preferencesMenuItemClicked:)];
    }
    [statusMenu addItem:preferencesMenuItem];

    if(!aboutMenuItem) {
        aboutMenuItem = [[NSMenuItem alloc] init];
        [aboutMenuItem setTitle:@"About"];
        [aboutMenuItem setAction:@selector(aboutMenuItemClicked:)];
    }
    [statusMenu addItem:aboutMenuItem];

    if(!checkForUpdatesMenuItem) {
        checkForUpdatesMenuItem = [[NSMenuItem alloc] init];
        [checkForUpdatesMenuItem setTitle:@"Check For Updates"];
        [checkForUpdatesMenuItem setAction:@selector(checkForUpdatesMenuItemClicked:)];
    }
    [statusMenu addItem:checkForUpdatesMenuItem];

    if(!quitMenuItem) {
        quitMenuItem = [[NSMenuItem alloc] init];
        [quitMenuItem setTitle:@"Quit"];
        [quitMenuItem setAction:@selector(terminate:)];
    }
    [statusMenu addItem:quitMenuItem];

    int runningCount = [self getRunningVmCount];
    if(runningCount > 0 ) {
        [statusItem setTitle:[NSString stringWithFormat:@"%d", runningCount]];
        [statusItem setImage:[self getThemedImage:@"vagrant_logo_on"]];
    } else {
        [statusItem setTitle:@""];
        [statusItem setImage:[self getThemedImage:@"vagrant_logo_off"]];
    }
    [statusItem setAlternateImage:[self getThemedImage:@"vagrant_logo_highlighted"]];
}

- (NSImage*)getThemedImage:(NSString*)imageName {
    return [NSImage imageNamed:[NSString stringWithFormat:@"%@-%@", imageName, [self getCurrentTheme]]];
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

- (IBAction)checkForUpdatesMenuItemClicked:(id)sender {
    [[SUUpdater sharedUpdater] checkForUpdates:sender];
}

- (IBAction)aboutMenuItemClicked:(id)sender {
    aboutWindow = [[AboutWindow alloc] initWithWindowNibName:@"AboutWindow"];
    [NSApp activateIgnoringOtherApps:YES];
    [aboutWindow showWindow:self];
}

- (IBAction)preferencesMenuItemClicked:(id)sender {
    preferencesWindow = [[PreferencesWindow alloc] initWithWindowNibName:@"PreferencesWindow"];
    [NSApp activateIgnoringOtherApps:YES];
    [preferencesWindow showWindow:self];
}

- (void)vagrantSshMenuItemClicked:(NSMenuItem*)menuItem {
    VirtualMachineInfo* machine = [self getMachineFromObject:menuItem.parentItem.representedObject];
    if(machine) {
        NSString *action = [NSString stringWithFormat:@"cd %@ && vagrant ssh", [Util escapeShellArg:[machine getSharedFolderPathWithName:@"/vagrant"]]];
        [self runTerminalCommand:action];
    }
}

- (void)sshAllMenuItemClicked:(NSMenuItem*)menuItem {
    [self runVagrantAction:@"ssh" withObjectArray:[self getAllBookmarksAndMachines:running]];
}

- (void)upAllMenuItemClicked:(NSMenuItem*)menuItem {
    [self runVagrantAction:@"up" withObjectArray:[self getAllBookmarksAndMachines:suspended]];
    [self runVagrantAction:@"up" withObjectArray:[self getAllBookmarksAndMachines:off]];
}

- (void)haltAllMenuItemClicked:(NSMenuItem*)menuItem {
    [self runVagrantAction:@"halt" withObjectArray:[self getAllBookmarksAndMachines:running]];
}

- (void)reloadAllMenuItemClicked:(NSMenuItem*)menuItem {
    [self runVagrantAction:@"reload" withObjectArray:[self getAllBookmarksAndMachines:running]];
}

- (void)suspendAllMenuItemClicked:(NSMenuItem*)menuItem {
    [self runVagrantAction:@"suspend" withObjectArray:[self getAllBookmarksAndMachines:running]];
}

- (void)provisionAllMenuItemClicked:(NSMenuItem*)menuItem {
    [self runVagrantAction:@"provision" withObjectArray:[self getAllBookmarksAndMachines:running]];
}

- (void)destroyAllMenuItemClicked:(NSMenuItem*)menuItem {
    NSAlert *confirmAlert = [NSAlert alertWithMessageText:@"Are you sure you want to destroy all of your vagrant machines?" defaultButton:@"Confirm" alternateButton:@"Cancel" otherButton:nil informativeTextWithFormat:@""];
    NSInteger button = [confirmAlert runModal];

    if(button == NSAlertDefaultReturn) {
        [self runVagrantAction:@"destroy" withObjectArray:[self getAllBookmarksAndMachines]];
    }
}

- (void)vagrantUpMenuItemClicked:(NSMenuItem*)menuItem {
    [self runVagrantAction:@"up" withObject:menuItem.parentItem.representedObject];
}

- (void)vagrantReloadMenuItemClicked:(NSMenuItem*)menuItem {
    [self runVagrantAction:@"reload" withObject:menuItem.parentItem.representedObject];
}

- (void)vagrantSuspendMenuItemClicked:(NSMenuItem*)menuItem {
    [self runVagrantAction:@"suspend" withObject:menuItem.parentItem.representedObject];
}

- (void)vagrantHaltMenuItemClicked:(NSMenuItem*)menuItem {
    [self runVagrantAction:@"halt" withObject:menuItem.parentItem.representedObject];
}

- (void)vagrantProvisionMenuItemClicked:(NSMenuItem*)menuItem {
    [self runVagrantAction:@"provision" withObject:menuItem.parentItem.representedObject];
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

    VirtualMachineInfoWindow *infoWindow = [[VirtualMachineInfoWindow alloc] initWithWindowNibName:@"VirtualMachineInfoWindow"];
    infoWindow.machine = machine;
    if([menuItem.parentItem.representedObject isKindOfClass:[Bookmark class]]) {
        infoWindow.bookmark = (Bookmark*)menuItem.parentItem.representedObject;
    }
    [NSApp activateIgnoringOtherApps:YES];
    [infoWindow showWindow:self];

    [infoWindows addObject:infoWindow];
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
    [self rebuildMenu:YES];
}

- (void)removeBookmarkMenuItemClicked:(NSMenuItem*)menuItem {
    if([menuItem.parentItem.representedObject isKindOfClass:[VirtualMachineInfo class]]) {
        VirtualMachineInfo *machine = menuItem.parentItem.representedObject;

        Bookmark *bookmark = [self getBookmarkForMachine:machine];

        if(bookmark) {
            [self removeBookmark:bookmark];
            [self rebuildMenu:YES];
        }
    } else if([menuItem.parentItem.representedObject isKindOfClass:[Bookmark class]]) {
        Bookmark *bookmark = menuItem.parentItem.representedObject;

        [self removeBookmark:bookmark];
        if(bookmark.machine && ![detectedVagrantMachines containsObject:bookmark.machine]) {
            [detectedVagrantMachines addObject:bookmark.machine];
        }
        [self rebuildMenu:YES];
    }
}

- (void)addCustomBookmarkMenuItemClicked:(NSMenuItem*)menuItem {
    addBookmarkWindow = [[AddBookmarkWindow alloc] initWithWindowNibName:@"AddBookmarkWindow"];
    [NSApp activateIgnoringOtherApps:YES];
    [addBookmarkWindow showWindow:self];
}

#pragma mark - General Functions

- (NSArray*)getAllBookmarksAndMachines {
    NSMutableArray *machines = [[NSMutableArray alloc] init];
    [machines addObjectsFromArray:bookmarks];
    [machines addObjectsFromArray:detectedVagrantMachines];
    return machines;
}

- (NSArray*)getAllBookmarksAndMachines :(PossibleVmStates)withState {
    NSMutableArray *machines = [[NSMutableArray alloc] init];
    for(Bookmark *bookmark in bookmarks) {
        if([bookmark.machine isState:withState]) {
            [machines addObject:bookmark];
        }
    }

    for(VirtualMachineInfo *vm in detectedVagrantMachines) {
        if([vm isState:withState]) {
            [machines addObject:vm];
        }
    }

    return machines;
}

- (NSMutableDictionary*)getServiceProviders {
    return serviceProviders;
}

- (VirtualMachineInfo*)getMachineFromObject:(id)obj {
    if([obj isKindOfClass:[VirtualMachineInfo class]]) {
        return obj;
    } else if([obj isKindOfClass:[Bookmark class]]) {
        return ((Bookmark*)obj).machine;
    }

    return nil;
}

- (void)removeOutputWindow:(TaskOutputWindow*)outputWindow {
    [taskOutputWindows removeObject:outputWindow];
}

- (void)removeInfoWindow:(VirtualMachineInfoWindow*)infoWindow {
    [infoWindows removeObject:infoWindow];
}

- (NSString*)getCurrentTheme {
    NSString *theme = [[NSUserDefaults standardUserDefaults] objectForKey:@"statusBarIconTheme"];

    if(!theme) {
        theme = @"clean";
        [[NSUserDefaults standardUserDefaults] setValue:theme forKey:@"statusBarIconTheme"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    return theme;
}

#pragma mark - Virtual Machines

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

- (void)updateVirtualMachineState:(VirtualMachineInfo*)machine {
    VirtualMachineInfo *info = [[machine getProvider] getVagrantMachineInfo:machine.uuid];

    if(!info) {
        for(Bookmark *bookmark in bookmarks) {
            if(bookmark.machine == machine) {
                bookmark.machine = nil;
                [bookmark loadId];
            }
        }

        [self detectVagrantMachines];
    } else {
        machine.state = info.state;

        for(Bookmark *bookmark in bookmarks) {
            if(bookmark.uuid == machine.uuid) {
                bookmark.machine = machine;
            }
        }

        [self rebuildMenu:YES];
    }
}

- (int)getRunningVmCount {
    int runningCount = 0;

    NSMutableArray *bookmarkUuids = [[NSMutableArray alloc] init];
    for(Bookmark *bookmark in bookmarks) {
        if(bookmark.machine && bookmark.machine.isRunning) {
            [bookmarkUuids addObject:bookmark.uuid];
            ++runningCount;
        }
    }

    for(VirtualMachineInfo *machine in detectedVagrantMachines) {
        if(machine.isRunning && ![bookmarkUuids containsObject:machine.uuid]) {
            ++runningCount;
        }
    }

    return runningCount;
}

- (void)detectVagrantMachines {
    [self removeDetectedMenuItems];

    for(Bookmark *bookmark in bookmarks) {
        [bookmark loadId];
    }

    NSMenuItem *i = [[NSMenuItem alloc] init];
    [i setTitle:@"Refreshing..."];
    [i setEnabled:NO];
    [i setTag:MenuItemDetected];
    [statusMenu insertItem:i atIndex:[statusMenu indexOfItem:refreshDetectedMenuItem]];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *vagrantMachines = [[NSMutableArray alloc] init];

        for (NSString *key in [serviceProviders allKeys]) {
            id<VirtualMachineServiceProvider> pr = [serviceProviders objectForKey:key];
            [vagrantMachines addObjectsFromArray:[pr getAllVagrantMachines]];
        }

        vagrantMachines = [self sortVirtualMachines:vagrantMachines];

        @synchronized(detectedVagrantMachines) {
            detectedVagrantMachines = [[NSMutableArray alloc] initWithArray:vagrantMachines];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [self rebuildMenu:YES];
        });
    });
}

#pragma mark - Sparkle updater delegates

- (NSArray*)feedParametersForUpdater:(SUUpdater *)updater sendingSystemProfile:(BOOL)sendingProfile {
    NSMutableArray *data = [[NSMutableArray alloc] init];
    [data addObject:@{@"key": @"machineid", @"value": [Util getMachineId]}];
    [data addObject:@{@"key": @"appversion", @"value": [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]}];
    if(sendingProfile) {
        [data addObject:@{@"key": @"profile", @"value": @"1"}];
    }

    return data;
}

- (void)updater:(SUUpdater *)updater didFindValidUpdate:(SUAppcastItem *)update {
    [self updateCheckUpdatesIcon:YES];
}

- (void)updaterDidNotFindUpdate:(SUUpdater *)update {
    [self updateCheckUpdatesIcon:NO];
}

@end
