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
#import "VirtualBoxMachineInfo.h"
#import "VirtualBoxServiceProvider.h"
#import "AXStatusItemPopup/AXStatusItemPopup.h"
#include <Sparkle/Sparkle.h>
#import "PopupContentViewController.h"
#import "VagrantManager.h"
#import "DDASLLogger.h"
#import "DDTTYLogger.h"
#import "DDFileLogger.h"

#define MENU_ITEM_BOOKMARKED_VM 1
#define MENU_ITEM_DETECTED_VM   2

@interface AppDelegate : NSObject <NSApplicationDelegate, VagrantManagerDelegate, MenuDelegate> {
    AXStatusItemPopup *statusItemPopup;
    /*
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
    NSMutableDictionary *serviceProviders;

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
    NSMenuItem *allMachinesMenuItem;

    AboutWindow *aboutWindow;
    PreferencesWindow *preferencesWindow;
    AddBookmarkWindow *addBookmarkWindow;
     */
}

@property (assign) IBOutlet NSWindow *window;

@property (weak) IBOutlet NSMenu *windowMenu;

- (void)refreshVagrantMachines;
- (void)removeTaskOutputWindow:(TaskOutputWindow*)taskOutputWindow;





- (void)removeInfoWindow:(VirtualMachineInfoWindow*)infoWindow;
- (void)updateVirtualMachineState:(VirtualMachineInfo*)machine;
- (void)updateBookmarkState:(Bookmark*)bookmark;
- (void)addBookmarkWithPath:(NSString*)path withDisplayName:(NSString*)displayName;
- (void)updateCheckUpdatesIcon:(BOOL)available;
- (void)rebuildMenu:(BOOL)closeMenu;
- (void)detectVagrantMachines;
- (void)saveBookmarks:(NSMutableArray*)bm;
- (void)updateRunningVmCount;

- (Bookmark*)getBookmarkById:(NSString*)uuid;
- (NSMutableDictionary*)getServiceProviders;


@end
