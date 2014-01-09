//
//  OutputWindow.h
//  Vagrant Manager
//
//  Created by Chris Ayoub on 1/8/14.
//  Copyright (c) 2014 Amitai Lanciano. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface OutputWindow : NSWindowController <NSWindowDelegate>

@property (strong, nonatomic) NSTask *task;

@property (unsafe_unretained) IBOutlet NSTextView *outputTextView;
@property (weak) IBOutlet NSProgressIndicator *progressBar;
@property (weak) IBOutlet NSTextField *taskStatusLabel;
@property (weak) IBOutlet NSButton *closeWindowButton;

- (IBAction)closeButtonClicked:(id)sender;

@end
