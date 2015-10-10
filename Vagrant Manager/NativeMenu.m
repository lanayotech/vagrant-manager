//
//  NativeMenu.m
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import "NativeMenu.h"
#import "BookmarkManager.h"

@implementation NativeMenu {
    NSStatusItem *_statusItem;
    NSMenu *_menu;
    NSMenuItem *_refreshMenuItem;
    NSTimer *_refreshTimer;
    int _refreshIconFrame;
    
    NSMutableArray *_menuItems;
    
    NSMenuItem *_topMachineSeparator;
    NSMenuItem *_bottomMachineSeparator;

    NSMenuItem *_checkForUpdatesMenuItem;
    NSMenuItem *_checkForVagrantUpdatesMenuItem;
}

- (id)init {
    self = [super init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bookmarksUpdated:) name:@"vagrant-manager.bookmarks-updated" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationPreferenceChanged:) name:@"vagrant-manager.notification-preference-changed" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(instanceAdded:) name:@"vagrant-manager.instance-added" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(instanceRemoved:) name:@"vagrant-manager.instance-removed" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(instanceUpdated:) name:@"vagrant-manager.instance-updated" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setUpdateAvailable:) name:@"vagrant-manager.update-available" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setVagrantUpdateAvailable:) name:@"vagrant-manager.vagrant-update-available" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshingStarted:) name:@"vagrant-manager.refreshing-started" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshingEnded:) name:@"vagrant-manager.refreshing-ended" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRunningVmCount:) name:@"vagrant-manager.update-running-vm-count" object:nil];
    
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    _menu = [[NSMenu alloc] init];
    [_menu setAutoenablesItems:NO];
    
    _menuItems = [[NSMutableArray alloc] init];
    
    _statusItem.image = [[Util getApp] getThemedImage:@"vagrant_logo_off"];
    _statusItem.highlightMode = YES;
    _statusItem.menu = _menu;

    _refreshMenuItem = [[NSMenuItem alloc] initWithTitle:@"Refresh" action:@selector(refreshMenuItemClicked:) keyEquivalent:@""];
    _refreshMenuItem.target = self;
    [_menu addItem:_refreshMenuItem];
    
    _topMachineSeparator = [NSMenuItem separatorItem];
    
    // instances here
    
    _bottomMachineSeparator = [NSMenuItem separatorItem];
    [_menu addItem:_bottomMachineSeparator];
    
    NSMenu *allMachinesMenu = [[NSMenu alloc] init];
    [allMachinesMenu setAutoenablesItems:NO];
    
    NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:@"Up" action:@selector(allUpMenuItemClicked:) keyEquivalent:@""];
    menuItem.target = self;
    menuItem.image = [NSImage imageNamed:@"up"];
    [menuItem.image setTemplate:YES];
    [allMachinesMenu addItem:menuItem];
    
    menuItem = [[NSMenuItem alloc] initWithTitle:@"Reload" action:@selector(allReloadMenuItemClicked:) keyEquivalent:@""];
    menuItem.target = self;
    menuItem.image = [NSImage imageNamed:@"reload"];
    [menuItem.image setTemplate:YES];
    [allMachinesMenu addItem:menuItem];
    
    menuItem = [[NSMenuItem alloc] initWithTitle:@"Suspend" action:@selector(allSuspendMenuItemClicked:) keyEquivalent:@""];
    menuItem.target = self;
    menuItem.image = [NSImage imageNamed:@"suspend"];
    [menuItem.image setTemplate:YES];
    [allMachinesMenu addItem:menuItem];
    
    menuItem = [[NSMenuItem alloc] initWithTitle:@"Halt" action:@selector(allHaltMenuItemClicked:) keyEquivalent:@""];
    menuItem.target = self;
    menuItem.image = [NSImage imageNamed:@"halt"];
    [menuItem.image setTemplate:YES];
    [allMachinesMenu addItem:menuItem];
    
    menuItem = [[NSMenuItem alloc] initWithTitle:@"Provision" action:@selector(allProvisionMenuItemClicked:) keyEquivalent:@""];
    menuItem.target = self;
    menuItem.image = [NSImage imageNamed:@"provision"];
    [menuItem.image setTemplate:YES];
    [allMachinesMenu addItem:menuItem];
    
    menuItem = [[NSMenuItem alloc] initWithTitle:@"Destroy" action:@selector(allDestroyMenuItemClicked:) keyEquivalent:@""];
    menuItem.target = self;
    menuItem.image = [NSImage imageNamed:@"destroy"];
    [menuItem.image setTemplate:YES];
    [allMachinesMenu addItem:menuItem];
    
    NSMenuItem *allMachinesMenuItem = [[NSMenuItem alloc] initWithTitle:@"All Machines" action:nil keyEquivalent:@""];
    [allMachinesMenuItem setSubmenu:allMachinesMenu];
    
    [_menu addItem:allMachinesMenuItem];
    
    NSMenuItem *manageBookmarksMenuItem = [[NSMenuItem alloc] initWithTitle:@"Manage Bookmarks" action:@selector(manageBookmarksMenuItemClicked:) keyEquivalent:@""];
    manageBookmarksMenuItem.target = self;
    [_menu addItem:manageBookmarksMenuItem];
    
    NSMenuItem *manageCustomCommandsMenuItem = [[NSMenuItem alloc] initWithTitle:@"Manage Custom Commands" action:@selector(manageCustomCommandsMenuItemClicked:) keyEquivalent:@""];
    manageCustomCommandsMenuItem.target = self;
    [_menu addItem:manageCustomCommandsMenuItem];
    
    [_menu addItem:[NSMenuItem separatorItem]];

    NSMenuItem *extrasMenuItem = [[NSMenuItem alloc] initWithTitle:@"Extras" action:nil keyEquivalent:@""];
    [_menu addItem:extrasMenuItem];
    
    NSMenu *extrasMenu = [[NSMenu alloc] init];
    
    NSMenuItem *editHostsMenuItem = [[NSMenuItem alloc] initWithTitle:@"Edit hosts file" action:@selector(editHostsMenuItemClicked:) keyEquivalent:@""];
    editHostsMenuItem.target = self;
    [extrasMenu addItem:editHostsMenuItem];
    
    [extrasMenuItem setSubmenu:extrasMenu];

    NSMenuItem *preferencesMenuItem = [[NSMenuItem alloc] initWithTitle:@"Preferences" action:@selector(preferencesMenuItemClicked:) keyEquivalent:@""];
    preferencesMenuItem.target = self;
    [_menu addItem:preferencesMenuItem];
    
    NSMenuItem *aboutMenuItem = [[NSMenuItem alloc] initWithTitle:@"About" action:@selector(aboutMenuItemClicked:) keyEquivalent:@""];
    aboutMenuItem.target = self;
    [_menu addItem:aboutMenuItem];
    
    _checkForUpdatesMenuItem = [[NSMenuItem alloc] initWithTitle:@"Check For Updates" action:@selector(checkForUpdatesMenuItemClicked:) keyEquivalent:@""];
    _checkForUpdatesMenuItem.target = self;
    [_menu addItem:_checkForUpdatesMenuItem];
    
    _checkForVagrantUpdatesMenuItem = [[NSMenuItem alloc] initWithTitle:@"Check For Vagrant Updates" action:@selector(checkForVagrantUpdatesMenuItemClicked:) keyEquivalent:@""];
    _checkForVagrantUpdatesMenuItem.target = self;
    [_menu addItem:_checkForVagrantUpdatesMenuItem];

    NSMenuItem *quitMenuItem = [[NSMenuItem alloc] initWithTitle:@"Quit" action:@selector(quitMenuItemClicked:) keyEquivalent:@""];
    quitMenuItem.target = self;
    [_menu addItem:quitMenuItem];
    
    return self;
}

#pragma mark - Notification Handlers

- (void)bookmarksUpdated:(NSNotification*)notification {
    [self rebuildMenu];
}

- (void)notificationPreferenceChanged: (NSNotification*)notification {
    
}

- (void)instanceAdded: (NSNotification*)notification {
    NativeMenuItem *item = [[NativeMenuItem alloc] init];
    [_menuItems addObject:item];
    item.delegate = self;
    item.instance = [notification.userInfo objectForKey:@"instance"];
    item.menuItem = [[NSMenuItem alloc] initWithTitle:item.instance.displayName action:nil keyEquivalent:@""];
    [item refresh];
    [self rebuildMenu];
}

- (void)instanceRemoved: (NSNotification*)notification {
    NativeMenuItem *item = [self menuItemForInstance:[notification.userInfo objectForKey:@"instance"]];
    [_menuItems removeObject:item];
    [_menu removeItem:item.menuItem];
    [self rebuildMenu];
}

- (void)instanceUpdated: (NSNotification*)notification {
    NativeMenuItem *item = [self menuItemForInstance:[notification.userInfo objectForKey:@"old_instance"]];
    item.instance = [notification.userInfo objectForKey:@"new_instance"];
    [item refresh];
    [self rebuildMenu];
}

- (void)setUpdateAvailable: (NSNotification*)notification {
    [self setUpdatesAvailable:[[notification.userInfo objectForKey:@"is_update_available"] boolValue]];
}

- (void)setVagrantUpdateAvailable: (NSNotification*)notification {
    [self setVagrantUpdatesAvailable:[[notification.userInfo objectForKey:@"is_update_available"] boolValue]];
}

- (void)refreshingStarted: (NSNotification*)notification {
    [self setIsRefreshing:YES];
}

- (void)refreshingEnded: (NSNotification*)notification {
    [self setIsRefreshing:NO];
}

#pragma mark - Control

- (void)rebuildMenu {
    for (NativeMenuItem *item in _menuItems) {
        [item refresh];
    }
    
    BookmarkManager *bookmarkManager = [BookmarkManager sharedManager];
    NSArray *sortedArray;
    sortedArray = [_menuItems sortedArrayUsingComparator:^NSComparisonResult(NativeMenuItem *a, NativeMenuItem *b) {;
        
        VagrantInstance *firstInstance = a.instance;
        VagrantInstance *secondInstance = b.instance;
        
        BOOL firstIsBookmarked = [bookmarkManager getBookmarkWithPath:firstInstance.path] != nil;
        BOOL secondIsBookmarked = [bookmarkManager getBookmarkWithPath:secondInstance.path] != nil;
        
        int firstRunningCount = [firstInstance getRunningMachineCount];
        int secondRunningCount = [secondInstance getRunningMachineCount];
        
        if(firstIsBookmarked && !secondIsBookmarked) {
            return NSOrderedAscending;
        } else if(secondIsBookmarked && !firstIsBookmarked) {
            return NSOrderedDescending;
        } else {
            if(firstRunningCount > 0 && secondRunningCount == 0) {
                return NSOrderedAscending;
            } else if(secondRunningCount > 0 && firstRunningCount == 0) {
                return NSOrderedDescending;
            } else {
                int firstIdx = [bookmarkManager getIndexOfBookmarkWithPath:firstInstance.path];
                int secondIdx = [bookmarkManager getIndexOfBookmarkWithPath:secondInstance.path];
                
                if(firstIdx < secondIdx) {
                    return NSOrderedAscending;
                } else if(secondIdx < firstIdx) {
                    return NSOrderedDescending;
                } else {
                    return [firstInstance.displayName compare:secondInstance.displayName];
                }
            }
        }
    }];
    
    for (NativeMenuItem *item in sortedArray) {
        if ([_menu.itemArray containsObject:item.menuItem]) {
             [_menu removeItem:item.menuItem];
        }
        
        [_menu insertItem:item.menuItem atIndex:[_menu indexOfItem:_bottomMachineSeparator]];
    }
    
    _menuItems = [sortedArray mutableCopy];
    
    if ([_menu.itemArray containsObject:_topMachineSeparator]) {
        [_menu removeItem:_topMachineSeparator];
    }
    
    if (_menuItems.count > 0) {
        [_menu insertItem:_topMachineSeparator atIndex:[_menu indexOfItem:_refreshMenuItem]+1];
    }
}

- (void)setUpdatesAvailable:(BOOL)updatesAvailable {
    _checkForUpdatesMenuItem.image = updatesAvailable ? [NSImage imageNamed:@"status_icon_problem"] : nil;
}

- (void)setVagrantUpdatesAvailable:(BOOL)updatesAvailable {
    _checkForVagrantUpdatesMenuItem.image = updatesAvailable ? [NSImage imageNamed:@"status_icon_problem"] : nil;
}

- (void)setIsRefreshing:(BOOL)isRefreshing {
    [_refreshMenuItem setEnabled:!isRefreshing];
    _refreshMenuItem.title = isRefreshing ? @"Refreshing..." : @"Refresh";
    
    if(isRefreshing && ![[NSUserDefaults standardUserDefaults] boolForKey:@"dontAnimateStatusIcon"]) {
        _refreshIconFrame = 1;
        _refreshTimer = [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(updateRefreshIcon:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_refreshTimer forMode:NSEventTrackingRunLoopMode];
    } else {
        [_refreshTimer invalidate];
        _refreshTimer = nil;
    }
}

- (void)updateRefreshIcon:(id)sender {
    _statusItem.image = [[Util getApp] getThemedImage:[NSString stringWithFormat:@"vagrant_logo_refresh_%d", _refreshIconFrame]];
    if(++_refreshIconFrame > 5) {
        _refreshIconFrame = 1;
    }
}

#pragma mark - Native menu item delegate

- (void)nativeMenuItemUpAllMachines:(NativeMenuItem *)menuItem withProvision:(BOOL)provision {
    if(provision) {
        [self performAction:@"up-provision" withInstance:menuItem.instance];
    } else {
        [self performAction:@"up" withInstance:menuItem.instance];
    }
}

- (void)nativeMenuItemHaltAllMachines:(NativeMenuItem *)menuItem {
    [self performAction:@"halt" withInstance:menuItem.instance];
}

- (void)nativeMenuItemSSHInstance:(NativeMenuItem*)menuItem {
    [self performAction:@"ssh" withInstance:menuItem.instance];
}

- (void)nativeMenuItemRDPInstance:(NativeMenuItem*)menuItem {
    [self performAction:@"rdp" withInstance:menuItem.instance];
}

- (void)nativeMenuItemReloadAllMachines:(NativeMenuItem*)menuItem {
    [self performAction:@"reload" withInstance:menuItem.instance];
}

- (void)nativeMenuItemSuspendAllMachines:(NativeMenuItem*)menuItem {
    [self performAction:@"suspend" withInstance:menuItem.instance];
}

- (void)nativeMenuItemDestroyAllMachines:(NativeMenuItem *)menuItem {
    NSAlert *confirmAlert = [NSAlert alertWithMessageText:[NSString stringWithFormat:@"Are you sure you want to destroy %@?", menuItem.instance.machines.count > 1 ? @" all machines in the group" : @"this machine"] defaultButton:@"Confirm" alternateButton:@"Cancel" otherButton:nil informativeTextWithFormat:@""];
    NSInteger button = [confirmAlert runModal];
    
    if(button == NSAlertDefaultReturn) {
        [self performAction:@"destroy" withInstance:menuItem.instance];
    }
}

- (void)nativeMenuItemProvisionAllMachines:(NativeMenuItem*)menuItem {
    [self performAction:@"provision" withInstance:menuItem.instance];
}

- (void)nativeMenuItemCustomCommandAllMachines:(NativeMenuItem*)menuItem withCommand:(CustomCommand*)customCommand {
    [self performCustomCommand:customCommand withInstance:menuItem.instance];
}

- (void)nativeMenuItemOpenFinder:(NativeMenuItem*)menuItem {
    [self.delegate openInstanceInFinder:menuItem.instance];
}

- (void)nativeMenuItemOpenTerminal:(NativeMenuItem*)menuItem {
    [self.delegate openInstanceInTerminal:menuItem.instance];
}

- (void)nativeMenuItemEditVagrantfile:(NativeMenuItem *)menuItem {
    [self.delegate editVagrantfile:menuItem.instance];
}

- (void)nativeMenuItemUpdateProviderIdentifier:(NativeMenuItem*)menuItem withProviderIdentifier:(NSString*)providerIdentifier {
    VagrantInstance *instance = menuItem.instance;
    
    Bookmark *bookmark = [[BookmarkManager sharedManager] getBookmarkWithPath:instance.path];
    
    if(bookmark) {
        bookmark.providerIdentifier = providerIdentifier;
        [[BookmarkManager sharedManager] saveBookmarks];
    }
    
    instance.providerIdentifier = providerIdentifier;
    [menuItem refresh];
}

- (void)nativeMenuItemRemoveBookmark:(NativeMenuItem*)menuItem {
    [self.delegate removeBookmarkWithInstance:menuItem.instance];
}

- (void)nativeMenuItemAddBookmark:(NativeMenuItem*)menuItem {
    [self.delegate addBookmarkWithInstance:menuItem.instance];
}

- (void)nativeMenuItemUpMachine:(VagrantMachine *)machine withProvision:(BOOL)provision {
    if(provision) {
        [self performAction:@"up-provision" withMachine:machine];
    } else {
        [self performAction:@"up" withMachine:machine];
    }
}

- (void)nativeMenuItemHaltMachine:(VagrantMachine *)machine {
    [self performAction:@"halt" withMachine:machine];
}

- (void)nativeMenuItemSSHMachine:(VagrantMachine*)machine {
    [self performAction:@"ssh" withMachine:machine];
}

- (void)nativeMenuItemRDPMachine:(VagrantMachine*)machine {
    [self performAction:@"rdp" withMachine:machine];
}

- (void)nativeMenuItemReloadMachine:(VagrantMachine *)machine {
    [self performAction:@"reload" withMachine:machine];
}

- (void)nativeMenuItemSuspendMachine:(VagrantMachine *)machine {
    [self performAction:@"suspend" withMachine:machine];
}

- (void)nativeMenuItemDestroyMachine:(VagrantMachine *)machine {
    NSAlert *confirmAlert = [NSAlert alertWithMessageText:@"Are you sure you want to destroy this machine?" defaultButton:@"Confirm" alternateButton:@"Cancel" otherButton:nil informativeTextWithFormat:@""];
    NSInteger button = [confirmAlert runModal];
    
    if(button == NSAlertDefaultReturn) {
        [self performAction:@"destroy" withMachine:machine];
    }
}

- (void)nativeMenuItemProvisionMachine:(VagrantMachine *)machine {
    [self performAction:@"provision" withMachine:machine];
}

- (void)nativeMenuItemCustomCommandMachine:(VagrantMachine*)machine withCommand:(CustomCommand*)customCommand {
    [self performCustomCommand:customCommand withMachine:machine];
}

#pragma mark - Menu Item Click Handlers

- (void)refreshMenuItemClicked:(id)sender {
    [[Util getApp] refreshVagrantMachines];
}

- (void)manageBookmarksMenuItemClicked:(id)sender {
    if(manageBookmarksWindow && !manageBookmarksWindow.isClosed) {
        [NSApp activateIgnoringOtherApps:YES];
        [manageBookmarksWindow showWindow:self];
    } else {
        manageBookmarksWindow = [[ManageBookmarksWindow alloc] initWithWindowNibName:@"ManageBookmarksWindow"];
        [NSApp activateIgnoringOtherApps:YES];
        [manageBookmarksWindow showWindow:self];
        [[Util getApp] addOpenWindow:manageBookmarksWindow];
    }
}

- (void)manageCustomCommandsMenuItemClicked:(id)sender {
    if(manageCustomCommandsWindow && !manageCustomCommandsWindow.isClosed) {
        [NSApp activateIgnoringOtherApps:YES];
        [manageCustomCommandsWindow showWindow:self];
    } else {
        manageCustomCommandsWindow = [[ManageCustomCommandsWindow alloc] initWithWindowNibName:@"ManageCustomCommandsWindow"];
        [NSApp activateIgnoringOtherApps:YES];
        [manageCustomCommandsWindow showWindow:self];
        [[Util getApp] addOpenWindow:manageCustomCommandsWindow];
    }
}

- (void)editHostsMenuItemClicked:(id)sender {
    [self.delegate editHostsFile];
}

- (void)preferencesMenuItemClicked:(id)sender {
    if(preferencesWindow && !preferencesWindow.isClosed) {
        [NSApp activateIgnoringOtherApps:YES];
        [preferencesWindow showWindow:self];
    } else {
        preferencesWindow = [[PreferencesWindow alloc] initWithWindowNibName:@"PreferencesWindow"];
        [NSApp activateIgnoringOtherApps:YES];
        [preferencesWindow showWindow:self];
        [[Util getApp] addOpenWindow:preferencesWindow];
    }
}

- (void)quitMenuItemClicked:(id)sender {
    [[NSApplication sharedApplication] terminate:self];
}

- (void)aboutMenuItemClicked:(id)sender {
    if(aboutWindow && !aboutWindow.isClosed) {
        [NSApp activateIgnoringOtherApps:YES];
        [aboutWindow showWindow:self];
    } else {
        aboutWindow = [[AboutWindow alloc] initWithWindowNibName:@"AboutWindow"];
        [NSApp activateIgnoringOtherApps:YES];
        [aboutWindow showWindow:self];
        [[Util getApp] addOpenWindow:aboutWindow];
    }
}

- (void)checkForUpdatesMenuItemClicked:(id)sender {
    [[SUUpdater sharedUpdater] checkForUpdates:self];
}

- (void)checkForVagrantUpdatesMenuItemClicked:(id)sender {
    [self.delegate checkForVagrantUpdates:YES];
}

#pragma mark - All machines actions

- (IBAction)allUpMenuItemClicked:(NSMenuItem*)sender {
    NSArray *instances = [[VagrantManager sharedManager] instances];
    
    for(VagrantInstance *instance in instances) {
        for(VagrantMachine *machine in instance.machines) {
            if(machine.state != RunningState) {
                [self performAction:@"up" withMachine:machine];
            }
        }
    }
}

- (IBAction)allReloadMenuItemClicked:(NSMenuItem*)sender {
    NSArray *instances = [[VagrantManager sharedManager] instances];
    
    for(VagrantInstance *instance in instances) {
        for(VagrantMachine *machine in instance.machines) {
            if(machine.state == RunningState) {
                [self performAction:@"reload" withMachine:machine];
            }
        }
    }
}

- (IBAction)allSuspendMenuItemClicked:(NSMenuItem*)sender {
    NSArray *instances = [[VagrantManager sharedManager] instances];
    
    for(VagrantInstance *instance in instances) {
        for(VagrantMachine *machine in instance.machines) {
            if(machine.state == RunningState) {
                [self performAction:@"suspend" withMachine:machine];
            }
        }
    }
}

- (IBAction)allHaltMenuItemClicked:(NSMenuItem*)sender {
    NSArray *instances = [[VagrantManager sharedManager] instances];
    
    for(VagrantInstance *instance in instances) {
        for(VagrantMachine *machine in instance.machines) {
            if(machine.state == RunningState) {
                [self performAction:@"halt" withMachine:machine];
            }
        }
    }
}

- (IBAction)allProvisionMenuItemClicked:(NSMenuItem*)sender {
    NSArray *instances = [[VagrantManager sharedManager] instances];
    
    for(VagrantInstance *instance in instances) {
        for(VagrantMachine *machine in instance.machines) {
            [self performAction:@"provision" withMachine:machine];
        }
    }
}

- (IBAction)allDestroyMenuItemClicked:(NSMenuItem*)sender {
    NSAlert *confirmAlert = [NSAlert alertWithMessageText:@"Are you sure you want to destroy all machines?" defaultButton:@"Confirm" alternateButton:@"Cancel" otherButton:nil informativeTextWithFormat:@""];
    NSInteger button = [confirmAlert runModal];
    
    if(button == NSAlertDefaultReturn) {
        NSArray *instances = [[VagrantManager sharedManager] instances];
        for(VagrantInstance *instance in instances) {
            for(VagrantMachine *machine in instance.machines) {
                [self performAction:@"destroy" withMachine:machine];
            }
        }
    }
}

#pragma mark - Misc

- (void)performAction:(NSString*)action withInstance:(VagrantInstance*)instance {
    [self.delegate performVagrantAction:action withInstance:instance];
}

- (void)performAction:(NSString*)action withMachine:(VagrantMachine *)machine {
    [self.delegate performVagrantAction:action withMachine:machine];
}

- (void)performCustomCommand:(CustomCommand*)customCommand withInstance:(VagrantInstance*)instance {
    [self.delegate performCustomCommand:customCommand withInstance:instance];
}

- (void)performCustomCommand:(CustomCommand*)customCommand withMachine:(VagrantMachine *)machine {
    [self.delegate performCustomCommand:customCommand withMachine:machine];
}

- (void)updateRunningVmCount:(NSNotification*)notification {
    int count = [[notification.userInfo objectForKey:@"count"] intValue];
    
    if (count) {
        if(![[NSUserDefaults standardUserDefaults] boolForKey:@"dontShowRunningVmCount"]) {
            [_statusItem setTitle:[@(count) stringValue]];
        } else {
            [_statusItem setTitle:@""];
        }
        _statusItem.image = [[Util getApp] getThemedImage:@"vagrant_logo_on"];
    } else {
        [_statusItem setTitle:@""];
        _statusItem.image = [[Util getApp] getThemedImage:@"vagrant_logo_off"];
    }
}

- (NativeMenuItem*)menuItemForInstance:(VagrantInstance*)instance {
    for (NativeMenuItem *nativeMenuItem in _menuItems) {
        if (nativeMenuItem.instance == instance) {
            return nativeMenuItem;
        }
    }
    
    return nil;
}


@end
