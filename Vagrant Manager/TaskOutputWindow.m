//
//  OutputWindow.m
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import "TaskOutputWindow.h"
#import "AppDelegate.h"

@interface TaskOutputWindow () {
    BOOL _isClosed;
}

@end

@implementation TaskOutputWindow

- (id)initWithWindow:(NSWindow *)window {
    self = [super initWithWindow:window];
    
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    self.windowUUID = (__bridge_transfer NSString *)CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    
    NSPipe *taskOutputPipe = [NSPipe pipe];
	[self.task setStandardInput:[NSFileHandle fileHandleWithNullDevice]];
    [self.task setStandardOutput:taskOutputPipe];
    [self.task setStandardError:taskOutputPipe];

    //set up Askpass handler for sudo
	NSString *askPassPath = [NSBundle pathForResource:@"Askpass" ofType:@"" inDirectory:[[NSBundle mainBundle] bundlePath]];
    NSMutableDictionary *env = [[[NSProcessInfo processInfo] environment] mutableCopy];
    [env setObject:@"NONE" forKey:@"DISPLAY"];
    [env setObject:askPassPath forKey:@"SUDO_ASKPASS"];
    [self.task setEnvironment:env];
    
    NSFileHandle *fh = [taskOutputPipe fileHandleForReading];
    [fh waitForDataInBackgroundAndNotify];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedOutput:) name:NSFileHandleDataAvailableNotification object:fh];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(taskCompletion:) name: NSTaskDidTerminateNotification object:self.task];
    
    NSString *name = [self.target isKindOfClass:[VagrantMachine class]] ? [NSString stringWithFormat:@"%@ - %@",((VagrantMachine*)self.target).instance.displayName, ((VagrantMachine*)self.target).name] : ((VagrantInstance*)self.target).displayName;
    
    self.window.title = [NSString stringWithFormat:@"%@ %@", name, self.taskAction];
    
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
    [self.cancelButton setHidden:YES];
    
    NSString *notificationText;

    if(task.terminationStatus != 0) {
        self.taskStatusLabel.stringValue = @"Completed with errors";
        notificationText = @"Task completed with errors";
        
    } else {
        self.taskStatusLabel.stringValue = @"Completed successfully";
        notificationText = @"Task completed successfully";
    }
    
    NSString *name = [self.target isKindOfClass:[VagrantMachine class]] ? [NSString stringWithFormat:@"%@ - %@",((VagrantMachine*)self.target).instance.displayName, ((VagrantMachine*)self.target).name] : ((VagrantInstance*)self.target).displayName;
    
    [[Util getApp] showUserNotificationWithTitle:notificationText informativeText:[NSString stringWithFormat:@"%@ %@", name, self.taskAction] taskWindowUUID:self.windowUUID];
    
    //notify app task is complete
    [[NSNotificationCenter defaultCenter] postNotificationName:@"vagrant-manager.task-completed" object:nil userInfo:@{@"target": self.target}];
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"autoCloseTaskWindows"] && task.terminationStatus == 0) {
        dispatch_async(dispatch_get_global_queue(0,0), ^{
            [self close];
        });
    }
}

- (void)windowWillClose:(NSNotification *)notification {
    AppDelegate *app = [Util getApp];
    
    @synchronized(self) {
        _isClosed = YES;
    }
    
    [app removeOpenWindow:self];
}

- (void)receivedOutput:(NSNotification*)notif {
    NSFileHandle *fh = [notif object];
    NSData *data = [fh availableData];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    
    @synchronized(self) {
        if (!_isClosed) {
            //smart scrolling logic for command output
            BOOL scroll = (NSMaxY(self.outputTextView.visibleRect) == NSMaxY(self.outputTextView.bounds));
            [self.outputTextView.textStorage appendAttributedString:[[NSAttributedString alloc] initWithString:str]];
            if([NSFont fontWithName:@"Menlo" size:11]) {
                [self.outputTextView.textStorage setFont:[NSFont fontWithName:@"Menlo" size:11]];
            }
            if (scroll) {
                [self.outputTextView scrollRangeToVisible: NSMakeRange(self.outputTextView.string.length, 0)];
            }
            
            if(self.task.isRunning) {
                [fh waitForDataInBackgroundAndNotify];
            }
        }
    }
}

- (IBAction)closeButtonClicked:(id)sender {
    [self close];
}

- (IBAction)cancelButtonClicked:(id)sender {
    NSAlert *confirmAlert = [NSAlert alertWithMessageText:@"Are you sure you want to cancel the running task?" defaultButton:@"Confirm" alternateButton:@"Cancel" otherButton:nil informativeTextWithFormat:@""];
    NSInteger button = [confirmAlert runModal];
    
    if(button == NSAlertDefaultReturn) {
        [self.task interrupt];
    }
}

@end
