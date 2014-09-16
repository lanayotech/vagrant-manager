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
@property (weak) IBOutlet NSButton *dontShowUpdateCheckBox;
@property (weak) IBOutlet NSButton *dontShowRunningVmCountCheckBox;
@property (weak) IBOutlet NSPopUpButton *terminalPreferencePopUpButton;
@property (weak) IBOutlet NSPopUpButton *statusBarIconThemePopUpButton;
@property (weak) IBOutlet NSPopUpButton *updateStabilityPopUpButton;
@property (weak) IBOutlet NSButton *sendProfileDataCheckBox;
@property (weak) IBOutlet NSButton *launchAtLoginCheckBox;
@property (weak) IBOutlet NSButton *refreshEveryCheckBox;
@property (weak) IBOutlet NSPopUpButton *intervalMenu;

- (IBAction)autoCloseCheckBoxClicked:(id)sender;
- (IBAction)dontShowUpdateCheckBoxClicked:(id)sender;
- (IBAction)dontShowRunningVmCountCheckBoxClicked:(id)sender;
- (IBAction)terminalPreferencePopUpButtonClicked:(id)sender;
- (IBAction)statusBarIconThemePopUpButtonClicked:(id)sender;
- (IBAction)updateStabilityPopUpButtonClicked:(id)sender;
- (IBAction)sendProfileDataCheckBoxClicked:(id)sender;
- (IBAction)launchAtLoginCheckBoxClicked:(id)sender;
- (IBAction)refreshEveryCheckBoxClicked:(id)sender;
- (IBAction)intervalMenuChanged:(id)sender;

@end
