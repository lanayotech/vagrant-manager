//
//  PreferencesWindow.h
//  Vagrant Manager
//
//  Created by Amitai Lanciano on 1/16/14.
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PreferencesWindow : NSWindowController {
    
}

@property (weak) IBOutlet NSButton *autoCloseCheckBox;
@property (weak) IBOutlet NSPopUpButton *terminalPreferencePopUpButton;

- (IBAction)autoCloseCheckBoxClicked:(id)sender;
- (IBAction)terminalPreferencePopUpButtonClicked:(id)sender;

@end
