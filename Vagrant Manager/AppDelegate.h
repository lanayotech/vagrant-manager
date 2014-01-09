//
//  AppDelegate.h
//  Vagrant Manager
//
//  Created by Amitai Lanciano on 1/7/14.
//  Copyright (c) 2014 Amitai Lanciano. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OutputWindow.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, NSMenuDelegate> {
    IBOutlet NSMenu *statusMenu;
    IBOutlet NSMenu *statusSubMenuTemplate;
    
    NSStatusItem *statusItem;
    NSImage *statusImage;
    NSImage *statusHighlightImage;
    NSMutableArray *outputWindows;
}

@property (assign) IBOutlet NSWindow *window;

- (void)runVagrantCommand:(NSString*)directory :(NSString*)command;
- (void)menuWillOpen:(NSMenu *)menu;
- (IBAction)vagrantUp:(id)sender;
- (IBAction)vagrantHalt:(id)sender;
- (IBAction)vagrantDestroy:(id)sender;
- (void)removeOutputWindow:(OutputWindow*)outputWindow;

@end
