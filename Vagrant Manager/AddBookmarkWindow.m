//
//  AddBookmarkWindow.m
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import "AddBookmarkWindow.h"

@interface AddBookmarkWindow ()

@end

@implementation AddBookmarkWindow

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (IBAction)cancelButtonClicked:(id)sender {
    [self close];
}

- (IBAction)addBookmarkButtonClicked:(id)sender {
    NSString *dir = [[self.directoryTextField stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *displayName = [[self.displayNameTextField stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    BOOL isDirectory = NO;
    
    if(dir.length == 0) {
        NSAlert *alert = [NSAlert alertWithMessageText:@"You must choose a directory" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@""];
        [alert runModal];
    } else if(![[NSFileManager defaultManager] fileExistsAtPath:dir isDirectory:&isDirectory] || !isDirectory) {
        NSAlert *alert = [NSAlert alertWithMessageText:@"You must choose a valid directory" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@""];
        [alert runModal];
    } else if(displayName.length == 0) {
        NSAlert *alert = [NSAlert alertWithMessageText:@"You must enter a display name" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@""];
        [alert runModal];
    } else {
        [[Util getApp] addBookmarkWithPath:dir withDisplayName:displayName];
        [[Util getApp] detectVagrantMachines];
        [self close];
    }
}

- (IBAction)chooseDirectoryButtonClicked:(id)sender {
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    
    [openDlg setCanChooseFiles:NO];
    [openDlg setCanChooseDirectories:YES];
    [openDlg setAllowsMultipleSelection:NO];
    
    [openDlg beginSheetModalForWindow:self.window completionHandler:^(NSInteger result){
        if(result == NSFileHandlingPanelOKButton) {
            NSArray *urls = [openDlg URLs];
            if(urls.count > 0) {
                NSURL *url = [urls objectAtIndex:0];
                
                [self.directoryTextField setStringValue:url.path];
                if([self.displayNameTextField.stringValue length] == 0) {
                    NSArray *parts = [url.path componentsSeparatedByString:@"/"];
                    if(parts.count > 0) {
                        [self.displayNameTextField setStringValue:[parts lastObject]];
                    }
                }
            }
        }
    }];
}

@end
