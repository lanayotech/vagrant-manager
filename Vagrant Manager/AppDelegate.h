//
//  AppDelegate.h
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TaskOutputWindow.h"
#import "AboutWindow.h"
#import "PreferencesWindow.h"
#import "AddBookmarkWindow.h"
#import "VirtualMachineInfoWindow.h"
#import "VirtualMachineInfo.h"
#include <Sparkle/Sparkle.h>

#define MENU_ITEM_BOOKMARKED_VM 1
#define MENU_ITEM_DETECTED_VM   2

@interface AppDelegate : NSObject <NSApplicationDelegate, NSMenuDelegate> {
    enum MenuItemType : NSUInteger {
        MenuItemBookmarked = 1,
        MenuItemDetected
    };
    
    IBOutlet NSMenu *statusMenu;
    IBOutlet NSMenu *statusSubMenuTemplate;
    NSStatusItem *statusItem;
    
    NSMutableArray *taskOutputWindows;
    NSMutableArray *infoWindows;
    
    NSMutableArray *detectedVagrantMachines;
    NSMutableArray *bookmarks;
    
    NSMenuItem *addBookmarkMenuItem;
    NSMenuItem *bookmarksSeparatorMenuItem;
    NSMenuItem *refreshDetectedMenuItem;
    NSMenuItem *detectedSeparatorMenuItem;
    NSMenuItem *preferencesMenuItem;
    NSMenuItem *aboutMenuItem;
    NSMenuItem *quitMenuItem;
    NSMenuItem *windowMenuItem;
    NSMenuItem *expirationMenuItem;
    NSMenuItem *checkForUpdatesMenuItem;
    NSMenuItem *globalCommandsSeparatorMenuItem;
    NSMenuItem *haltAllMenuItem;
    
    AboutWindow *aboutWindow;
    PreferencesWindow *preferencesWindow;
    AddBookmarkWindow *addBookmarkWindow;
}

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSMenu *windowMenu;

- (void)removeOutputWindow:(TaskOutputWindow*)outputWindow;
- (void)removeInfoWindow:(VirtualMachineInfoWindow*)infoWindow;
- (void)updateVirtualMachineState:(VirtualMachineInfo*)machine;
- (void)updateBookmarkState:(Bookmark*)bookmark;
- (void)addBookmarkWithPath:(NSString*)path withDisplayName:(NSString*)displayName;
- (void)updateCheckUpdatesIcon:(BOOL)available;
- (void)rebuildMenu:(BOOL)closeMenu;
- (void)detectVagrantMachines;
- (void)saveBookmarks:(NSMutableArray*)bm;

@end
