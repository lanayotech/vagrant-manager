//
//  AddBookmarkWindow.h
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AddBookmarkWindow : NSWindowController

@property (weak) IBOutlet NSTextField *directoryTextField;
@property (weak) IBOutlet NSTextField *displayNameTextField;

- (IBAction)chooseDirectoryButtonClicked:(id)sender;
- (IBAction)cancelButtonClicked:(id)sender;
- (IBAction)addBookmarkButtonClicked:(id)sender;

@end
