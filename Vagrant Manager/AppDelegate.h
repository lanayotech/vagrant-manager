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
#import "VirtualBoxMachineInfo.h"
#import "VirtualBoxServiceProvider.h"
#import "ParallelsServiceProvider.h"
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
    NSMutableArray *bookmarks;
}

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSMenu *windowMenu;
@property (strong, nonatomic) NSTimer *refreshTimer;

- (void)refreshVagrantMachines;
- (void)removeTaskOutputWindow:(TaskOutputWindow*)taskOutputWindow;
- (void)updateRunningVmCount;
- (void)refreshTimerState;

@end
