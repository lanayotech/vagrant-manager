//
//  AppDelegate.h
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TaskOutputWindow.h"
#import "AboutWindow.h"
#import "VirtualMachineInfoWindow.h"
#import "VirtualMachineInfo.h"

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
    
    NSMenuItem *bookmarksSeparatorMenuItem;
    NSMenuItem *refreshDetectedMenuItem;
    NSMenuItem *detectedSeparatorMenuItem;
    NSMenuItem *preferencesMenuItem;
    NSMenuItem *aboutMenuItem;
    NSMenuItem *quitMenuItem;
    NSMenuItem *windowMenuItem;
    
    AboutWindow *aboutWindow;
}

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSMenu *windowMenu;

- (void)removeOutputWindow:(TaskOutputWindow*)outputWindow;
- (void)removeInfoWindow:(VirtualMachineInfoWindow*)infoWindow;
- (void)updateVirtualMachineState:(VirtualMachineInfo*)machine;
- (void)updateBookmarkState:(Bookmark*)bookmark;

@end
