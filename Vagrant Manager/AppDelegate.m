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
}

#pragma mark - Vagrant machine control

- (void)runVagrantAction:(NSString*)action withMachine:(VagrantMachine*)machine {
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
    
    NSString *taskCommand = [NSString stringWithFormat:@"cd '%@' && %@", machine.path, command];
    
    [task setArguments:@[@"-c", taskCommand]];
    
    TaskOutputWindow *outputWindow = [[TaskOutputWindow alloc] initWithWindowNibName:@"TaskOutputWindow"];
    outputWindow.task = task;
    outputWindow.taskCommand = taskCommand;
    outputWindow.machine = machine;
    
    [NSApp activateIgnoringOtherApps:YES];
    [outputWindow showWindow:self];
    
    [taskOutputWindows addObject:outputWindow];
}

- (void)vagrantUp:(NSMenuItem*)menuItem {
    VagrantMachine *machine = [menuItem parentItem].representedObject;
    [self runVagrantAction:@"up" withMachine:machine];
}

- (void) vagrantHalt:(NSMenuItem*)menuItem {
    VagrantMachine *machine = [menuItem parentItem].representedObject;
    [self runVagrantAction:@"halt" withMachine:machine];
}

- (void) vagrantDestroy:(NSMenuItem*)menuItem {
    VagrantMachine *machine = [menuItem parentItem].representedObject;
    
    NSAlert *confirmAlert = [NSAlert alertWithMessageText:[NSString stringWithFormat:@"Are you sure you want to destroy \"%@\"?", machine.displayName] defaultButton:@"Confirm" alternateButton:@"Cancel" otherButton:nil informativeTextWithFormat:@""];
    NSInteger button = [confirmAlert runModal];
    
    if(button == NSAlertDefaultReturn) {
        [self runVagrantAction:@"destroy" withMachine:machine];
    }
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
            for(VagrantMachine *machine in detectedVagrantMachines) {
                i = [[NSMenuItem alloc] init];
                [i setTitle:machine.displayName];
                
                [i setEnabled:YES];
                [i setImage:[[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:machine.isRunning?@"on":@"off" ofType:@"png"]]];
                [i setTag:MenuItemDetected];
                [i setRepresentedObject:machine];
                
                [statusMenu addItem:i];
                
                NSMenu *submenu = [statusSubMenuTemplate copy];
                
                if(machine.isRunning) {
                    NSMenuItem *vagrantHalt = [submenu itemWithTitle:@"vagrant halt"];
                    [vagrantHalt setAction:@selector(vagrantHalt:)];
                    
                    NSMenuItem *vagrantDestroy = [submenu itemWithTitle:@"vagrant destroy"];
                    [vagrantDestroy setAction:@selector(vagrantDestroy:)];
                        
                    [statusMenu setSubmenu:submenu forItem:i];
                } else {
                    NSMenu *submenu = [statusSubMenuTemplate copy];
                    
                    NSMenuItem *vagrantUp = [submenu itemWithTitle:@"vagrant up"];
                    [vagrantUp setAction:@selector(vagrantUp:)];
                    
                    NSMenuItem *vagrantDestroy = [submenu itemWithTitle:@"vagrant destroy"];
                    [vagrantDestroy setAction:@selector(vagrantDestroy:)];
                    [statusMenu setSubmenu:submenu forItem:i];
                }
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

- (int)getRunningVmCount {
    int runningCount = 0;
    for(VagrantMachine *machine in detectedVagrantMachines) {
        if(machine.isRunning) {
            ++runningCount;
        }
    }
    
    return runningCount;
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

#pragma mark - General Functions

- (void)removeOutputWindow:(TaskOutputWindow*)outputWindow {
    [taskOutputWindows removeObject:outputWindow];
}

- (void)detectVagrantMachines {
    //TODO: more thorough checking of method to get VM names and paths
    
    [self removeDetectedMenuItems];
    
    NSMenuItem *i = [[NSMenuItem alloc] init];
    [i setTitle:@"Refreshing..."];
    [i setEnabled:NO];
    [i setTag:MenuItemDetected];
    [statusMenu insertItem:i atIndex:[statusMenu indexOfItem:refreshDetectedMenuItem]];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //detect all VMs
        NSTask *allVmsTask = [[NSTask alloc] init];
        [allVmsTask setLaunchPath:@"/bin/sh"];
        [allVmsTask setArguments:@[@"-c", @"vboxmanage list vms | grep -iEo '\".*\"' | cut -c 2- | rev | cut -c 2- | rev"]];
        
        NSPipe *allVmsOutputPipe = [NSPipe pipe];
        [allVmsTask setStandardInput:[NSPipe pipe]];
        [allVmsTask setStandardOutput:allVmsOutputPipe];
        
        [allVmsTask launch];
        [allVmsTask waitUntilExit];
        
        NSData *allVmsOutputData = [[allVmsOutputPipe fileHandleForReading] readDataToEndOfFile];
        NSString *allVmsOutputString = [[NSString alloc] initWithData:allVmsOutputData encoding:NSUTF8StringEncoding];
        
        NSMutableArray *arr = [[allVmsOutputString componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]] mutableCopy];
        
        NSMutableArray *detectedVmNames = [[NSMutableArray alloc] init];
        
        for(NSString *str in arr) {
            if([[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] > 0) {
                [detectedVmNames addObject:str];
            }
        }
        
        detectedVmNames = [[detectedVmNames sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] mutableCopy];
        
        //get running vms
        NSTask *runningVmsTask = [[NSTask alloc] init];
        [runningVmsTask setLaunchPath:@"/bin/sh"];
        [runningVmsTask setArguments:@[@"-c", @"vboxmanage list runningvms | grep -iEo '\".*\"' | cut -c 2- | rev | cut -c 2- | rev"]];
        
        NSPipe *runningVmsOutputPipe = [NSPipe pipe];
        [runningVmsTask setStandardInput:[NSPipe pipe]];
        [runningVmsTask setStandardOutput:runningVmsOutputPipe];
        
        [runningVmsTask launch];
        [runningVmsTask waitUntilExit];
        
        NSData *runningVmsOutputData = [[runningVmsOutputPipe fileHandleForReading] readDataToEndOfFile];
        NSString *runningVmsOutputString = [[NSString alloc] initWithData:runningVmsOutputData encoding:NSUTF8StringEncoding];
        
        arr = [[runningVmsOutputString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] mutableCopy];
        
        NSMutableArray *runningVmNames = [[NSMutableArray alloc] init];
        
        for(NSString *str in arr) {
            if([[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] > 0) {
                [runningVmNames addObject:str];
            }
        }
        
        runningVmNames = [[runningVmNames sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] mutableCopy];
        
        //get vagrant machine paths
        NSMutableArray *vagrantMachines = [[NSMutableArray alloc] init];
        for (NSString *machineName in detectedVmNames) {
            NSTask *getVagrantPathTask = [[NSTask alloc] init];
            [getVagrantPathTask setLaunchPath:@"/bin/sh"];
            [getVagrantPathTask setArguments:@[@"-c", [NSString stringWithFormat:@"vboxmanage showvminfo \"%@\" | grep 'Name:.*' | grep -iEo \"'[^\']*'\" | cut -c 2- | rev | cut -c 2- | rev", machineName]]];
            
            NSPipe *outputPipe = [NSPipe pipe];
            [getVagrantPathTask setStandardInput:[NSPipe pipe]];
            [getVagrantPathTask setStandardOutput:outputPipe];
            
            [getVagrantPathTask launch];
            [getVagrantPathTask waitUntilExit];
            
            NSData *outputData = [[outputPipe fileHandleForReading] readDataToEndOfFile];
            NSString *outputString = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
            outputString = [outputString stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
            NSMutableArray *outputArr = [[outputString componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]] mutableCopy];
            
            [outputArr removeObject:@""];
            
            int insertIdx = 0;
            if ([outputArr count] == 2) {
                if ([[outputArr objectAtIndex:0] isEqualToString:@"/vagrant"]) {
                    VagrantMachine *machine = [[VagrantMachine alloc] init];
                    machine.vmid = machineName;
                    machine.displayName = machineName;
                    machine.path = [outputArr objectAtIndex:1];
                    machine.isRunning = [runningVmNames containsObject:machineName];
                    
                    //TODO: need to check if it's bookmark and ignore it or set running flag on bookmarked machine
                    
                    if(machine.isRunning) {
                        [vagrantMachines insertObject:machine atIndex:insertIdx++];
                    } else {
                        [vagrantMachines addObject:machine];
                    }
                }
            }
        }
        
        vagrantMachines = [[vagrantMachines sortedArrayUsingComparator:^(id obj1, id obj2) {
            if ([obj1 isKindOfClass:[VagrantMachine class]] && [obj2 isKindOfClass:[VagrantMachine class]]) {
                VagrantMachine *m1 = obj1;
                VagrantMachine *m2 = obj2;
                
                if (m1.isRunning && !m2.isRunning) {
                    return (NSComparisonResult)NSOrderedAscending;
                } else if (m2.isRunning && !m1.isRunning) {
                    return (NSComparisonResult)NSOrderedDescending;
                }
                
                return [m1.displayName caseInsensitiveCompare:m2.displayName];
            }
            
            return NSOrderedSame;
        }] mutableCopy];
        
        @synchronized(detectedVagrantMachines) {
            detectedVagrantMachines = vagrantMachines;
        }
        
        // when that method finishes you can run whatever you need to on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            [self rebuildMenu];
        });
    });
}

@end
