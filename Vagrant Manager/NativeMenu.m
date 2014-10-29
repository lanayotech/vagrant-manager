//
//  NativeMenu.m
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import "NativeMenu.h"
#import "NativeMenuItem.h"

@implementation NativeMenu {
    NSStatusItem *_statusItem;
    NSMenu *_menu;
    NSMutableArray *_menuItems;
    NSMenuItem *_machineSeparator;
}

- (id)init {
    self = [super init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bookmarksUpdated:) name:@"vagrant-manager.bookmarks-updated" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationPreferenceChanged:) name:@"vagrant-manager.notification-preference-changed" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(instanceAdded:) name:@"vagrant-manager.instance-added" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(instanceRemoved:) name:@"vagrant-manager.instance-removed" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(instanceUpdated:) name:@"vagrant-manager.instance-updated" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setUpdateAvailable:) name:@"vagrant-manager.update-available" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshingStarted:) name:@"vagrant-manager.refreshing-started" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshingEnded:) name:@"vagrant-manager.refreshing-ended" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRunningVmCount:) name:@"vagrant-manager.update-running-vm-count" object:nil];
    
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    _menu = [[NSMenu alloc] init];
    _menuItems = [[NSMutableArray alloc] init];
    
    _statusItem.image = [[Util getApp] getThemedImage:@"vagrant_logo_off"];
    _statusItem.highlightMode = YES;
    _statusItem.menu = _menu;
    
    [_menu addItem:[[NSMenuItem alloc] initWithTitle:@"Refresh" action:nil keyEquivalent:@""]];
    
    _machineSeparator = [NSMenuItem separatorItem];
    [_menu addItem:_machineSeparator];
    
    // machines go here
    
    [_menu addItem:[NSMenuItem separatorItem]];
    
    NSMenuItem *preferencesMenuItem = [[NSMenuItem alloc] initWithTitle:@"Preferences" action:@selector(preferencesMenuItemClicked:) keyEquivalent:@""];
    preferencesMenuItem.target = self;
    [_menu addItem:preferencesMenuItem];
    
    NSMenuItem *aboutMenuItem = [[NSMenuItem alloc] initWithTitle:@"About" action:@selector(aboutMenuItemClicked:) keyEquivalent:@""];
    aboutMenuItem.target = self;
    [_menu addItem:aboutMenuItem];
    
    NSMenuItem *checkForUpdatesMenuItem = [[NSMenuItem alloc] initWithTitle:@"Check For Updates" action:@selector(checkForUpdatesMenuItemClicked:) keyEquivalent:@""];
    checkForUpdatesMenuItem.target = self;
    [_menu addItem:checkForUpdatesMenuItem];
    
    NSMenuItem *quitMenuItem = [[NSMenuItem alloc] initWithTitle:@"Quit" action:@selector(quitMenuItemClicked:) keyEquivalent:@""];
    quitMenuItem.target = self;
    [_menu addItem:quitMenuItem];
    
    return self;
}

#pragma mark - Notification Handlers

- (void)bookmarksUpdated:(NSNotification*)notification {
//    _menuItems = [self sortMenuItems];
//    [self.tableView reloadData];
}

- (void)notificationPreferenceChanged: (NSNotification*)notification {
//    if([[NSUserDefaults standardUserDefaults] boolForKey:@"dontShowUpdateNotification"]) {
//        [self setUpdatesAvailable:NO];
//    }
}

- (void)instanceAdded: (NSNotification*)notification {
    NativeMenuItem *item = [[NativeMenuItem alloc] init];
    item.instance = [notification.userInfo objectForKey:@"instance"];
    item.menuItem = [[NSMenuItem alloc] initWithTitle:item.instance.displayName action:nil keyEquivalent:@""];
    [_menu insertItem:item.menuItem atIndex:[_menu indexOfItem:_machineSeparator]+1];
}

- (void)instanceRemoved: (NSNotification*)notification {
//    [self removeInstance:[notification.userInfo objectForKey:@"instance"]];
}

- (void)instanceUpdated: (NSNotification*)notification {
//    [self updateInstance:[notification.userInfo objectForKey:@"old_instance"] withInstance:[notification.userInfo objectForKey:@"new_instance"]];
}

- (void)setUpdateAvailable: (NSNotification*)notification {
//    [self setUpdatesAvailable:[[notification.userInfo objectForKey:@"is_update_available"] boolValue]];
}

- (void)refreshingStarted: (NSNotification*)notification {
//    [self setIsRefreshing:YES];
}

- (void)refreshingEnded: (NSNotification*)notification {
//    [self setIsRefreshing:NO];
}


#pragma mark - Menu Item Click Handlers

- (void)preferencesMenuItemClicked:(id)sender {
    preferencesWindow = [[PreferencesWindow alloc] initWithWindowNibName:@"PreferencesWindow"];
    [NSApp activateIgnoringOtherApps:YES];
    [preferencesWindow showWindow:self];
}

- (void)quitMenuItemClicked:(id)sender {
    [[NSApplication sharedApplication] terminate:self];
}

- (void)aboutMenuItemClicked:(id)sender {
    aboutWindow = [[AboutWindow alloc] initWithWindowNibName:@"AboutWindow"];
    [NSApp activateIgnoringOtherApps:YES];
    [aboutWindow showWindow:self];
}

- (void)checkForUpdatesMenuItemClicked:(id)sender {
    [[SUUpdater sharedUpdater] checkForUpdates:self];
}

#pragma mark - Misc

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



@end
