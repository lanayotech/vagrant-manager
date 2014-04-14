//
//  PreferencesWindow.h
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PreferencesWindow : NSWindowController {
    
}

@property (weak) IBOutlet NSButton *autoCloseCheckBox;
@property (weak) IBOutlet NSPopUpButton *terminalPreferencePopUpButton;
@property (weak) IBOutlet NSPopUpButton *statusBarIconThemePopUpButton;

- (IBAction)autoCloseCheckBoxClicked:(id)sender;
- (IBAction)terminalPreferencePopUpButtonClicked:(id)sender;
- (IBAction)statusBarIconThemePopUpButtonClicked:(id)sender;

@end
