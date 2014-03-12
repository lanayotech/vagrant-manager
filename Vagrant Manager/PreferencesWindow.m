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
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    NSString *terminalPreference = [[NSUserDefaults standardUserDefaults] stringForKey:@"terminalPreference"];
    BOOL autoCloseTaskWindows = [[NSUserDefaults standardUserDefaults] boolForKey:@"autoCloseTaskWindows"];
    NSString *statusBarIconTheme = [[NSUserDefaults standardUserDefaults] stringForKey:@"statusBarIconTheme"];
    
    if([statusBarIconTheme isEqualToString:@"black"]) {
        [self.statusBarIconThemePopUpButton selectItemWithTag:101];
    } else if([statusBarIconTheme isEqualToString:@"flat"]) {
        [self.statusBarIconThemePopUpButton selectItemWithTag:102];
    } else if([statusBarIconTheme isEqualToString:@"clean"]) {
        [self.statusBarIconThemePopUpButton selectItemWithTag:103];
    } else {
        [self.statusBarIconThemePopUpButton selectItemWithTag:100];
    }
    
    if ([terminalPreference isEqualToString:@"iTerm"]) {
        [self.terminalPreferencePopUpButton selectItemWithTag:101];
    } else {
        [self.terminalPreferencePopUpButton selectItemWithTag:100];
    }
    
    [self.autoCloseCheckBox setState:autoCloseTaskWindows ? NSOnState : NSOffState];
}

- (IBAction)autoCloseCheckBoxClicked:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:(self.autoCloseCheckBox.state == NSOnState) forKey:@"autoCloseTaskWindows"];
    [[NSUserDefaults standardUserDefaults] synchronize];
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
    
    if (self.statusBarIconThemePopUpButton.selectedItem.tag == 101) {
        statusBarIconTheme = @"black";
    } else if (self.statusBarIconThemePopUpButton.selectedItem.tag == 102) {
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

@end
