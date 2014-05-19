//
//  PopupContentViewController.h
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SlideMenuView.h"

@interface PopupContentViewController : NSViewController <SlideMenuDelegate> {
    PreferencesWindow *preferencesWindow;
    AboutWindow *aboutWindow;
}

@property (weak) AXStatusItemPopup *statusItemPopup;

@property (weak) IBOutlet NSButton *quitButton;
@property (weak) IBOutlet NSButton *preferencesButton;
@property (weak) IBOutlet NSButton *aboutButton;
@property (weak) IBOutlet SlideMenuView *slideMenu;
@property (weak) IBOutlet NSButton *refreshButton;
@property (weak) IBOutlet NSImageView *moreUpIndicator;
@property (weak) IBOutlet NSImageView *moreDownIndicator;
@property (weak) IBOutlet NSProgressIndicator *refreshingIndicator;

- (void)setIsRefreshing:(BOOL)isRefreshing;
- (void)addInstance:(VagrantInstance*)instance;

- (IBAction)quitButtonClicked:(id)sender;
- (IBAction)preferencesButtonClicked:(id)sender;
- (IBAction)aboutButtonClicked:(id)sender;
- (IBAction)refreshButtonClicked:(id)sender;

@end
