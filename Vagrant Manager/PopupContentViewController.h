//
//  PopupContentViewController.h
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "VagrantInstance.h"
#import "MenuItemObject.h"
#import "InstanceRowView.h"
#import "InstanceMenuItem.h"
#import "InstanceActionsMenuItem.h"
#import "MachineMenuItem.h"

@class PopupContentViewController;

@protocol MenuDelegate <NSObject>

- (void)machineMenuItem:(MachineMenuItem*)menuItem vagrantAction:(NSString*)action;
- (void)instanceActionsMenuItem:(InstanceActionsMenuItem*)menuItem vagrantAction:(NSString*)action;

@end

@interface PopupContentViewController : NSViewController <NSTableViewDelegate, NSTableViewDataSource, MachineMenuItemDelegate, InstanceActionsMenuItemDelegate> {
    PreferencesWindow *preferencesWindow;
    AboutWindow *aboutWindow;
}

@property (weak) AXStatusItemPopup *statusItemPopup;

@property (weak) IBOutlet NSButton *quitButton;
@property (weak) IBOutlet NSButton *preferencesButton;
@property (weak) IBOutlet NSButton *aboutButton;
@property (weak) IBOutlet NSButton *refreshButton;
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

- (IBAction)quitButtonClicked:(id)sender;
- (IBAction)preferencesButtonClicked:(id)sender;
- (IBAction)aboutButtonClicked:(id)sender;
- (IBAction)refreshButtonClicked:(id)sender;

@end
