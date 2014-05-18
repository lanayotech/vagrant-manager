//
//  PopupContentViewController.m
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import "PopupContentViewController.h"

@interface PopupContentViewController ()

@end

@implementation PopupContentViewController

#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

#pragma mark - Button handlers

- (IBAction)quitButtonClicked:(id)sender {
    [[NSApplication sharedApplication] terminate:self];
}

- (IBAction)preferencesButtonClicked:(id)sender {
    preferencesWindow = [[PreferencesWindow alloc] initWithWindowNibName:@"PreferencesWindow"];
    [NSApp activateIgnoringOtherApps:YES];
    [preferencesWindow showWindow:self];
    [self.statusItemPopup hidePopover];
}

- (IBAction)aboutButtonClicked:(id)sender {
    aboutWindow = [[AboutWindow alloc] initWithWindowNibName:@"AboutWindow"];
    [NSApp activateIgnoringOtherApps:YES];
    [aboutWindow showWindow:self];
    [self.statusItemPopup hidePopover];    
}

@end
