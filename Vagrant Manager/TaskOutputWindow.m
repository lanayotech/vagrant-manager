//
//  OutputWindow.m
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import "TaskOutputWindow.h"
#import "AppDelegate.h"

@interface TaskOutputWindow ()

@end

@implementation TaskOutputWindow

- (id)initWithWindow:(NSWindow *)window {
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    NSPipe *taskOutputPipe = [NSPipe pipe];
    [self.task setStandardInput:[NSPipe pipe]];
    [self.task setStandardOutput:taskOutputPipe];
    [self.task setStandardError:taskOutputPipe];
    
    NSFileHandle *fh = [taskOutputPipe fileHandleForReading];
    [fh waitForDataInBackgroundAndNotify];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedOutput:) name:NSFileHandleDataAvailableNotification object:fh];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(taskCompletion:)  name: NSTaskDidTerminateNotification object:self.task];
    
    self.window.title = [NSString stringWithFormat:@"%@ %@", (self.bookmark ? self.bookmark.displayName : self.machine.name), self.taskAction];
    
    self.taskCommandLabel.stringValue = self.taskCommand;
    self.taskStatusLabel.stringValue = @"Running task...";
    [self.progressBar startAnimation:self];

    [self.task launch];
}

- (void)taskCompletion:(NSNotification*)notif {
    NSTask *task = [notif object];
    
    [self.progressBar stopAnimation:self];
    [self.progressBar setIndeterminate:NO];
    [self.progressBar setDoubleValue:self.progressBar.maxValue];
    
    NSButton *closeButton = [self.window standardWindowButton:NSWindowCloseButton];
    [closeButton setEnabled:YES];
    
    [self.closeWindowButton setEnabled:YES];

    if(task.terminationStatus != 0) {
        self.taskStatusLabel.stringValue = @"Completed with errors";
    } else {
        self.taskStatusLabel.stringValue = @"Completed successfully";
    }
    
    AppDelegate *app = [Util getApp];
    if(self.machine) {
        [app updateVirtualMachineState:self.machine];
    } else if(self.bookmark) {
        [app updateBookmarkState:self.bookmark];
    }
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"autoCloseTaskWindows"] && task.terminationStatus == 0) {
        dispatch_async(dispatch_get_global_queue(0,0), ^{
            [self close];
        });
    }
}

- (void)windowWillClose:(NSNotification *)notification {
    AppDelegate *app = [Util getApp];
    
    [app removeOutputWindow:self];
}

- (void)receivedOutput:(NSNotification*)notif {
    NSFileHandle *fh = [notif object];
    NSData *data = [fh availableData];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    
    //smart scrolling logic for command output
    BOOL scroll = (NSMaxY(self.outputTextView.visibleRect) == NSMaxY(self.outputTextView.bounds));
    [self.outputTextView.textStorage appendAttributedString:[[NSAttributedString alloc]initWithString:str]];
    if (scroll) {
        [self.outputTextView scrollRangeToVisible: NSMakeRange(self.outputTextView.string.length, 0)];
    }
    
    [fh waitForDataInBackgroundAndNotify];
}

- (IBAction)closeButtonClicked:(id)sender {
    [self close];
}

@end
