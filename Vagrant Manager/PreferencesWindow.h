//
//  PreferencesWindow.h
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BaseWindowController.h"

@interface PreferencesWindow : BaseWindowController {
    
}

@property (weak) IBOutlet NSButton *autoCloseCheckBox;
@property (weak) IBOutlet NSButton *dontShowUpdateCheckBox;
@property (weak) IBOutlet NSButton *optionKeyDestroyCheckBox;
@property (weak) IBOutlet NSButton *usePathAsInstanceDisplayNameCheckBox;
@property (weak) IBOutlet NSButton *includeMachineNamesCheckBox;
@property (weak) IBOutlet NSButton *dontShowRunningVmCountCheckBox;
@property (weak) IBOutlet NSPopUpButton *terminalPreferencePopUpButton;
@property (weak) IBOutlet NSPopUpButton *terminalEditorPreferencePopUpButton;
@property (weak) IBOutlet NSPopUpButton *statusBarIconThemePopUpButton;
@property (weak) IBOutlet NSPopUpButton *updateStabilityPopUpButton;
@property (weak) IBOutlet NSButton *sendProfileDataCheckBox;
@property (weak) IBOutlet NSButton *launchAtLoginCheckBox;
@property (weak) IBOutlet NSButton *refreshEveryCheckBox;
@property (weak) IBOutlet NSPopUpButton *intervalMenu;
@property (weak) IBOutlet NSButton *dontAnimateStatusIconCheckBox;
@property (weak) IBOutlet NSButton *showTaskNotificationCheckBox;


- (IBAction)autoCloseCheckBoxClicked:(id)sender;
- (IBAction)dontShowUpdateCheckBoxClicked:(id)sender;
- (IBAction)optionKeyDestroyCheckBoxClicked:(id)sender;
- (IBAction)usePathAsInstanceDisplayNameCheckBoxClicked:(id)sender;
- (IBAction)includeMachineNamesCheckBoxClicked:(id)sender;
- (IBAction)dontShowRunningVmCountCheckBoxClicked:(id)sender;
- (IBAction)terminalPreferencePopUpButtonClicked:(id)sender;
- (IBAction)statusBarIconThemePopUpButtonClicked:(id)sender;
- (IBAction)updateStabilityPopUpButtonClicked:(id)sender;
- (IBAction)sendProfileDataCheckBoxClicked:(id)sender;
- (IBAction)launchAtLoginCheckBoxClicked:(id)sender;
- (IBAction)refreshEveryCheckBoxClicked:(id)sender;
- (IBAction)intervalMenuChanged:(id)sender;
- (IBAction)dontAnimateStatusIconCheckBoxClicked:(id)sender;
- (IBAction)showTaskNotificationCheckBoxClicked:(id)sender;


@end
