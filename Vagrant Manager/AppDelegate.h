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
#include <Sparkle/Sparkle.h>
#import "MenuDelegate.h"
#import "NativeMenu.h"
#import "VagrantManager.h"

#define MENU_ITEM_BOOKMARKED_VM 1
#define MENU_ITEM_DETECTED_VM   2

@interface AppDelegate : NSObject <NSApplicationDelegate, VagrantManagerDelegate, MenuDelegate, NSMenuDelegate, NSUserNotificationCenterDelegate, SUUpdaterDelegate> {
    NSMutableArray *bookmarks;
}

@property (assign) IBOutlet NSWindow *window;
@property (strong, nonatomic) NSTimer *refreshTimer;

- (void)refreshVagrantMachines;
- (void)addOpenWindow:(id)window;
- (void)removeOpenWindow:(id)window;
- (void)updateRunningVmCount;
- (void)refreshTimerState;
- (NSImage*)getThemedImage:(NSString*)imageName;
- (void)showNotificationWithTitle:(NSString*)title informativeText:(NSString*)informativeText taskWindowUUID:(NSString*)taskWindowUUID;
- (void)showUserNotificationWithTitle:(NSString*)title informativeText:(NSString*)informativeText taskWindowUUID:(NSString*)taskWindowUUID;

@end
