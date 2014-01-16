//
//  OutputWindow.h
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "VirtualMachineInfo.h"
#import "Bookmark.h"

@interface TaskOutputWindow : NSWindowController <NSWindowDelegate>

@property (strong, nonatomic) VirtualMachineInfo *machine;
@property (strong, nonatomic) Bookmark *bookmark;
@property (strong, nonatomic) NSString *taskCommand;
@property (strong, nonatomic) NSString *taskAction;
@property (strong, nonatomic) NSTask *task;

@property (unsafe_unretained) IBOutlet NSTextView *outputTextView;
@property (weak) IBOutlet NSProgressIndicator *progressBar;
@property (weak) IBOutlet NSTextField *taskCommandLabel;
@property (weak) IBOutlet NSTextField *taskStatusLabel;
@property (weak) IBOutlet NSButton *closeWindowButton;

- (IBAction)closeButtonClicked:(id)sender;

@end
