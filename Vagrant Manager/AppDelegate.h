//
//  AppDelegate.h
//  Vagrant Manager
//
//  Created by Amitai Lanciano on 1/7/14.
//  Copyright (c) 2014 Amitai Lanciano. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, NSMenuDelegate> {
    IBOutlet NSMenu *statusMenu;
    IBOutlet NSMenu *statusSubMenuTemplate;
    
    NSStatusItem *statusItem;
    NSImage *statusImage;
    NSImage *statusHighlightImage;
}

@property (assign) IBOutlet NSWindow *window;

- (void)runVagrantCommand:(NSString*)directory :(NSString*)command;
- (void)menuWillOpen:(NSMenu *)menu;
- (IBAction)vagrantUp:(id)sender;
- (IBAction)vagrantHalt:(id)sender;
- (IBAction)vagrantDestroy:(id)sender;

@end
