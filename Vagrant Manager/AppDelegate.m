//
//  AppDelegate.m
//  Vagrant Manager
//
//  Created by Amitai Lanciano on 1/7/14.
//  Copyright (c) 2014 Amitai Lanciano. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    NSBundle *bundle = [NSBundle mainBundle];
    
    statusImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"vagrant_logo" ofType:@"png"]];
    statusHighlightImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"vagrant_logo_highlighted" ofType:@"png"]];
    
    [statusItem setImage:statusImage];
    [statusItem setAlternateImage:statusHighlightImage];
    [statusItem setMenu:statusMenu];
    [statusItem setHighlightMode:YES];
    [statusMenu setDelegate:self];
}

- (void)menuWillOpen:(NSMenu *)menu {
    NSBundle *bundle = [NSBundle mainBundle];
    [menu removeAllItems];
    
    //get running vms
    NSTask *runningVmsTask = [[NSTask alloc] init];
    [runningVmsTask setLaunchPath:@"/bin/sh"];
    [runningVmsTask setArguments:@[@"-c", @"vboxmanage list runningvms | grep -iEo '\".*\"' | sed -e 's/\"//g'"]];
    
    NSPipe *runningVmsOutputPipe = [NSPipe pipe];
    [runningVmsTask setStandardInput:[NSPipe pipe]];
    [runningVmsTask setStandardOutput:runningVmsOutputPipe];
    
    [runningVmsTask launch];
    [runningVmsTask waitUntilExit];
    
    NSData *runningVmsOutputData = [[runningVmsOutputPipe fileHandleForReading] readDataToEndOfFile];
    NSString *runningVmsOutputString = [[NSString alloc] initWithData:runningVmsOutputData encoding:NSUTF8StringEncoding];
    
    NSMutableArray *runningMachines = [[runningVmsOutputString componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]] mutableCopy];
    
    //get all vms
    NSTask *allVmsTask = [[NSTask alloc] init];
    [allVmsTask setLaunchPath:@"/bin/sh"];
    [allVmsTask setArguments:@[@"-c", @"vboxmanage list vms | grep -iEo '\".*\"' | sed -e 's/\"//g'"]];
    
    NSPipe *allVmsOutputPipe = [NSPipe pipe];
    [allVmsTask setStandardInput:[NSPipe pipe]];
    [allVmsTask setStandardOutput:allVmsOutputPipe];
    
    [allVmsTask launch];
    [allVmsTask waitUntilExit];
    
    NSData *allVmsOutputData = [[allVmsOutputPipe fileHandleForReading] readDataToEndOfFile];
    NSString *allVmsOutputString = [[NSString alloc] initWithData:allVmsOutputData encoding:NSUTF8StringEncoding];
    
    NSMutableArray *allMachines = [[allVmsOutputString componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]] mutableCopy];
    
    //clean up results
    [runningMachines removeObject:@""];
    [allMachines removeObject:@""];
    
    //get vagrant machine paths
    NSMutableDictionary *vagrantMachines = [[NSMutableDictionary alloc] init];
    for (NSString *machine in allMachines) {
        NSTask *allVagrantsTask = [[NSTask alloc] init];
        [allVagrantsTask setLaunchPath:@"/bin/sh"];
        [allVagrantsTask setArguments:@[@"-c", [NSString stringWithFormat:@"vboxmanage showvminfo \"%@\" | grep 'Name:.*' | grep -iEo \"'[^']*'\"", machine]]];
        
        NSPipe *allVagrantsOutputPipe = [NSPipe pipe];
        [allVagrantsTask setStandardInput:[NSPipe pipe]];
        [allVagrantsTask setStandardOutput:allVagrantsOutputPipe];
        
        [allVagrantsTask launch];
        [allVagrantsTask waitUntilExit];
        
        NSData *allVagrantsOutputData = [[allVagrantsOutputPipe fileHandleForReading] readDataToEndOfFile];
        NSString *allVagrantsOutputString = [[NSString alloc] initWithData:allVagrantsOutputData encoding:NSUTF8StringEncoding];
        allVagrantsOutputString = [allVagrantsOutputString stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        NSMutableArray *allVagrantsOutputStringArr = [[allVagrantsOutputString componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]] mutableCopy];
        
        [allVagrantsOutputStringArr removeObject:@""];
        
        if ([allVagrantsOutputStringArr count] == 2) {
            if ([[allVagrantsOutputStringArr objectAtIndex:0] isEqualToString:@"'/vagrant'"]) {
                [vagrantMachines setObject:[allVagrantsOutputStringArr objectAtIndex:1] forKey:machine];
            }
        }
        
    }
    
    //remove running machines from all machines list
    for(NSString *machine in runningMachines) {
        if([allMachines containsObject:machine]) {
            [allMachines removeObject:machine];
        }
    }
    
    for (NSString *machine in runningMachines) {
        if ([vagrantMachines objectForKey:machine]) {
            NSMenuItem *menuItem = [[NSMenuItem alloc] init];
            [menuItem setTitle:machine];
            [menuItem setImage:[[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"on" ofType:@"png"]]];
            [statusMenu addItem:menuItem];
            
            NSMenu *submenu = [statusSubMenuTemplate copy];
            
            NSMenuItem *vagrantHalt = [submenu itemWithTitle:@"vagrant halt"];
            [vagrantHalt setToolTip:[vagrantMachines objectForKey:machine]]; //lazy
            [vagrantHalt setAction:@selector(vagrantHalt:)];
            
            NSMenuItem *vagrantDestroy = [submenu itemWithTitle:@"vagrant destroy"];
            [vagrantDestroy setToolTip:[vagrantMachines objectForKey:machine]]; //lazy
            [vagrantDestroy setAction:@selector(vagrantDestroy:)];
            
            [statusMenu setSubmenu:submenu forItem:menuItem];
        }
    }
    
    for (NSString *machine in allMachines) {
        if ([vagrantMachines objectForKey:machine]) {
            NSMenuItem *menuItem = [[NSMenuItem alloc] init];
            [menuItem setTitle:machine];
            [menuItem setImage:[[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"off" ofType:@"png"]]];
            [statusMenu addItem:menuItem];
            
            NSMenu *submenu = [statusSubMenuTemplate copy];
            
            NSMenuItem *vagrantUp = [submenu itemWithTitle:@"vagrant up"];
            [vagrantUp setToolTip:[vagrantMachines objectForKey:machine]]; //lazy
            [vagrantUp setAction:@selector(vagrantUp:)];
            
            NSMenuItem *vagrantDestroy = [submenu itemWithTitle:@"vagrant destroy"];
            [vagrantDestroy setToolTip:[vagrantMachines objectForKey:machine]]; //lazy
            [vagrantDestroy setAction:@selector(vagrantDestroy:)];
            [statusMenu setSubmenu:submenu forItem:menuItem];
        }
    }
    
    NSMenuItem *menuItem = [[NSMenuItem alloc] init];
    [menuItem setTitle:@"Quit"];
    [menuItem setAction:@selector(terminate:)];
    [statusMenu addItem:menuItem];
    
}

- (void)runVagrantCommand:directory :command {
    
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/sh"];
    [task setArguments:@[@"-c", [NSString stringWithFormat:@"cd %@ && %@", directory, command]]];
    
    NSPipe *taskOutputPipe = [NSPipe pipe];
    [task setStandardInput:[NSPipe pipe]];
    [task setStandardOutput:taskOutputPipe];
    [task setStandardError:taskOutputPipe];
    
    [task launch];
    [task waitUntilExit];
    
    NSData *taskOutputData = [[taskOutputPipe fileHandleForReading] readDataToEndOfFile];
    NSString *taskOutputString = [[NSString alloc] initWithData:taskOutputData encoding:NSUTF8StringEncoding];
    
    if([task terminationStatus] != 0) {
        [[NSAlert alertWithMessageText:@"Vagrant Manager Error:" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"%@",taskOutputString] runModal];
    }

}

- (void)vagrantUp:(id)sender {
    sender = (NSMenuItem*)sender;
    [self runVagrantCommand:[sender toolTip] :@"vagrant up"];
}

- (void) vagrantHalt:(id)sender {
    sender = (NSMenuItem*)sender;
    [self runVagrantCommand:[sender toolTip] :@"vagrant halt"];
}

- (void) vagrantDestroy:(id)sender {
    sender = (NSMenuItem*)sender;
    [self runVagrantCommand:[sender toolTip] :@"vagrant destroy -f"];
}


@end
