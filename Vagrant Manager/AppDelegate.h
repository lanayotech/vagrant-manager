//
//  AppDelegate.h
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TaskOutputWindow.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, NSMenuDelegate> {
    IBOutlet NSMenu *statusMenu;
    IBOutlet NSMenu *statusSubMenuTemplate;
    
    NSStatusItem *statusItem;
    NSImage *statusImage;
    NSImage *statusHighlightImage;
    NSMutableArray *taskOutputWindows;
}

@property (assign) IBOutlet NSWindow *window;

- (void)runVagrantCommand:(NSString*)directory :(NSString*)command;
- (void)menuWillOpen:(NSMenu *)menu;
- (IBAction)vagrantUp:(id)sender;
- (IBAction)vagrantHalt:(id)sender;
- (IBAction)vagrantDestroy:(id)sender;
- (void)removeOutputWindow:(TaskOutputWindow*)outputWindow;

@end
