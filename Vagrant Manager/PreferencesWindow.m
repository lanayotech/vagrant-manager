//
//  PreferencesWindow.m
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import "PreferencesWindow.h"

@interface PreferencesWindow ()

@end

@implementation PreferencesWindow

- (id)initWithWindow:(NSWindow *)window {
    self = [super initWithWindow:window];
    
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    NSString *terminalPreference = [[NSUserDefaults standardUserDefaults] stringForKey:@"terminalPreference"];
    BOOL autoCloseTaskWindows = [[NSUserDefaults standardUserDefaults] boolForKey:@"autoCloseTaskWindows"];
    BOOL dontShowUpdateNotification = [[NSUserDefaults standardUserDefaults] boolForKey:@"dontShowUpdateNotification"];
    NSString *statusBarIconTheme = [[NSUserDefaults standardUserDefaults] stringForKey:@"statusBarIconTheme"];
    NSString *updateStability = [Util getUpdateStability];
    
    if([statusBarIconTheme isEqualToString:@"flat"]) {
        [self.statusBarIconThemePopUpButton selectItemWithTag:102];
    } else if([statusBarIconTheme isEqualToString:@"default"]) {
        [self.statusBarIconThemePopUpButton selectItemWithTag:100];
    } else {
        [self.statusBarIconThemePopUpButton selectItemWithTag:103];
    }
    
    if ([terminalPreference isEqualToString:@"iTerm"]) {
        [self.terminalPreferencePopUpButton selectItemWithTag:101];
    } else {
        [self.terminalPreferencePopUpButton selectItemWithTag:100];
    }
    
    if([updateStability isEqualToString:@"rc"]) {
        [self.updateStabilityPopUpButton selectItemWithTag:101];
    } else if([updateStability isEqualToString:@"beta"]) {
        [self.updateStabilityPopUpButton selectItemWithTag:102];
    } else if([updateStability isEqualToString:@"alpha"]) {
        [self.updateStabilityPopUpButton selectItemWithTag:103];
    } else if([updateStability isEqualToString:@"debug"]) {
        [self.updateStabilityPopUpButton selectItemWithTag:104];
    } else {
        [self.updateStabilityPopUpButton selectItemWithTag:100];
    }

    [self.autoCloseCheckBox setState:autoCloseTaskWindows ? NSOnState : NSOffState];
    [self.dontShowUpdateCheckBox setState:dontShowUpdateNotification ? NSOnState : NSOffState];
    [self.sendProfileDataCheckBox setState:[Util shouldSendProfileData] ? NSOnState : NSOffState];
}

- (IBAction)autoCloseCheckBoxClicked:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:(self.autoCloseCheckBox.state == NSOnState) forKey:@"autoCloseTaskWindows"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)dontShowUpdateCheckBoxClicked:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:(self.dontShowUpdateCheckBox.state == NSOnState) forKey:@"dontShowUpdateNotification"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[Util getApp] updateCheckUpdatesIcon:NO];
}

- (IBAction)terminalPreferencePopUpButtonClicked:(id)sender {
    NSString *terminalPreference;
    
    if (self.terminalPreferencePopUpButton.selectedItem.tag == 101) {
        terminalPreference = @"iTerm";
    } else {
        terminalPreference = @"Terminal";
    }
    
    [[NSUserDefaults standardUserDefaults] setValue:terminalPreference forKey:@"terminalPreference"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)statusBarIconThemePopUpButtonClicked:(id)sender {
    NSString *statusBarIconTheme;
    
    if (self.statusBarIconThemePopUpButton.selectedItem.tag == 102) {
        statusBarIconTheme = @"flat";
    } else if (self.statusBarIconThemePopUpButton.selectedItem.tag == 103) {
        statusBarIconTheme = @"clean";
    } else {
        statusBarIconTheme = @"default";
    }
    
    [[NSUserDefaults standardUserDefaults] setValue:statusBarIconTheme forKey:@"statusBarIconTheme"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[Util getApp] rebuildMenu:NO];
}

- (IBAction)updateStabilityPopUpButtonClicked:(id)sender {
    NSString *updateStability;
    
    if(self.updateStabilityPopUpButton.selectedItem.tag == 101) {
        updateStability = @"rc";
    } else if(self.updateStabilityPopUpButton.selectedItem.tag == 102) {
        updateStability = @"beta";
    } else if(self.updateStabilityPopUpButton.selectedItem.tag == 103) {
        updateStability = @"alpha";
    } else if(self.updateStabilityPopUpButton.selectedItem.tag == 104) {
        updateStability = @"debug";
    } else {
        updateStability = @"stable";
    }

    [[NSUserDefaults standardUserDefaults] setValue:updateStability forKey:@"updateStability"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [[SUUpdater sharedUpdater] checkForUpdateInformation];
}

- (IBAction)sendProfileDataCheckBoxClicked:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:(self.sendProfileDataCheckBox.state == NSOnState) forKey:@"sendProfileData"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[SUUpdater sharedUpdater] setSendsSystemProfile:[Util shouldSendProfileData]];
}

@end
