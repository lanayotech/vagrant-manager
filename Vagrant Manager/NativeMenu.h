//
//  NativeMenu.h
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MenuDelegate.h"
#import "PreferencesWindow.h"
#import "AboutWindow.h"
#import "ManageBookmarksWindow.h"
#import "ManageCustomCommandsWindow.h"
#import "NativeMenuItem.h"
#import "CustomCommand.h"

@interface NativeMenu : NSObject <NSMenuDelegate, NativeMenuItemDelegate> {
    PreferencesWindow *preferencesWindow;
    AboutWindow *aboutWindow;
    ManageBookmarksWindow *manageBookmarksWindow;
    ManageCustomCommandsWindow *manageCustomCommandsWindow;
}

@property (weak) id<MenuDelegate> delegate;

- (void)rebuildMenu;

@end
