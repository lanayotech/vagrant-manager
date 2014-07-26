//
//  PopupContentViewController.h
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "VagrantInstance.h"
#import "VagrantMachine.h"
#import "MenuItemObject.h"
#import "InstanceRowView.h"
#import "InstanceMenuItem.h"
#import "MachineMenuItem.h"
#import "ManageBookmarksWindow.h"

@class PopupContentViewController;

@protocol MenuDelegate <NSObject>

- (void)performVagrantAction:(NSString*)action withInstance:(VagrantInstance*)instance;
- (void)performVagrantAction:(NSString*)action withMachine:(VagrantMachine*)machine;
- (void)openInstanceInFinder:(VagrantInstance*)instance;
- (void)openInstanceInTerminal:(VagrantInstance*)instance;
- (void)addBookmarkWithInstance:(VagrantInstance*)instance;
- (void)removeBookmarkWithInstance:(VagrantInstance*)instance;

@end

@interface PopupContentViewController : NSViewController <NSTableViewDelegate, NSTableViewDataSource, InstanceMenuItemDelegate> {
    PreferencesWindow *preferencesWindow;
    AboutWindow *aboutWindow;
    ManageBookmarksWindow *manageBookmarksWindow;
}

@property (weak) AXStatusItemPopup *statusItemPopup;

@property (weak) IBOutlet NSButton *closeButton;
@property (weak) IBOutlet NSButton *refreshButton;
@property (weak) IBOutlet NSButton *bookmarkButton;
@property (weak) IBOutlet NSImageView *moreUpIndicator;
@property (weak) IBOutlet NSImageView *moreDownIndicator;
@property (weak) IBOutlet NSProgressIndicator *refreshingIndicator;
@property (weak) IBOutlet NSTableView *tableView;

@property (weak) id<MenuDelegate> delegate;

- (void)setIsRefreshing:(BOOL)isRefreshing;
- (void)addInstance:(VagrantInstance*)instance;
- (void)updateInstance:(VagrantInstance*)oldInstance withInstance:(VagrantInstance*)newInstance;
- (void)removeInstance:(VagrantInstance*)instance;
- (void)resizeTableView;
- (void)collapseAllChildMenuItems;

- (IBAction)closeButtonClicked:(id)sender;
- (IBAction)bookmarkButtonClicked:(id)sender;
- (IBAction)refreshButtonClicked:(id)sender;

@end
