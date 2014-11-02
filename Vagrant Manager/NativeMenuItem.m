//
//  NativeMenuItem.m
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import "NativeMenuItem.h"
#import "BookmarkManager.h"

@implementation NativeMenuItem {
    NSMenuItem *_instanceUpMenuItem;
    NSMenuItem *_sshMenuItem;
    NSMenuItem *_instanceReloadMenuItem;
    NSMenuItem *_instanceSuspendMenuItem;
    NSMenuItem *_instanceHaltMenuItem;
    NSMenuItem *_instanceDestroyMenuItem;
    NSMenuItem *_instanceProvisionMenuItem;
    
    NSMenuItem *_openInFinderMenuItem;
    NSMenuItem *_openInTerminalMenuItem;
    NSMenuItem *_addBookmarkMenuItem;
    NSMenuItem *_removeBookmarkMenuItem;
    NSMenuItem *_chooseProviderMenuItem;
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
    return [menuItem isEnabled];
}

- (void)refresh {
    
    if(self.instance) {
        
        if(!self.menuItem.hasSubmenu) {
            [self.menuItem setSubmenu:[[NSMenu alloc] init]];
            self.menuItem.submenu.delegate = self;
        }
        
        if(!_instanceUpMenuItem) {
            _instanceUpMenuItem = [[NSMenuItem alloc] initWithTitle:self.instance.machines.count > 1 ? @"up all" : @"up" action:@selector(upAllMachines:) keyEquivalent:@""];
            _instanceUpMenuItem.target = self;
            [self.menuItem.submenu addItem:_instanceUpMenuItem];
        }
        
        if(!_sshMenuItem) {
            _sshMenuItem = [[NSMenuItem alloc] initWithTitle:@"ssh" action:@selector(sshInstance:) keyEquivalent:@""];
            _sshMenuItem.target = self;
            [self.menuItem.submenu addItem:_sshMenuItem];
        }
        
        if(!_instanceReloadMenuItem) {
            _instanceReloadMenuItem = [[NSMenuItem alloc] initWithTitle:self.instance.machines.count > 1 ? @"reload all" : @"reload" action:@selector(reloadAllMachines:) keyEquivalent:@""];
            _instanceReloadMenuItem.target = self;
            [self.menuItem.submenu addItem:_instanceReloadMenuItem];
        }
        
        if(!_instanceSuspendMenuItem) {
            _instanceSuspendMenuItem = [[NSMenuItem alloc] initWithTitle:self.instance.machines.count > 1 ? @"suspend all" : @"suspend" action:@selector(suspendAllMachines:) keyEquivalent:@""];
            _instanceSuspendMenuItem.target = self;
            [self.menuItem.submenu addItem:_instanceSuspendMenuItem];
        }
        
        if(!_instanceHaltMenuItem) {
            _instanceHaltMenuItem = [[NSMenuItem alloc] initWithTitle:self.instance.machines.count > 1 ? @"halt all" : @"halt" action:@selector(haltAllMachines:) keyEquivalent:@""];
            _instanceHaltMenuItem.target = self;
            [self.menuItem.submenu addItem:_instanceHaltMenuItem];
        }
        
        if(!_instanceDestroyMenuItem) {
            _instanceDestroyMenuItem = [[NSMenuItem alloc] initWithTitle:self.instance.machines.count > 1 ? @"destroy all" : @"destroy" action:@selector(destroyAllMachines:) keyEquivalent:@""];
            _instanceDestroyMenuItem.target = self;
            [self.menuItem.submenu addItem:_instanceDestroyMenuItem];
        }
        
        if(!_instanceProvisionMenuItem) {
            _instanceProvisionMenuItem = [[NSMenuItem alloc] initWithTitle:self.instance.machines.count > 1 ? @"provision all" : @"provision" action:@selector(provisionAllMachines:) keyEquivalent:@""];
            _instanceProvisionMenuItem.target = self;
            [self.menuItem.submenu addItem:_instanceProvisionMenuItem];
        }
        
        [self.menuItem.submenu addItem:[NSMenuItem separatorItem]];
        
        if (!_openInFinderMenuItem) {
            _openInFinderMenuItem = [[NSMenuItem alloc] initWithTitle:@"Open in Finder" action:@selector(finderMenuItemClicked:) keyEquivalent:@""];
            _openInFinderMenuItem.target = self;
            [self.menuItem.submenu addItem:_openInFinderMenuItem];
        }
        
        if (!_openInTerminalMenuItem) {
            _openInTerminalMenuItem = [[NSMenuItem alloc] initWithTitle:@"Open in Terminal" action:@selector(terminalMenuItemClicked:) keyEquivalent:@""];
            _openInTerminalMenuItem.target = self;
            [self.menuItem.submenu addItem:_openInTerminalMenuItem];
        }
        
        if (!_chooseProviderMenuItem) {
            _chooseProviderMenuItem = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"Provider: %@", self.instance.providerIdentifier ?: @"Unknown"] action:nil keyEquivalent:@""];
            NSMenu *submenu = [[NSMenu alloc] init];
            NSArray *providerIdentifiers = [[VagrantManager sharedManager] getProviderIdentifiers];
            for(NSString *providerIdentifier in providerIdentifiers) {
                NSMenuItem *submenuItem = [[NSMenuItem alloc] initWithTitle:providerIdentifier action:@selector(updateProviderIdentifier:) keyEquivalent:@""];
                submenuItem.representedObject = providerIdentifier;
                submenuItem.target = self;
                [submenu addItem:submenuItem];
            }
            [_chooseProviderMenuItem setSubmenu:submenu];
            [self.menuItem.submenu addItem:_chooseProviderMenuItem];
        } else {
            _chooseProviderMenuItem.title = [NSString stringWithFormat:@"Provider: %@", self.instance.providerIdentifier ?: @"Unknown"];
        }
        
        if (!_removeBookmarkMenuItem) {
            _removeBookmarkMenuItem = [[NSMenuItem alloc] initWithTitle:@"Remove from bookmarks" action:@selector(removeBookmarkMenuItemClicked:) keyEquivalent:@""];
            _removeBookmarkMenuItem.target = self;
            [self.menuItem.submenu addItem:_removeBookmarkMenuItem];
        }
        
        if (!_addBookmarkMenuItem) {
            _addBookmarkMenuItem = [[NSMenuItem alloc] initWithTitle:@"Add to bookmarks" action:@selector(addBookmarkMenuItemClicked:) keyEquivalent:@""];
            _addBookmarkMenuItem.target = self;
            [self.menuItem.submenu addItem:_addBookmarkMenuItem];
        }
        
        if([self.instance hasVagrantfile]) {
            int runningCount = [self.instance getRunningMachineCount];
            int suspendedCount = [self.instance getMachineCountWithState:SavedState];
            if(runningCount == 0 && suspendedCount == 0) {
                self.menuItem.image = [NSImage imageNamed:@"status_icon_off"];
            } else if(runningCount == self.instance.machines.count) {
                self.menuItem.image = [NSImage imageNamed:@"status_icon_on"];
            } else {
                self.menuItem.image = [NSImage imageNamed:@"status_icon_suspended"];
            }
            
            if([self.instance getRunningMachineCount] < self.instance.machines.count) {
                [_instanceUpMenuItem setHidden:NO];
                [_sshMenuItem setHidden:YES];
                [_instanceReloadMenuItem setHidden:YES];
                [_instanceSuspendMenuItem setHidden:YES];
                [_instanceHaltMenuItem setHidden:YES];
                [_instanceProvisionMenuItem setHidden:YES];
            }
            
            if([self.instance getRunningMachineCount] > 0) {
                [_instanceUpMenuItem setHidden:YES];
                [_sshMenuItem setHidden:NO];
                [_instanceReloadMenuItem setHidden:NO];
                [_instanceSuspendMenuItem setHidden:NO];
                [_instanceHaltMenuItem setHidden:NO];
                [_instanceProvisionMenuItem setHidden:NO];
            }
            
            if([[BookmarkManager sharedManager] getBookmarkWithPath:self.instance.path]) {
                [_removeBookmarkMenuItem setHidden:NO];
                [_addBookmarkMenuItem setHidden:YES];
            } else {
                [_addBookmarkMenuItem setHidden:NO];
                [_removeBookmarkMenuItem setHidden:YES];
            }
            
        } else {
            self.menuItem.image = [NSImage imageNamed:@"status_icon_problem"];
            self.menuItem.submenu = nil;
        }
        
        Bookmark *bookmark = [[BookmarkManager sharedManager] getBookmarkWithPath:self.instance.path];
        if(bookmark) {
            self.menuItem.title = [NSString stringWithFormat:@"[B] %@", bookmark.displayName];
        } else {
            self.menuItem.title = self.instance.displayName;
        }
        
    } else {
        self.menuItem.submenu = nil;
    }
}

- (void)upAllMachines:(NSMenuItem*)sender {
    [self.delegate nativeMenuItemUpAllMachines:self];
}

- (void)sshInstance:(NSMenuItem*)sender {
    [self.delegate nativeMenuItemSSHInstance:self];
}

- (void)reloadAllMachines:(NSMenuItem*)sender {
    [self.delegate nativeMenuItemReloadAllMachines:self];
}

- (void)suspendAllMachines:(NSMenuItem*)sender {
    [self.delegate nativeMenuItemSuspendAllMachines:self];
}

- (void)haltAllMachines:(NSMenuItem*)sender {
    [self.delegate nativeMenuItemHaltAllMachines:self];
}

- (void)destroyAllMachines:(NSMenuItem*)sender {
    [self.delegate nativeMenuItemDestroyAllMachines:self];
}

- (void)provisionAllMachines:(NSMenuItem*)sender {
    [self.delegate nativeMenuItemProvisionAllMachines:self];
}

- (void)finderMenuItemClicked:(NSMenuItem*)sender {
    [self.delegate nativeMenuItemOpenFinder:self];
}

- (void)terminalMenuItemClicked:(NSMenuItem*)sender {
    [self.delegate nativeMenuItemOpenTerminal:self];
}

- (void)updateProviderIdentifier:(NSMenuItem*)sender {
    [self.delegate nativeMenuItemUpdateProviderIdentifier:self withProviderIdentifier:sender.representedObject];
}

- (void)removeBookmarkMenuItemClicked:(NSMenuItem*)sender {
    [self.delegate nativeMenuItemRemoveBookmark:self];
}

- (void)addBookmarkMenuItemClicked:(NSMenuItem*)sender {
    [self.delegate nativeMenuItemAddBookmark:self];
}

@end
