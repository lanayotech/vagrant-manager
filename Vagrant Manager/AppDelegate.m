//
//  AppDelegate.m
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

#pragma mark - Application events

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSBundle *bundle = [NSBundle mainBundle];

    //initialize data
    taskOutputWindows = [[NSMutableArray alloc] init];
    infoWindows = [[NSMutableArray alloc] init];
    detectedVagrantMachines = [[NSMutableArray alloc] init];
    
    //create status bar menu item
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setImage:[[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"vagrant_logo" ofType:@"png"]]];
    [statusItem setAlternateImage:[[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"vagrant_logo_highlighted" ofType:@"png"]]];
    [statusItem setMenu:statusMenu];
    [statusItem setHighlightMode:YES];
    
    [statusMenu setDelegate:self];
    
    [self rebuildMenu];
    [self detectVagrantMachines];
}

- (void)menuWillOpen:(NSMenu *)menu {
    if(menu == statusMenu) {
        @synchronized(detectedVagrantMachines) {
            detectedVagrantMachines = [self sortVirtualMachines:detectedVagrantMachines];
        }
        [self rebuildMenu];
    }
}

#pragma mark - Vagrant machine control

- (void)runVagrantAction:(NSString*)action withMachine:(VirtualMachineInfo*)machine {
    NSString *command;
    
    if([action isEqualToString:@"up"]) {
        command = @"vagrant up";
    } else if([action isEqualToString:@"halt"]) {
        command = @"vagrant halt";
    } else if([action isEqualToString:@"destroy"]) {
        command = @"vagrant destroy -f";
    }
    
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/sh"];
    
    NSString *taskCommand = [NSString stringWithFormat:@"cd '%@' && %@", [machine getSharedFolderPathWithName:@"/vagrant"], command];
    
    [task setArguments:@[@"-c", taskCommand]];
    
    TaskOutputWindow *outputWindow = [[TaskOutputWindow alloc] initWithWindowNibName:@"TaskOutputWindow"];
    outputWindow.task = task;
    outputWindow.taskCommand = taskCommand;
    outputWindow.machine = machine;
    
    [NSApp activateIgnoringOtherApps:YES];
    [outputWindow showWindow:self];
    
    [taskOutputWindows addObject:outputWindow];
}

#pragma mark - Menu management

- (void)rebuildMenu {
    NSBundle *bundle = [NSBundle mainBundle];

    [statusMenu removeAllItems];
    
    //add bookmarks
    NSMenuItem *i = [[NSMenuItem alloc] init];
    [i setTitle:@"Bookmarks"];
    [i setEnabled:NO];
    [statusMenu addItem:i];
    
    if(!bookmarksSeparatorMenuItem) {
        bookmarksSeparatorMenuItem = [NSMenuItem separatorItem];
    }
    [statusMenu addItem:bookmarksSeparatorMenuItem];
    
    //add detected
    if(detectedVagrantMachines && [detectedVagrantMachines count] > 0) {
        @synchronized(detectedVagrantMachines) {
            for(VirtualMachineInfo *machine in detectedVagrantMachines) {
                i = [[NSMenuItem alloc] init];
                [i setTitle:machine.name];
                
                [i setEnabled:YES];
                [i setImage:[[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:[machine isRunning]?@"on":@"off" ofType:@"png"]]];
                [i setTag:MenuItemDetected];
                [i setRepresentedObject:machine];
                
                [statusMenu addItem:i];
                
                NSMenu *submenu = [statusSubMenuTemplate copy];
                
                if(machine.isRunning) {
                    NSMenuItem *vagrantUp = [submenu itemWithTag:0];
                    [vagrantUp setEnabled:NO];
                    
                    NSMenuItem *vagrantHalt = [submenu itemWithTag:1];
                    [vagrantHalt setAction:@selector(vagrantHaltMenuItemClicked:)];
                } else {
                    NSMenu *submenu = [statusSubMenuTemplate copy];
                    
                    NSMenuItem *vagrantUp = [submenu itemWithTag:0];
                    [vagrantUp setAction:@selector(vagrantUpMenuItemClicked:)];
                    
                    NSMenuItem *vagrantHalt = [submenu itemWithTag:1];
                    [vagrantHalt setEnabled:NO];
                }
                
                NSMenuItem *vagrantDestroy = [submenu itemWithTag:2];
                [vagrantDestroy setAction:@selector(vagrantDestroyMenuItemClicked:)];

                NSMenuItem *virtualMachineDetails = [submenu itemWithTag:3];
                [virtualMachineDetails setAction:@selector(virtualMachineDetailsMenuItemClicked:)];
                
                [statusMenu setSubmenu:submenu forItem:i];
            }
        }
    } else {
        i = [[NSMenuItem alloc] init];
        [i setTitle:@"No detected VMs"];
        [i setTag:MenuItemDetected];
        [i setEnabled:NO];
        [statusMenu addItem:i];
    }
    
    if(!refreshDetectedMenuItem) {
        refreshDetectedMenuItem = [[NSMenuItem alloc] init];
        [refreshDetectedMenuItem setTitle:@"Refresh Detected VMs"];
        [refreshDetectedMenuItem setAction:@selector(refreshDetectedMenuItemClicked:)];
    }
    [statusMenu addItem:refreshDetectedMenuItem];
    
    if(!detectedSeparatorMenuItem) {
        detectedSeparatorMenuItem = [NSMenuItem separatorItem];
    }
    [statusMenu addItem:detectedSeparatorMenuItem];
    
    //add static items
    if(!preferencesMenuItem) {
        preferencesMenuItem = [[NSMenuItem alloc] init];
        [preferencesMenuItem setTitle:@"Preferences"];
    }
    [statusMenu addItem:preferencesMenuItem];

    if(!aboutMenuItem) {
        aboutMenuItem = [[NSMenuItem alloc] init];
        [aboutMenuItem setTitle:@"About"];
        [aboutMenuItem setAction:@selector(aboutMenuItemClicked:)];
    }
    [statusMenu addItem:aboutMenuItem];

    if(!quitMenuItem) {
        quitMenuItem = [[NSMenuItem alloc] init];
        [quitMenuItem setTitle:@"Quit"];
        [quitMenuItem setAction:@selector(terminate:)];
    }
    [statusMenu addItem:quitMenuItem];
    
    int runningCount = [self getRunningVmCount];
    if(runningCount > 0 ) {
        [statusItem setTitle:[NSString stringWithFormat:@"%d", runningCount]];
    } else {
        [statusItem setTitle:@""];
    }
}

- (void)removeDetectedMenuItems {
    while(true) {
        NSMenuItem *i = [statusMenu itemWithTag:MenuItemDetected];
        if(!i) {
            break;
        }
        [statusMenu removeItem:i];
    };
}

#pragma mark - Menu Item Handlers

- (IBAction)refreshDetectedMenuItemClicked:(id)sender {
    [self detectVagrantMachines];
}

- (IBAction)aboutMenuItemClicked:(id)sender {
    aboutWindow = [[AboutWindow alloc] initWithWindowNibName:@"AboutWindow"];
    [aboutWindow showWindow:self];
}


- (void)vagrantUpMenuItemClicked:(NSMenuItem*)menuItem {
    VirtualMachineInfo *machine = [menuItem parentItem].representedObject;
    [self runVagrantAction:@"up" withMachine:machine];
}

- (void)vagrantHaltMenuItemClicked:(NSMenuItem*)menuItem {
    VirtualMachineInfo *machine = [menuItem parentItem].representedObject;
    [self runVagrantAction:@"halt" withMachine:machine];
}

- (void)vagrantDestroyMenuItemClicked:(NSMenuItem*)menuItem {
    VirtualMachineInfo *machine = [menuItem parentItem].representedObject;
    
    NSAlert *confirmAlert = [NSAlert alertWithMessageText:[NSString stringWithFormat:@"Are you sure you want to destroy \"%@\"?", machine.name] defaultButton:@"Confirm" alternateButton:@"Cancel" otherButton:nil informativeTextWithFormat:@""];
    NSInteger button = [confirmAlert runModal];
    
    if(button == NSAlertDefaultReturn) {
        [self runVagrantAction:@"destroy" withMachine:machine];
    }
}

- (void)virtualMachineDetailsMenuItemClicked:(NSMenuItem*)menuItem {
    VirtualMachineInfo *machine = [menuItem parentItem].representedObject;
    VirtualMachineInfoWindow *infoWindow = [[VirtualMachineInfoWindow alloc] initWithWindowNibName:@"VirtualMachineInfoWindow"];
    infoWindow.machine = machine;
    [NSApp activateIgnoringOtherApps:YES];
    [infoWindow showWindow:self];

    [infoWindows addObject:infoWindow];
}

#pragma mark - General Functions

- (void)removeOutputWindow:(TaskOutputWindow*)outputWindow {
    [taskOutputWindows removeObject:outputWindow];
}

- (void)removeInfoWindow:(VirtualMachineInfoWindow*)infoWindow {
    [infoWindows removeObject:infoWindow];
}

#pragma mark - Virtual Machines

- (VirtualMachineInfo*)getVirtualMachineInfo:(NSString*)uuid {
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/sh"];
    [task setArguments:@[@"-c", [NSString stringWithFormat:@"vboxmanage showvminfo %@ --machinereadable", uuid]]];
    
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardInput:[NSPipe pipe]];
    [task setStandardOutput:pipe];
    
    [task launch];
    [task waitUntilExit];
    
    NSData *outputData = [[pipe fileHandleForReading] readDataToEndOfFile];
    NSString *outputString = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
    
    if(task.terminationStatus != 0) {
        return nil;
    }

    VirtualMachineInfo *vmInfo = [VirtualMachineInfo fromInfo:outputString];
    
    return vmInfo;
}

- (NSArray*)getAllVirtualMachinesInfo {
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/sh"];
    [task setArguments:@[@"-c", @"vboxmanage list vms | awk '{ print $NF }' | sed -e 's/[{}]//g'"]];
    
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardInput:[NSPipe pipe]];
    [task setStandardOutput:pipe];
    
    [task launch];
    [task waitUntilExit];
    
    NSData *outputData = [[pipe fileHandleForReading] readDataToEndOfFile];
    NSString *outputString = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
    
    NSMutableArray *vmUuids = [[outputString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] mutableCopy];
    [vmUuids removeObject:@""];
    
    NSMutableArray *virtualMachines = [[NSMutableArray alloc] init];
    
    for(NSString *uuid in vmUuids) {
        VirtualMachineInfo *vmInfo = [self getVirtualMachineInfo:uuid];
        if(vmInfo) {
            [virtualMachines addObject:vmInfo];
        }
    }
    
    return [NSArray arrayWithArray:virtualMachines];
}

- (void)updateVirtualMachineState:(VirtualMachineInfo*)machine {
    VirtualMachineInfo *info = [self getVirtualMachineInfo:machine.uuid];
    if(info) {
        machine.state = info.state;
        [self rebuildMenu];
    }
}

- (int)getRunningVmCount {
    int runningCount = 0;
    for(VirtualMachineInfo *machine in detectedVagrantMachines) {
        if(machine.isRunning) {
            ++runningCount;
        }
    }
    
    return runningCount;
}

- (NSMutableArray*)sortVirtualMachines:(NSArray*)virtualMachines {
    //sort alphabetically with running machines at the top
    return [[virtualMachines sortedArrayUsingComparator:^(id obj1, id obj2) {
        if ([obj1 isKindOfClass:[VirtualMachineInfo class]] && [obj2 isKindOfClass:[VirtualMachineInfo class]]) {
            VirtualMachineInfo *m1 = obj1;
            VirtualMachineInfo *m2 = obj2;
            
            if ([m1 isRunning] && ![m2 isRunning]) {
                return (NSComparisonResult)NSOrderedAscending;
            } else if (m2.isRunning && !m1.isRunning) {
                return (NSComparisonResult)NSOrderedDescending;
            }
            
            return [m1.name caseInsensitiveCompare:m2.name];
        }
        
        return NSOrderedSame;
    }] mutableCopy];
}

- (void)detectVagrantMachines {
    [self removeDetectedMenuItems];
    
    NSMenuItem *i = [[NSMenuItem alloc] init];
    [i setTitle:@"Refreshing..."];
    [i setEnabled:NO];
    [i setTag:MenuItemDetected];
    [statusMenu insertItem:i atIndex:[statusMenu indexOfItem:refreshDetectedMenuItem]];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //detect all VMs
        NSArray *virtualMachines = [self getAllVirtualMachinesInfo];
        
        //filter only vagrant machines
        NSMutableArray *vagrantMachines = [[NSMutableArray alloc] init];
        for(VirtualMachineInfo *vmInfo in virtualMachines) {
            if([vmInfo getSharedFolderPathWithName:@"/vagrant"]) {
                [vagrantMachines addObject:vmInfo];
            }
        }
        
        vagrantMachines = [self sortVirtualMachines:vagrantMachines];
        
        @synchronized(detectedVagrantMachines) {
            detectedVagrantMachines = vagrantMachines;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self rebuildMenu];
        });
    });
}

@end
