//
//  CustomPopoverMenu.m
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import "CustomPopoverMenu.h"
#import "BookmarkManager.h"
#import "TextMenuItem.h"

@interface CustomPopoverMenu ()

@end

@implementation CustomPopoverMenu {
    BOOL _isRefreshing;
    NSMutableArray *_menuItems;
    NSMutableArray *_footerMenuItems;
}

#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _menuItems = [[NSMutableArray alloc] init];
        
        _footerMenuItems = [[NSMutableArray alloc] init];
        [_footerMenuItems addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"All Machines", @"text", @"all_machines", @"id", @"", @"image", nil]];
        [_footerMenuItems addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Preferences", @"text", @"preferences", @"id", @"", @"image", nil]];
        [_footerMenuItems addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"About", @"text", @"about", @"id", @"", @"image", nil]];
        [_footerMenuItems addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Check For Updates", @"text", @"check_for_updates", @"id", @"", @"image", nil]];
        [_footerMenuItems addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Quit", @"text", @"quit", @"id", @"", @"image", nil]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bookmarksUpdated:) name:@"vagrant-manager.bookmarks-updated" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rowMouseEntered:) name:@"vagrant-manager.menu-row-mouse-entered" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rowMouseExited:) name:@"vagrant-manager.menu-row-mouse-exited" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationPreferenceChanged:) name:@"vagrant-manager.notification-preference-changed" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(instanceAdded:) name:@"vagrant-manager.instance-added" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(instanceRemoved:) name:@"vagrant-manager.instance-removed" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(instanceUpdated:) name:@"vagrant-manager.instance-updated" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setUpdateAvailable:) name:@"vagrant-manager.update-available" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshingStarted:) name:@"vagrant-manager.refreshing-started" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshingEnded:) name:@"vagrant-manager.refreshing-ended" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRunningVmCount:) name:@"vagrant-manager.update-running-vm-count" object:nil];
        
    }
    return self;
}

- (void)rowMouseEntered:(NSNotification*)notification {
    NSNumber *num = [notification.userInfo objectForKey:@"row"];
    if(num) {
        NSTableRowView *rowView = [self.tableView rowViewAtRow:[num intValue] makeIfNecessary:NO];
        NSView *view = [rowView viewAtColumn:0];
        if ([view isKindOfClass:[InstanceMenuItem class]]) {
            ((InstanceMenuItem*)view).nameTextField.textColor = [NSColor whiteColor];
        } else if ([view isKindOfClass:[MachineMenuItem class]]) {
            ((MachineMenuItem*)view).nameTextField.textColor = [NSColor whiteColor];
        } else if ([view isKindOfClass:[TextMenuItem class]]) {
            ((TextMenuItem*)view).textField.textColor = [NSColor whiteColor];
        }
    }
}

- (void)rowMouseExited:(NSNotification*)notification {
    NSNumber *num = [notification.userInfo objectForKey:@"row"];
    if(num) {
        NSTableRowView *rowView = [self.tableView rowViewAtRow:[num intValue] makeIfNecessary:NO];
        NSView *view = [rowView viewAtColumn:0];
        if ([view isKindOfClass:[InstanceMenuItem class]]) {
            ((InstanceMenuItem*)view).nameTextField.textColor = [NSColor blackColor];
        } else if ([view isKindOfClass:[MachineMenuItem class]]) {
            ((MachineMenuItem*)view).nameTextField.textColor = [NSColor blackColor];
        } else if ([view isKindOfClass:[TextMenuItem class]]) {
            ((TextMenuItem*)view).textField.textColor = [NSColor blackColor];
        }
    }
}

- (void)bookmarksUpdated:(NSNotification*)notification {
    _menuItems = [self sortMenuItems];
    [self.tableView reloadData];
}

- (void)notificationPreferenceChanged: (NSNotification*)notification {
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"dontShowUpdateNotification"]) {
        [self setUpdatesAvailable:NO];
    }
}

- (void)instanceAdded: (NSNotification*)notification {
    [self addInstance:[notification.userInfo objectForKey:@"instance"]];
}

- (void)instanceRemoved: (NSNotification*)notification {
    [self removeInstance:[notification.userInfo objectForKey:@"instance"]];
}

- (void)instanceUpdated: (NSNotification*)notification {
    [self updateInstance:[notification.userInfo objectForKey:@"old_instance"] withInstance:[notification.userInfo objectForKey:@"new_instance"]];
}

- (void)setUpdateAvailable: (NSNotification*)notification {
    [self setUpdatesAvailable:[[notification.userInfo objectForKey:@"is_update_available"] boolValue]];
}

- (void)refreshingStarted: (NSNotification*)notification {
    [self setIsRefreshing:YES];
}

- (void)refreshingEnded: (NSNotification*)notification {
    [self setIsRefreshing:NO];
}

- (void)updateRunningVmCount: (NSNotification*)notification {
    int count = [[notification.userInfo objectForKey:@"count"] intValue];
    if(count) {
        if(![[NSUserDefaults standardUserDefaults] boolForKey:@"dontShowRunningVmCount"]) {
            [self.statusItemPopup setTitle:[NSString stringWithFormat:@"%d", count]];
        } else {
            [self.statusItemPopup setTitle:@""];
        }
        [self.statusItemPopup setImage:[[Util getApp] getThemedImage:@"vagrant_logo_on"]];
        [self.statusItemPopup setAlternateImage:[[Util getApp] getThemedImage:@"vagrant_logo_highlighted"]];
    } else {
        [self.statusItemPopup setTitle:@""];
        [self.statusItemPopup setImage:[[Util getApp] getThemedImage:@"vagrant_logo_off"]];
        [self.statusItemPopup setAlternateImage:[[Util getApp] getThemedImage:@"vagrant_logo_highlighted"]];
    }
}

- (void)loadView {
    [super loadView];
    
    [self.moreUpIndicator setHidden:YES];
    [self.moreDownIndicator setHidden:YES];
    [self setIsRefreshing:_isRefreshing];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView.enclosingScrollView setScrollerStyle:NSScrollerStyleOverlay];
    [self.tableView.enclosingScrollView setVerticalScrollElasticity:NSScrollElasticityNone];
    [self.tableView.enclosingScrollView setHorizontalScrollElasticity:NSScrollElasticityNone];
    
    [self.tableView.enclosingScrollView.contentView setPostsBoundsChangedNotifications:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollBoundsDidChange:) name:NSViewBoundsDidChangeNotification object:self.tableView.enclosingScrollView.contentView];
    
    [self.tableView reloadData];
}

- (void)scrollBoundsDidChange:(id)sender {
    [self updateScrollIndicators];
    [self.tableView enumerateAvailableRowViewsUsingBlock:^(NSTableRowView *rowView, NSInteger row) {
        [(InstanceRowView*)rowView checkHover];
    }];
}


#pragma mark - TableView delegates

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return _menuItems.count + _footerMenuItems.count;
}

- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row {
    InstanceRowView *rowView = [[InstanceRowView alloc] initWithFrame:NSMakeRect(0, 0, 100, 100)];
    rowView.rowIdx = row;
    return rowView;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    NSInteger row = [[notification object] selectedRow];
    if(row == -1) {
        return;
    }
    
    [self.tableView deselectRow:row];
    NSView *rowView = [self.tableView rowViewAtRow:row makeIfNecessary:NO];
    
    if(row >= _menuItems.count) {
        [self handleTextMenuItemClick:[((InstanceRowView*)rowView) viewAtColumn:0]];
        return;
    }
    
    MenuItemObject *menuItem = [_menuItems objectAtIndex:row];
    
    if([menuItem.target isKindOfClass:[VagrantInstance class]]) {
        VagrantInstance *instance = menuItem.target;
        
        NSMenu *menu = [[NSMenu alloc] init];
        
        [menu addItem:[[NSMenuItem alloc] initWithTitle:instance.displayName action:nil keyEquivalent:@""]];
        
        [menu addItem:[NSMenuItem separatorItem]];
        
        if([instance hasVagrantfile]) {
            if([instance getRunningMachineCount] < instance.machines.count) {
                NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:@"vagrant up" action:@selector(upMenuItemClicked:) keyEquivalent:@""];
                menuItem.target = self;
                menuItem.representedObject = instance;
                [menu addItem:menuItem];
            }

            if([instance getRunningMachineCount] > 0) {
                NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:@"vagrant ssh" action:@selector(sshMenuItemClicked:) keyEquivalent:@""];
                menuItem.target = self;
                menuItem.representedObject = instance;
                [menu addItem:menuItem];
                
                menuItem = [[NSMenuItem alloc] initWithTitle:@"vagrant reload" action:@selector(reloadMenuItemClicked:) keyEquivalent:@""];
                menuItem.target = self;
                menuItem.representedObject = instance;
                [menu addItem:menuItem];
                
                menuItem = [[NSMenuItem alloc] initWithTitle:@"vagrant suspend" action:@selector(suspendMenuItemClicked:) keyEquivalent:@""];
                menuItem.target = self;
                menuItem.representedObject = instance;
                [menu addItem:menuItem];
                
                menuItem = [[NSMenuItem alloc] initWithTitle:@"vagrant halt" action:@selector(haltMenuItemClicked:) keyEquivalent:@""];
                menuItem.target = self;
                menuItem.representedObject = instance;
                [menu addItem:menuItem];
                
                menuItem = [[NSMenuItem alloc] initWithTitle:@"vagrant provision" action:@selector(provisionMenuItemClicked:) keyEquivalent:@""];
                menuItem.target = self;
                menuItem.representedObject = instance;
                [menu addItem:menuItem];
            }
            
            NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:@"vagrant destroy" action:@selector(destroyMenuItemClicked:) keyEquivalent:@""];
            menuItem.target = self;
            menuItem.representedObject = instance;
            [menu addItem:menuItem];
        } else {
            [menu addItem:[[NSMenuItem alloc] initWithTitle:@"No Vagrantfile found" action:nil keyEquivalent:@""]];
        }
        
        [menu addItem:[NSMenuItem separatorItem]];
        
        NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:@"Open in Finder" action:@selector(finderMenuItemClicked:) keyEquivalent:@""];
        menuItem.target = self;
        menuItem.representedObject = instance;
        [menu addItem:menuItem];
        
        menuItem = [[NSMenuItem alloc] initWithTitle:@"Open in Terminal" action:@selector(terminalMenuItemClicked:) keyEquivalent:@""];
        menuItem.target = self;
        menuItem.representedObject = instance;
        [menu addItem:menuItem];
        
        menuItem = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"Provider: %@", instance.providerIdentifier ?: @"Unknown"] action:nil keyEquivalent:@""];
        NSMenu *submenu = [[NSMenu alloc] init];
        NSArray *providerIdentifiers = [[VagrantManager sharedManager] getProviderIdentifiers];
        for(NSString *providerIdentifier in providerIdentifiers) {
            NSMenuItem *submenuItem = [[NSMenuItem alloc] initWithTitle:providerIdentifier action:@selector(updateProviderIdentifier:) keyEquivalent:@""];
            submenuItem.representedObject = @{@"provider_identifier":providerIdentifier, @"instance":instance};
            submenuItem.target = self;
            [submenu addItem:submenuItem];
        }
        [menuItem setSubmenu:submenu];
        [menu addItem:menuItem];
        
        
        if([[BookmarkManager sharedManager] getBookmarkWithPath:instance.path]) {
            menuItem = [[NSMenuItem alloc] initWithTitle:@"Remove from bookmarks" action:@selector(removeBookmarkMenuItemClicked:) keyEquivalent:@""];
            menuItem.target = self;
            menuItem.representedObject = instance;
            [menu addItem:menuItem];
        } else {
            menuItem = [[NSMenuItem alloc] initWithTitle:@"Add to bookmarks" action:@selector(addBookmarkMenuItemClicked:) keyEquivalent:@""];
            menuItem.target = self;
            menuItem.representedObject = instance;
            [menu addItem:menuItem];
        }
        
        [NSMenu popUpContextMenu:menu withEvent:[[NSApplication sharedApplication] currentEvent] forView:rowView];
    } else if([menuItem.target isKindOfClass:[VagrantMachine class]]){
        VagrantMachine *machine = menuItem.target;
        
        NSMenu *menu = [[NSMenu alloc] init];
        
        [menu addItem:[[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"%@ - %@", machine.instance.displayName, machine.name] action:nil keyEquivalent:@""]];
        
        [menu addItem:[NSMenuItem separatorItem]];
        
        if(machine.state == RunningState) {
            NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:@"vagrant ssh" action:@selector(sshMenuItemClicked:) keyEquivalent:@""];
            menuItem.target = self;
            menuItem.representedObject = machine;
            [menu addItem:menuItem];
            
            menuItem = [[NSMenuItem alloc] initWithTitle:@"vagrant reload" action:@selector(reloadMenuItemClicked:) keyEquivalent:@""];
            menuItem.target = self;
            menuItem.representedObject = machine;
            [menu addItem:menuItem];
            
            menuItem = [[NSMenuItem alloc] initWithTitle:@"vagrant suspend" action:@selector(suspendMenuItemClicked:) keyEquivalent:@""];
            menuItem.target = self;
            menuItem.representedObject = machine;
            [menu addItem:menuItem];
            
            menuItem = [[NSMenuItem alloc] initWithTitle:@"vagrant halt" action:@selector(haltMenuItemClicked:) keyEquivalent:@""];
            menuItem.target = self;
            menuItem.representedObject = machine;
            [menu addItem:menuItem];
            
            menuItem = [[NSMenuItem alloc] initWithTitle:@"vagrant provision" action:@selector(provisionMenuItemClicked:) keyEquivalent:@""];
            menuItem.target = self;
            menuItem.representedObject = machine;
            [menu addItem:menuItem];
            
            menuItem = [[NSMenuItem alloc] initWithTitle:@"vagrant destroy" action:@selector(destroyMenuItemClicked:) keyEquivalent:@""];
            menuItem.target = self;
            menuItem.representedObject = machine;
            [menu addItem:menuItem];
        } else {
            NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:@"vagrant up" action:@selector(upMenuItemClicked:) keyEquivalent:@""];
            menuItem.target = self;
            menuItem.representedObject = machine;
            [menu addItem:menuItem];
            
            menuItem = [[NSMenuItem alloc] initWithTitle:@"vagrant destroy" action:@selector(destroyMenuItemClicked:) keyEquivalent:@""];
            menuItem.target = self;
            menuItem.representedObject = machine;
            [menu addItem:menuItem];
        }
        
        [menu addItem:[NSMenuItem separatorItem]];
        
        NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:@"Open in Finder" action:@selector(finderMenuItemClicked:) keyEquivalent:@""];
        menuItem.target = self;
        menuItem.representedObject = machine;
        [menu addItem:menuItem];
        
        menuItem = [[NSMenuItem alloc] initWithTitle:@"Open in Terminal" action:@selector(terminalMenuItemClicked:) keyEquivalent:@""];
        menuItem.target = self;
        menuItem.representedObject = machine;
        [menu addItem:menuItem];
        
        [NSMenu popUpContextMenu:menu withEvent:[[NSApplication sharedApplication] currentEvent] forView:rowView];
    }
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if(row >= _menuItems.count) {
        NSInteger footerRow = row - _menuItems.count;
        NSDictionary *itemObj = [_footerMenuItems objectAtIndex:footerRow];
        TextMenuItem *item = [tableView makeViewWithIdentifier:@"TextMenuItem" owner:self];
        [item.textField setStringValue:[itemObj objectForKey:@"text"]];
        item.itemId = [itemObj objectForKey:@"id"];
        if(footerRow == 0) {
            item.hasTopBorder = YES;
        } else {
            item.hasTopBorder = NO;
        }
        
        if([[itemObj objectForKey:@"image"] isEqualToString:@""]) {
            [item.imageView setHidden:YES];
        } else {
            [item.imageView setHidden:NO];
            [item.imageView setImage:[NSImage imageNamed:[itemObj objectForKey:@"image"]]];
        }
        
        return item;
    }
    
    MenuItemObject *itemObj = [_menuItems objectAtIndex:row];
    
    if([itemObj.target isKindOfClass:[VagrantInstance class]]) {
        InstanceMenuItem *item;
        item = [tableView makeViewWithIdentifier:@"InstanceMenuItem" owner:self];
        
        VagrantInstance *instance = itemObj.target;
        item.instance = instance;
        item.delegate = self;
        if([instance hasVagrantfile]) {
            int runningCount = [instance getRunningMachineCount];
            int suspendedCount = [instance getMachineCountWithState:SavedState];
            if(runningCount == 0 && suspendedCount == 0) {
                item.stateImageView.image = [NSImage imageNamed:@"status_icon_off"];
            } else if(runningCount == instance.machines.count) {
                item.stateImageView.image = [NSImage imageNamed:@"status_icon_on"];
            } else {
                item.stateImageView.image = [NSImage imageNamed:@"status_icon_suspended"];
            }
        } else {
            item.stateImageView.image = [NSImage imageNamed:@"status_icon_problem"];
        }
        
        if(instance.machines.count < 2) {
            [item.toggleOpenButton setHidden:YES];
        } else {
            [item.toggleOpenButton setHidden:NO];
        }
        
        [((NSButton*)item.toggleOpenButton) setImage:[NSImage imageNamed:itemObj.isExpanded ? @"arrow_down" : @"arrow_right"]];
        
        Bookmark *bookmark = [[BookmarkManager sharedManager] getBookmarkWithPath:instance.path];
        if(bookmark) {
            [item.bookmarkIconImageView setHidden:NO];
            item.nameTextField.stringValue = bookmark.displayName;
        } else {
            item.nameTextField.stringValue = instance.displayName;
            [item.bookmarkIconImageView setHidden:YES];
        }
        
        [self updateScrollIndicators];
        [self resizeTableView];
        
        return item;
    } else if([itemObj.target isKindOfClass:[VagrantMachine class]]) {
        MachineMenuItem *item = [tableView makeViewWithIdentifier:@"MachineMenuItem" owner:self];
        
        VagrantMachine *machine = itemObj.target;
        item.machine = machine;
        item.stateImageView.image = machine.state == RunningState ? [NSImage imageNamed:@"status_icon_on"] : machine.state == SavedState ? [NSImage imageNamed:@"status_icon_suspended"] : [NSImage imageNamed:@"status_icon_off"];
        item.nameTextField.stringValue = machine.name;
        
        [self updateScrollIndicators];
        [self resizeTableView];
        
        return item;
    }
    
    return nil;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return 22;
}

- (float)getTableHeight {
    float height = 22 * (_menuItems.count + _footerMenuItems.count);
    
    return height;
}

- (void)updateScrollIndicators {
    [self.moreUpIndicator setHidden:![self hasMoreUp]];
    [self.moreDownIndicator setHidden:![self hasMoreDown]];
}

- (BOOL)hasMoreUp {
    NSRect scrollRect = self.tableView.enclosingScrollView.contentView.documentVisibleRect;
    return scrollRect.origin.y > 0;
}

- (BOOL)hasMoreDown {
    NSRect scrollRect = self.tableView.enclosingScrollView.contentView.documentVisibleRect;
    NSRect frame = ((NSView*)self.tableView.enclosingScrollView.documentView).frame;
    return scrollRect.origin.y + scrollRect.size.height < frame.size.height;
}

- (void)resizeTableView {
    float width = 250;
    for(MenuItemObject *menuItem in _menuItems) {
        NSString *name = [menuItem.target isKindOfClass:[VagrantInstance class]] ? ((VagrantInstance*)menuItem.target).displayName : ((VagrantMachine*)menuItem.target).name;
        float padLeft = [menuItem.target isKindOfClass:[VagrantInstance class]] ? 18 : 28;
        NSAttributedString *string = [[NSAttributedString alloc] initWithString:name attributes:@{NSFontAttributeName: [NSFont systemFontOfSize:11]}];
        CGRect rect = [string boundingRectWithSize:(CGSize){CGFLOAT_MAX, CGFLOAT_MAX} options:0];
        float itemWidth = ceil(padLeft + rect.size.width + 18);
        
        if(itemWidth > width) {
            width = itemWidth;
        }
    }
    
    float maxHeight = [[NSScreen mainScreen] frame].size.height - [NSStatusBar systemStatusBar].thickness - 60;
    float tableHeight = MAX(29 + [self getTableHeight], 100);
    
    float height = MIN(maxHeight, tableHeight);

    if([self.statusItemPopup getPopover].isShown) {
        CGRect frame = self.view.frame;
        frame.size.width = width;
        frame.size.height = height;
        [[self.statusItemPopup getPopover] setContentSize:frame.size];
    }
    
    [self updateScrollIndicators];
}

#pragma mark - Control

- (void)setIsRefreshing:(BOOL)isRefreshing {
    _isRefreshing = isRefreshing;
    
    [self.refreshButton setEnabled:!isRefreshing];
    [self.refreshButton setHidden:isRefreshing];
    if(isRefreshing) {
        [self.refreshingIndicator startAnimation:self];
    } else {
        [self.refreshingIndicator stopAnimation:self];
    }
}

- (void)setUpdatesAvailable:(BOOL)updatesAvailable {
    NSMutableDictionary *menuItem = [self getFooterMenuItemWithId:@"check_for_updates"];
    if(updatesAvailable) {
        [menuItem setObject:@"status_icon_problem" forKey:@"image"];
    } else {
        [menuItem setObject:@"" forKey:@"image"];
    }
    
    [self.tableView reloadData];
}

- (int)getIndexOfMenuItemWithTarget:(id)target {
    for(int i=0; i<[_menuItems count]; ++i) {
        MenuItemObject *menuItem = [_menuItems objectAtIndex:i];
        
        if(menuItem.target == target) {
            return i;
        }
    }
    
    return -1;
}

#pragma mark - Menu management

- (NSMutableDictionary*)getFooterMenuItemWithId:(NSString*)itemId {
    for(NSMutableDictionary *menuItem in _footerMenuItems) {
        if([[menuItem objectForKey:@"id"] isEqualToString:itemId]) {
            return menuItem;
        }
    }
    
    return nil;
}

- (NSMutableArray*)sortMenuItems {
    NSMutableArray *instanceItems = [[NSMutableArray alloc] init];

    
    NSMutableDictionary *curObj = nil;
    
    for(MenuItemObject *menuItemObject in _menuItems) {
        if([menuItemObject.target isKindOfClass:[VagrantInstance class]]) {
            curObj = [[NSMutableDictionary alloc] init];
            [curObj setObject:menuItemObject forKey:@"instance"];
            [curObj setObject:[[NSMutableArray alloc] init] forKey:@"machines"];
            [instanceItems addObject:curObj];
        } else if([menuItemObject.target isKindOfClass:[VagrantMachine class]]) {
            NSMutableArray *machines = [curObj objectForKey:@"machines"];
            [machines addObject:menuItemObject];
        }
    }
    
    BookmarkManager *bookmarkManager = [BookmarkManager sharedManager];
    NSArray *sortedArray;
    sortedArray = [instanceItems sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSMutableDictionary *first = a;
        NSMutableDictionary *second = b;
        
        VagrantInstance *firstInstance = ((MenuItemObject*)[first objectForKey:@"instance"]).target;
        VagrantInstance *secondInstance = ((MenuItemObject*)[second objectForKey:@"instance"]).target;
        
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
                    return NSOrderedSame;
                }
            }
        }
    }];
    
    NSMutableArray *menuItems = [[NSMutableArray alloc] init];
    
    for(NSMutableDictionary *sortedObj in sortedArray) {
        [menuItems addObject:[sortedObj objectForKey:@"instance"]];
        
        NSArray *sortedMachinesArray = [[sortedObj objectForKey:@"machines"] sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            VagrantMachine *firstMachine = ((MenuItemObject*)a).target;
            VagrantMachine *secondMachine = ((MenuItemObject*)b).target;
            
            if(firstMachine.state == RunningState && secondMachine.state != RunningState) {
                return NSOrderedAscending;
            } else if(secondMachine.state == RunningState && firstMachine.state != RunningState) {
                return NSOrderedDescending;
            } else {
                return [firstMachine.name compare:secondMachine.name];
            }
        }];
        
        for(MenuItemObject *machineObj in sortedMachinesArray) {
            [menuItems addObject:machineObj];
        }
    }
    
    return menuItems;
}

- (void)instanceMenuItem:(InstanceMenuItem *)menuItem toggleOpenButtonClicked:(id)sender {
    int row = [self getIndexOfMenuItemWithTarget:menuItem.instance];
    
    MenuItemObject *menuItemObject = [_menuItems objectAtIndex:row];
    
    if([menuItemObject.target isKindOfClass:[VagrantInstance class]] && !menuItemObject.isChildMenuItem) {
        VagrantInstance *instance = menuItemObject.target;
        
        if(menuItemObject.isExpanded) {
            long nextRow = row + 1;
            while(nextRow < _menuItems.count && ((MenuItemObject*)[_menuItems objectAtIndex:nextRow]).isChildMenuItem) {
                [_menuItems removeObjectAtIndex:nextRow];
            }
        } else {
            int i = 1;
            for(VagrantMachine *machine in instance.machines) {
                MenuItemObject *obj = [[MenuItemObject alloc] initWithTarget:machine];
                obj.isChildMenuItem = YES;
                [_menuItems insertObject:obj atIndex:row+i];
                ++i;
            }
        }
        
        menuItemObject.isExpanded = !menuItemObject.isExpanded;
        
        _menuItems = [self sortMenuItems];
        
        [self.tableView reloadData];
        [self performSelector:@selector(resizeTableView) withObject:nil afterDelay:.25f];
    }
}

- (void)addInstance:(VagrantInstance*)instance {
    [_menuItems addObject:[[MenuItemObject alloc] initWithTarget:instance]];

    _menuItems = [self sortMenuItems];
    [self.tableView reloadData];
    [self resizeTableView];
}

- (void)updateInstance:(VagrantInstance*)oldInstance withInstance:(VagrantInstance *)newInstance {
    BOOL shouldExpand = NO;
    for(long i = _menuItems.count - 1; i >= 0; --i) {
        MenuItemObject *menuItem = [_menuItems objectAtIndex:i];
        if([menuItem.target isKindOfClass:[VagrantInstance class]] && !menuItem.isChildMenuItem) {
            VagrantInstance *itemInstance = (VagrantInstance*)menuItem.target;
            
            if([oldInstance.path isEqualToString:itemInstance.path]) {
                shouldExpand = menuItem.isExpanded;
                
                [_menuItems removeObjectAtIndex:i];
                
                while(i < _menuItems.count && ((MenuItemObject*)[_menuItems objectAtIndex:i]).isChildMenuItem) {
                    [_menuItems removeObjectAtIndex:i];
                }
            }
        }
    }
    
    MenuItemObject *menuItem = [[MenuItemObject alloc] initWithTarget:newInstance];
    long newIdx = _menuItems.count;
    [_menuItems addObject:menuItem];
    menuItem.isExpanded = shouldExpand;
    
    if(shouldExpand) {
        int i = 1;
        for(VagrantMachine *machine in newInstance.machines) {
            MenuItemObject *obj = [[MenuItemObject alloc] initWithTarget:machine];
            obj.isChildMenuItem = YES;
            [_menuItems insertObject:obj atIndex:newIdx+i];
            ++i;
        }
    }
    
    _menuItems = [self sortMenuItems];
    
    [self.tableView reloadData];
    [self resizeTableView];
}

- (void)removeInstance:(VagrantInstance*)instance {
    for(long i = _menuItems.count - 1; i >= 0; --i) {
        MenuItemObject *menuItem = [_menuItems objectAtIndex:i];
        if([menuItem.target isKindOfClass:[VagrantInstance class]] && !menuItem.isChildMenuItem) {
            VagrantInstance *itemInstance = (VagrantInstance*)menuItem.target;
            
            if(instance == itemInstance) {
                [_menuItems removeObjectAtIndex:i];
                
                while(i < _menuItems.count && ((MenuItemObject*)[_menuItems objectAtIndex:i]).isChildMenuItem) {
                    [_menuItems removeObjectAtIndex:i];
                }
            }
        }
    }
    
    _menuItems = [self sortMenuItems];
    
    [self.tableView reloadData];
    [self resizeTableView];
}

- (void)collapseAllChildMenuItems {
    for(long i = _menuItems.count - 1; i >= 0; --i) {
        MenuItemObject *menuItem = [_menuItems objectAtIndex:i];
        if(menuItem.isChildMenuItem) {
            [_menuItems removeObjectAtIndex:i];
        } else {
            if([menuItem.target isKindOfClass:[VagrantInstance class]]) {
                InstanceRowView *rowView = [_tableView rowViewAtRow:i makeIfNecessary:NO];
                InstanceMenuItem *instanceMenuItem = [rowView viewAtColumn:0];
                if([instanceMenuItem isKindOfClass:[InstanceMenuItem class]]) {
                    [instanceMenuItem.toggleOpenButton setImage:[NSImage imageNamed:@"arrow_right"]];
                }
            }
            menuItem.isExpanded = NO;
        }
    }
    [self.tableView reloadData];
    [self resizeTableView];
}

#pragma mark - Action Menu Item Handlers

- (void)updateProviderIdentifier:(NSMenuItem*)sender {
    VagrantInstance *instance = [sender.representedObject objectForKey:@"instance"];
    NSString *providerIdentifier = [sender.representedObject objectForKey:@"provider_identifier"];
    
    Bookmark *bookmark = [[BookmarkManager sharedManager] getBookmarkWithPath:instance.path];
    
    if(bookmark) {
        bookmark.providerIdentifier = providerIdentifier;
        [[BookmarkManager sharedManager] saveBookmarks];
    }
    
    instance.providerIdentifier = providerIdentifier;
    [self.tableView reloadData];
}

- (void)handleTextMenuItemClick:(TextMenuItem*)textMenuItem {
    NSString *itemId = textMenuItem.itemId;
    
    if([itemId isEqualToString:@"quit"]) {
        [[NSApplication sharedApplication] terminate:self];
    } else if([itemId isEqualToString:@"preferences"]) {
        preferencesWindow = [[PreferencesWindow alloc] initWithWindowNibName:@"PreferencesWindow"];
        [NSApp activateIgnoringOtherApps:YES];
        [preferencesWindow showWindow:self];
        [self.statusItemPopup hidePopover];
    } else if([itemId isEqualToString:@"about"]) {
        aboutWindow = [[AboutWindow alloc] initWithWindowNibName:@"AboutWindow"];
        [NSApp activateIgnoringOtherApps:YES];
        [aboutWindow showWindow:self];
        [self.statusItemPopup hidePopover];
    } else if([itemId isEqualToString:@"all_machines"]) {
        NSMenu *menu = [[NSMenu alloc] init];
        
        [menu addItem:[[NSMenuItem alloc] initWithTitle:@"All Machines" action:nil keyEquivalent:@""]];
        
        [menu addItem:[NSMenuItem separatorItem]];

        NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:@"vagrant up" action:@selector(allUpMenuItemClicked:) keyEquivalent:@""];
        menuItem.target = self;
        [menu addItem:menuItem];
        
        menuItem = [[NSMenuItem alloc] initWithTitle:@"vagrant reload" action:@selector(allReloadMenuItemClicked:) keyEquivalent:@""];
        menuItem.target = self;
        [menu addItem:menuItem];

        menuItem = [[NSMenuItem alloc] initWithTitle:@"vagrant suspend" action:@selector(allSuspendMenuItemClicked:) keyEquivalent:@""];
        menuItem.target = self;
        [menu addItem:menuItem];
        
        menuItem = [[NSMenuItem alloc] initWithTitle:@"vagrant halt" action:@selector(allHaltMenuItemClicked:) keyEquivalent:@""];
        menuItem.target = self;
        [menu addItem:menuItem];
        
        menuItem = [[NSMenuItem alloc] initWithTitle:@"vagrant provision" action:@selector(allProvisionMenuItemClicked:) keyEquivalent:@""];
        menuItem.target = self;
        [menu addItem:menuItem];
        
        menuItem = [[NSMenuItem alloc] initWithTitle:@"vagrant destroy" action:@selector(allDestroyMenuItemClicked:) keyEquivalent:@""];
        menuItem.target = self;
        [menu addItem:menuItem];
        
        [NSMenu popUpContextMenu:menu withEvent:[[NSApplication sharedApplication] currentEvent] forView:textMenuItem];
    } else if([itemId isEqualToString:@"check_for_updates"]) {
        [[SUUpdater sharedUpdater] checkForUpdates:self];
        [self.statusItemPopup hidePopover];
    }
}

- (IBAction)finderMenuItemClicked:(NSMenuItem*)sender {
    if([sender.representedObject isKindOfClass:[VagrantInstance class]]) {
        [self.delegate openInstanceInFinder:sender.representedObject];
        [self.statusItemPopup hidePopover];
    } else if([sender.representedObject isKindOfClass:[VagrantMachine class]]) {
        [self.delegate openInstanceInFinder:((VagrantMachine*)sender.representedObject).instance];
        [self.statusItemPopup hidePopover];
    }
}

- (IBAction)terminalMenuItemClicked:(NSMenuItem*)sender {
    if([sender.representedObject isKindOfClass:[VagrantInstance class]]) {
        [self.delegate openInstanceInTerminal:sender.representedObject];
        [self.statusItemPopup hidePopover];
    } else if([sender.representedObject isKindOfClass:[VagrantMachine class]]) {
        [self.delegate openInstanceInTerminal:((VagrantMachine*)sender.representedObject).instance];
        [self.statusItemPopup hidePopover];
    }
}

- (IBAction)addBookmarkMenuItemClicked:(NSMenuItem*)sender {
    if([sender.representedObject isKindOfClass:[VagrantInstance class]]) {
        [self.delegate addBookmarkWithInstance:sender.representedObject];
    }
}

- (IBAction)removeBookmarkMenuItemClicked:(NSMenuItem*)sender {
    if([sender.representedObject isKindOfClass:[VagrantInstance class]]) {
        [self.delegate removeBookmarkWithInstance:sender.representedObject];
    }
}

- (IBAction)sshMenuItemClicked:(NSMenuItem*)sender {
    if([sender.representedObject isKindOfClass:[VagrantInstance class]]) {
        [self performAction:@"ssh" withInstance:sender.representedObject];
    } else {
        [self performAction:@"ssh" withMachine:sender.representedObject];
    }
}

- (IBAction)upMenuItemClicked:(NSMenuItem*)sender {
    if([sender.representedObject isKindOfClass:[VagrantInstance class]]) {
        [self performAction:@"up" withInstance:sender.representedObject];
    } else {
        [self performAction:@"up" withMachine:sender.representedObject];
    }
}

- (IBAction)reloadMenuItemClicked:(NSMenuItem*)sender {
    if([sender.representedObject isKindOfClass:[VagrantInstance class]]) {
        [self performAction:@"reload" withInstance:sender.representedObject];
    } else {
        [self performAction:@"reload" withMachine:sender.representedObject];
    }
}

- (IBAction)suspendMenuItemClicked:(NSMenuItem*)sender {
    if([sender.representedObject isKindOfClass:[VagrantInstance class]]) {
        [self performAction:@"suspend" withInstance:sender.representedObject];
    } else {
        [self performAction:@"suspend" withMachine:sender.representedObject];
    }
}

- (IBAction)haltMenuItemClicked:(NSMenuItem*)sender {
    if([sender.representedObject isKindOfClass:[VagrantInstance class]]) {
        [self performAction:@"halt" withInstance:sender.representedObject];
    } else {
        [self performAction:@"halt" withMachine:sender.representedObject];
    }
}

- (IBAction)provisionMenuItemClicked:(NSMenuItem*)sender {
    if([sender.representedObject isKindOfClass:[VagrantInstance class]]) {
        [self performAction:@"provision" withInstance:sender.representedObject];
    } else {
        [self performAction:@"provision" withMachine:sender.representedObject];
    }
}

- (IBAction)destroyMenuItemClicked:(NSMenuItem*)sender {
    NSAlert *confirmAlert = [NSAlert alertWithMessageText:[NSString stringWithFormat:@"Are you sure you want to destroy %@?", [sender.target isKindOfClass:[VagrantInstance class]] ? @" all machines in this group" : @"this machine"] defaultButton:@"Confirm" alternateButton:@"Cancel" otherButton:nil informativeTextWithFormat:@""];
    NSInteger button = [confirmAlert runModal];
    
    if(button == NSAlertDefaultReturn) {
        if([sender.representedObject isKindOfClass:[VagrantInstance class]]) {
            [self performAction:@"destroy" withInstance:sender.representedObject];
        } else {
            [self performAction:@"destroy" withMachine:sender.representedObject];
        }
    }
}

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

#pragma mark - Vagrant Actions

- (void)performAction:(NSString*)action withInstance:(VagrantInstance*)instance {
    [self.delegate performVagrantAction:action withInstance:instance];
}

- (void)performAction:(NSString*)action withMachine:(VagrantMachine *)machine {
    [self.delegate performVagrantAction:action withMachine:machine];
}

#pragma mark - Button handlers

- (IBAction)bookmarkButtonClicked:(id)sender {
    manageBookmarksWindow = [[ManageBookmarksWindow alloc] initWithWindowNibName:@"ManageBookmarksWindow"];
    [NSApp activateIgnoringOtherApps:YES];
    [manageBookmarksWindow showWindow:self];
    [self.statusItemPopup hidePopover];
}

- (IBAction)refreshButtonClicked:(id)sender {
    [[Util getApp] refreshVagrantMachines];
}

@end
