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
    NSString *terminalEditorPreference = [[NSUserDefaults standardUserDefaults] stringForKey:@"terminalEditorPreference"];
    BOOL autoCloseTaskWindows = [[NSUserDefaults standardUserDefaults] boolForKey:@"autoCloseTaskWindows"];
    BOOL hideTaskWindows = [[NSUserDefaults standardUserDefaults] boolForKey:@"hideTaskWindows"];
    BOOL haltOnExit = [[NSUserDefaults standardUserDefaults] boolForKey:@"haltOnExit"];
    BOOL dontShowUpdateNotification = [[NSUserDefaults standardUserDefaults] boolForKey:@"dontShowUpdateNotification"];
    BOOL optionKeyDestroy = [[NSUserDefaults standardUserDefaults] boolForKey:@"optionKeyDestroy"];
    BOOL usePathAsInstanceDisplayName = [[NSUserDefaults standardUserDefaults] boolForKey:@"usePathAsInstanceDisplayName"];
    BOOL useProviderMachineDetection = [[NSUserDefaults standardUserDefaults] boolForKey:@"useProviderMachineDetection"];
    BOOL includeMachineNames = [[NSUserDefaults standardUserDefaults] boolForKey:@"includeMachineNamesInMenu"];
    BOOL dontShowRunningVmCount = [[NSUserDefaults standardUserDefaults] boolForKey:@"dontShowRunningVmCount"];
    BOOL refreshEvery = [[NSUserDefaults standardUserDefaults] boolForKey:@"refreshEvery"];
    BOOL dontAnimateStatusIcon = [[NSUserDefaults standardUserDefaults] boolForKey:@"dontAnimateStatusIcon"];
    BOOL showTaskNotification = [[NSUserDefaults standardUserDefaults] boolForKey:@"showTaskNotification"];
    NSInteger refreshEveryInterval = [[NSUserDefaults standardUserDefaults] integerForKey:@"refreshEveryInterval"];
    NSString *statusBarIconTheme = [[NSUserDefaults standardUserDefaults] stringForKey:@"statusBarIconTheme"];
    NSString *updateStability = [Util getUpdateStability];
    
    if([statusBarIconTheme isEqualToString:@"flat"]) {
        [self.statusBarIconThemePopUpButton selectItemWithTag:102];
    } else {
        [self.statusBarIconThemePopUpButton selectItemWithTag:103];
    }
    
    if ([terminalPreference isEqualToString:@"iTerm"]) {
        [self.terminalPreferencePopUpButton selectItemWithTag:101];
    } else {
        [self.terminalPreferencePopUpButton selectItemWithTag:100];
    }
    
    if ([terminalEditorPreference isEqualToString:@"vim"]) {
        [self.terminalEditorPreferencePopUpButton selectItemWithTag:101];
    } else if ([terminalEditorPreference isEqualToString:@"emacs"]) {
        [self.terminalEditorPreferencePopUpButton selectItemWithTag:102];
    } else if ([terminalEditorPreference isEqualToString:@"micro"]) {
        [self.terminalEditorPreferencePopUpButton selectItemWithTag:103];
    } else {
        [self.terminalEditorPreferencePopUpButton selectItemWithTag:100];
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
    [self.hideTaskWindowsCheckBox setState:hideTaskWindows ? NSOnState : NSOffState];
    [self.haltOnExitCheckBox setState:haltOnExit ? NSOnState : NSOffState];
    [self.dontShowUpdateCheckBox setState:dontShowUpdateNotification ? NSOnState : NSOffState];
    [self.optionKeyDestroyCheckBox setState:optionKeyDestroy ? NSOnState : NSOffState];
    [self.usePathAsInstanceDisplayNameCheckBox setState:usePathAsInstanceDisplayName ? NSOnState : NSOffState];
    [self.useProviderMachineDetectionCheckBox setState:useProviderMachineDetection ? NSOnState: NSOffState];
    [self.includeMachineNamesCheckBox setState:includeMachineNames ? NSOnState : NSOffState];
    [self.dontShowRunningVmCountCheckBox setState:dontShowRunningVmCount ? NSOnState : NSOffState];
    [self.dontAnimateStatusIconCheckBox setState:dontAnimateStatusIcon ? NSOnState : NSOffState];
    [self.refreshEveryCheckBox setState:refreshEvery ? NSOnState : NSOffState];
    [self.showTaskNotificationCheckBox setState:showTaskNotification ? NSOnState : NSOffState];
    [self.intervalMenu selectItemWithTag:refreshEveryInterval];
    
    [self.sendProfileDataCheckBox setState:[Util shouldSendProfileData] ? NSOnState : NSOffState];
    [self.launchAtLoginCheckBox setState:[self willStartAtLogin] ? NSOnState : NSOffState];
}

- (IBAction)haltOnExitCheckBoxClicked:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:(self.haltOnExitCheckBox.state == NSOnState) forKey:@"haltOnExit"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"vagrant-manager.halt-on-exit-preference-changed" object:nil];
}

- (IBAction)autoCloseCheckBoxClicked:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:(self.autoCloseCheckBox.state == NSOnState) forKey:@"autoCloseTaskWindows"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)hideTaskWindowsCheckBoxClicked:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:(self.hideTaskWindowsCheckBox.state == NSOnState) forKey:@"hideTaskWindows"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)dontShowUpdateCheckBoxClicked:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:(self.dontShowUpdateCheckBox.state == NSOnState) forKey:@"dontShowUpdateNotification"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"vagrant-manager.show-update-notification-preference-changed" object:nil];
}

- (IBAction)optionKeyDestroyCheckBoxClicked:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:(self.optionKeyDestroyCheckBox.state == NSOnState) forKey:@"optionKeyDestroy"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)usePathAsInstanceDisplayNameCheckBoxClicked:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:(self.usePathAsInstanceDisplayNameCheckBox.state == NSOnState) forKey:@"usePathAsInstanceDisplayName"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"vagrant-manager.use-path-as-instance-display-name-preference-changed" object:nil];
}

- (IBAction)useProviderMachineDetectionCheckBoxClicked:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:(self.useProviderMachineDetectionCheckBox.state == NSOnState) forKey:@"useProviderMachineDetection"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)includeMachineNamesCheckBoxClicked:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:(self.includeMachineNamesCheckBox.state == NSOnState) forKey:@"includeMachineNamesInMenu"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"vagrant-manager.include-machine-names-in-menu-preference-changed" object:nil];
}

- (IBAction)dontShowRunningVmCountCheckBoxClicked:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:(self.dontShowRunningVmCountCheckBox.state == NSOnState) forKey:@"dontShowRunningVmCount"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"vagrant-manager.show-running-vm-count-preference-changed" object:nil];
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

- (IBAction)terminalEditorPreferencePopUpButtonClicked:(id)sender {
    NSString *terminalEditorPreference;
    
    if (self.terminalEditorPreferencePopUpButton.selectedItem.tag == 101) {
        terminalEditorPreference = @"vim";
    } else if (self.terminalEditorPreferencePopUpButton.selectedItem.tag == 102) {
        terminalEditorPreference = @"emacs";
    } else if (self.terminalEditorPreferencePopUpButton.selectedItem.tag == 103) {
        terminalEditorPreference = @"micro";
    } else {
        terminalEditorPreference = @"nano";
    }
    
    [[NSUserDefaults standardUserDefaults] setValue:terminalEditorPreference forKey:@"terminalEditorPreference"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)statusBarIconThemePopUpButtonClicked:(id)sender {
    NSString *statusBarIconTheme;
    
    if (self.statusBarIconThemePopUpButton.selectedItem.tag == 102) {
        statusBarIconTheme = @"flat";
    } else if (self.statusBarIconThemePopUpButton.selectedItem.tag == 103) {
        statusBarIconTheme = @"clean";
    }
    
    [[NSUserDefaults standardUserDefaults] setValue:statusBarIconTheme forKey:@"statusBarIconTheme"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"vagrant-manager.theme-changed" object:nil];
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

- (IBAction)launchAtLoginCheckBoxClicked:(id)sender {
    [self setLaunchOnLogin:(self.launchAtLoginCheckBox.state == NSOnState)];
}

- (IBAction)dontAnimateStatusIconCheckBoxClicked:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:(self.dontAnimateStatusIconCheckBox.state == NSOnState) forKey:@"dontAnimateStatusIcon"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)showTaskNotificationCheckBoxClicked:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:(self.showTaskNotificationCheckBox.state == NSOnState) forKey:@"showTaskNotification"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)refreshEveryCheckBoxClicked:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:(self.refreshEveryCheckBox.state == NSOnState) forKey:@"refreshEvery"];
    [[NSUserDefaults standardUserDefaults] setInteger:self.intervalMenu.selectedItem.tag forKey:@"refreshEveryInterval"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[Util getApp] refreshTimerState];
}

- (IBAction)intervalMenuChanged:(id)sender {
    [[NSUserDefaults standardUserDefaults] setInteger:self.intervalMenu.selectedItem.tag forKey:@"refreshEveryInterval"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[Util getApp] refreshTimerState];
}

- (void)setLaunchOnLogin:(BOOL)launchOnLogin {
    NSURL *bundleURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
    
    LSSharedFileListItemRef existingItem = NULL;
    
    LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    if (loginItems) {
        UInt32 seed = 0U;
        NSArray *currentLoginItems = (__bridge NSArray *)(LSSharedFileListCopySnapshot(loginItems, &seed));
        for (id itemObject in currentLoginItems) {
            LSSharedFileListItemRef item = (__bridge LSSharedFileListItemRef)itemObject;
            
            UInt32 resolutionFlags = kLSSharedFileListNoUserInteraction | kLSSharedFileListDoNotMountVolumes;
            CFURLRef URL = NULL;
            OSStatus err = LSSharedFileListItemResolve(item, resolutionFlags, &URL, NULL);
            if (err == noErr) {
                Boolean foundIt = CFEqual(URL, (__bridge CFTypeRef)(bundleURL));
                CFRelease(URL);
                
                if (foundIt) {
                    existingItem = item;
                    break;
                }
            }
        }
        
        if (launchOnLogin && (existingItem == NULL)) {
            LSSharedFileListInsertItemURL(loginItems, kLSSharedFileListItemBeforeFirst, NULL, NULL, (__bridge CFURLRef)bundleURL, NULL, NULL);
            
        } else if (!launchOnLogin && (existingItem != NULL)) {
            LSSharedFileListItemRemove(loginItems, existingItem);
        }
        
        CFRelease(loginItems);
    }
}

- (BOOL)willStartAtLogin {
    NSURL *bundleURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
    BOOL foundIt = NO;
    
    LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    if (loginItems) {
        UInt32 seed = 0U;
        NSArray *currentLoginItems = (__bridge NSArray *)(LSSharedFileListCopySnapshot(loginItems, &seed));
        for (id itemObject in currentLoginItems) {
            LSSharedFileListItemRef item = (__bridge LSSharedFileListItemRef)itemObject;
            
            UInt32 resolutionFlags = kLSSharedFileListNoUserInteraction | kLSSharedFileListDoNotMountVolumes;
            CFURLRef URL = NULL;
            OSStatus err = LSSharedFileListItemResolve(item, resolutionFlags, &URL, NULL);
            if (err == noErr) {
                foundIt = (BOOL)CFEqual(URL, (__bridge CFTypeRef)(bundleURL));
                CFRelease(URL);
                
                if (foundIt)
                    break;
            }
        }
        CFRelease(loginItems);
    }
    return foundIt;
}

@end
