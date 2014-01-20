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

@end
