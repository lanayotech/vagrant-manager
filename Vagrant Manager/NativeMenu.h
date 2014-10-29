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

@interface NativeMenu : NSObject <NSMenuDelegate> {
    PreferencesWindow *preferencesWindow;
    AboutWindow *aboutWindow;
    ManageBookmarksWindow *manageBookmarksWindow;
}

@property (weak) id<MenuDelegate> delegate;

@end
