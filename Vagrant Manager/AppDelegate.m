//
//  AppDelegate.m
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import "AppDelegate.h"
#import "Environment.h"
#import "VersionComparison.h"
#import "VagrantInstance.h"
#import "BookmarkManager.h"
#import "CustomCommandManager.h"

@implementation AppDelegate {
    BOOL isRefreshingVagrantMachines;
    
    VagrantManager *_manager;
    NativeMenu *_nativeMenu;
    NSMutableArray *openWindows;
    
    int queuedRefreshes;
}

#pragma mark - Application events

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    //initialize data
    openWindows = [[NSMutableArray alloc] init];
    
    //register notification listeners
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(taskCompleted:) name:@"vagrant-manager.task-completed" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeChanged:) name:@"vagrant-manager.theme-changed" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showRunningVmCountPreferenceChanged:) name:@"vagrant-manager.show-running-vm-count-preference-changed" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(usePathAsInstanceDisplayNamePreferenceChanged:) name:@"vagrant-manager.use-path-as-instance-display-name-preference-changed" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(includeMachineNamesInMenuPreferenceChanged:) name:@"vagrant-manager.include-machine-names-in-menu-preference-changed" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showUpdateNotificationPreferenceChanged:) name:@"vagrant-manager.show-update-notification-preference-changed" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bookmarksUpdated:) name:@"vagrant-manager.bookmarks-updated" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(customCommandsUpdated:) name:@"vagrant-manager.custom-commands-updated" object:nil];
    
    //register for wake from sleep notification
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(receivedWakeNotification:) name:NSWorkspaceDidWakeNotification object:NULL];
    
    //create popup and status menu item
    _nativeMenu = [[NativeMenu alloc] init];
    _nativeMenu.delegate = self;
    
    //create vagrant manager
    _manager = [VagrantManager sharedManager];
    _manager.delegate = self;
    [_manager registerServiceProvider:[[VirtualBoxServiceProvider alloc] init]];
    [_manager registerServiceProvider:[[ParallelsServiceProvider alloc] init]];
    
    [[BookmarkManager sharedManager] loadBookmarks];
    [[CustomCommandManager sharedManager] loadCustomCommands];
    
    //initialize updates
    [[SUUpdater sharedUpdater] setDelegate:self];
    [[SUUpdater sharedUpdater] setSendsSystemProfile:[Util shouldSendProfileData]];
    [[SUUpdater sharedUpdater] checkForUpdateInformation];
    
    //start initial vagrant machine detection
    [self refreshVagrantMachines];
    
    //start refresh timer if activated in preferences
    [self refreshTimerState];
}

#pragma mark - Notification handlers

- (void)receivedWakeNotification:(NSNotification*)notification {
    [self refreshVagrantMachines];
}

- (void)taskCompleted:(NSNotification*)notification {
    [self refreshVagrantMachines];
}

- (void)bookmarksUpdated:(NSNotification*)notification {
    [self refreshVagrantMachines];
}

- (void)customCommandsUpdated:(NSNotification*)notification {
    [_nativeMenu rebuildMenu];
}

- (void)themeChanged:(NSNotification*)notification {
    [self updateRunningVmCount];
}

- (void)showRunningVmCountPreferenceChanged:(NSNotification*)notification {
    [self updateRunningVmCount];
}

- (void)usePathAsInstanceDisplayNamePreferenceChanged:(NSNotification*)notification {
    [_nativeMenu rebuildMenu];
}

- (void)includeMachineNamesInMenuPreferenceChanged:(NSNotification*)notification {
    [_nativeMenu rebuildMenu];
}

- (void)showUpdateNotificationPreferenceChanged:(NSNotification*)notification {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"vagrant-manager.notification-preference-changed" object:nil];
}

#pragma mark - Vagrant manager control

- (void)refreshTimerState {
    if (self.refreshTimer) {
        [self.refreshTimer invalidate];
        self.refreshTimer = nil;
    }
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"refreshEvery"]) {
        self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:[[NSUserDefaults standardUserDefaults] integerForKey:@"refreshEveryInterval"] target:self selector:@selector(refreshVagrantMachines) userInfo:nil repeats:YES];
    }
}

- (void)refreshVagrantMachines {
    //only run if not already refreshing
    if(!isRefreshingVagrantMachines) {
        isRefreshingVagrantMachines = YES;
        //tell popup controller refreshing has started
        [[NSNotificationCenter defaultCenter] postNotificationName:@"vagrant-manager.refreshing-started" object:nil];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //tell manager to refresh all instances
            [_manager refreshInstances];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //tell popup controller refreshing has ended
                isRefreshingVagrantMachines = NO;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"vagrant-manager.refreshing-ended" object:nil];
                [self updateRunningVmCount];
                
                if(queuedRefreshes > 0) {
                    --queuedRefreshes;
                    [self refreshVagrantMachines];
                }
            });
        });
    } else {
        ++queuedRefreshes;
    }
}

#pragma mark - Vagrant Manager delegates

- (void)vagrantManager:(VagrantManager *)vagrantManger instanceAdded:(VagrantInstance *)instance {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"vagrant-manager.instance-added" object:nil userInfo:@{@"instance": instance}];
    });
}

- (void)vagrantManager:(VagrantManager *)vagrantManger instanceRemoved:(VagrantInstance *)instance {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"vagrant-manager.instance-removed" object:nil userInfo:@{@"instance": instance}];
    });
}

- (void)vagrantManager:(VagrantManager *)vagrantManger instanceUpdated:(VagrantInstance *)oldInstance withInstance:(VagrantInstance *)newInstance {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"vagrant-manager.instance-updated" object:nil userInfo:@{@"old_instance":oldInstance, @"new_instance":newInstance}];
    });
}

#pragma mark - Menu item handlers

- (void)performVagrantAction:(NSString *)action withInstance:(VagrantInstance *)instance {
    if([action isEqualToString:@"ssh"]) {
        NSString *action = [NSString stringWithFormat:@"\\cd %@; vagrant ssh", [Util escapeShellArg:instance.path]];
        [self runTerminalCommand:action];
    } else {
        [self runVagrantAction:action withInstance:instance];
    }
}

- (void)performVagrantAction:(NSString *)action withMachine:(VagrantMachine *)machine {
    if([action isEqualToString:@"ssh"]) {
        NSString *action = [NSString stringWithFormat:@"\\cd %@; vagrant ssh %@", [Util escapeShellArg:machine.instance.path], machine.name];
        [self runTerminalCommand:action];
    } else {
        [self runVagrantAction:action withMachine:machine];
    }
}

- (void)performCustomCommand:(CustomCommand *)customCommand withInstance:(VagrantInstance *)instance {
    for(VagrantMachine *machine in instance.machines) {
        if(machine.state == RunningState) {
            if(customCommand.runInTerminal) {
                NSString *action = [NSString stringWithFormat:@"\\cd %@; vagrant ssh %@ -c %@", [Util escapeShellArg:instance.path], [Util escapeShellArg:machine.name], [Util escapeShellArg:customCommand.command]];
                [self runTerminalCommand:action];
            } else {
                [self runVagrantCustomCommand:customCommand.command withMachine:machine];
            }
        }
    }
}

- (void)performCustomCommand:(CustomCommand *)customCommand withMachine:(VagrantMachine *)machine {
    if(customCommand.runInTerminal) {
        NSString *action = [NSString stringWithFormat:@"\\cd %@; vagrant ssh %@ -c %@", [Util escapeShellArg:machine.instance.path], [Util escapeShellArg:machine.name], [Util escapeShellArg:customCommand.command]];
        [self runTerminalCommand:action];
    } else {
        [self runVagrantCustomCommand:customCommand.command withMachine:machine];
    }
}

- (void)openInstanceInFinder:(VagrantInstance *)instance {
    NSString *path = instance.path;
    
    BOOL isDir = NO;
    if([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir] && isDir) {
        NSURL *fileURL = [NSURL fileURLWithPath:path];
        [[NSWorkspace sharedWorkspace] openURL:fileURL];
    } else {
        [[NSAlert alertWithMessageText:[NSString stringWithFormat:@"Path not found: %@", path] defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@""] runModal];
    }
}

- (void)openInstanceInTerminal:(VagrantInstance *)instance {
    NSString *path = instance.path;
    
    BOOL isDir = NO;
    if([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir] && isDir) {
        [self runTerminalCommand:[NSString stringWithFormat:@"\\cd %@", [Util escapeShellArg:path]]];
    } else {
        [[NSAlert alertWithMessageText:[NSString stringWithFormat:@"Path not found: %@", path] defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@""] runModal];
    }
}

- (void)addBookmarkWithInstance:(VagrantInstance *)instance {
    [[BookmarkManager sharedManager] addBookmarkWithPath:instance.path displayName:instance.displayName providerIdentifier:instance.providerIdentifier];
    [[BookmarkManager sharedManager] saveBookmarks];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"vagrant-manager.bookmarks-updated" object:nil];
}

- (void)removeBookmarkWithInstance:(VagrantInstance *)instance {
    [[BookmarkManager sharedManager] removeBookmarkWithPath:instance.path];
    [[BookmarkManager sharedManager] saveBookmarks];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"vagrant-manager.bookmarks-updated" object:nil];
}

#pragma mark - Vagrant Machine control

- (void)runVagrantCustomCommand:(NSString*)command withMachine:(VagrantMachine*)machine {
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/bash"];
    
    NSString *taskCommand = [NSString stringWithFormat:@"\\cd %@; vagrant ssh %@ -c %@", [Util escapeShellArg:machine.instance.path], [Util escapeShellArg:machine.name], [Util escapeShellArg:command]];
    
    [task setArguments:@[@"-c", taskCommand]];
    
    TaskOutputWindow *outputWindow = [[TaskOutputWindow alloc] initWithWindowNibName:@"TaskOutputWindow"];
    outputWindow.task = task;
    outputWindow.taskCommand = taskCommand;
    outputWindow.target = machine;
    outputWindow.taskAction = command;
    
    [NSApp activateIgnoringOtherApps:YES];
    [outputWindow showWindow:self];

    [self addOpenWindow:outputWindow];
}

- (void)runVagrantAction:(NSString*)action withMachine:(VagrantMachine*)machine {
    NSString *command;
    
    if([action isEqualToString:@"up"]) {
        command = [NSString stringWithFormat:@"vagrant up%@", machine.instance.providerIdentifier ? [NSString stringWithFormat:@" --provider=%@", machine.instance.providerIdentifier] : @""];
    } else if([action isEqualToString:@"reload"]) {
        command = @"vagrant reload";
    } else if([action isEqualToString:@"suspend"]) {
        command = @"vagrant suspend";
    } else if([action isEqualToString:@"halt"]) {
        command = @"vagrant halt";
    } else if([action isEqualToString:@"provision"]) {
        command = @"vagrant provision";
    } else if([action isEqualToString:@"destroy"]) {
        command = @"vagrant destroy -f";
    } else {
        return;
    }
    
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/bash"];
    
    NSString *taskCommand = [NSString stringWithFormat:@"\\cd %@; %@ %@", [Util escapeShellArg:machine.instance.path], command, [Util escapeShellArg:machine.name]];
    
    [task setArguments:@[@"-c", taskCommand]];
    
    TaskOutputWindow *outputWindow = [[TaskOutputWindow alloc] initWithWindowNibName:@"TaskOutputWindow"];
    outputWindow.task = task;
    outputWindow.taskCommand = taskCommand;
    outputWindow.target = machine;
    outputWindow.taskAction = command;
    
    [NSApp activateIgnoringOtherApps:YES];
    [outputWindow showWindow:self];
    
    [self addOpenWindow:outputWindow];
}

- (void)runVagrantAction:(NSString*)action withInstance:(VagrantInstance*)instance {
    NSString *command;
    
    if([action isEqualToString:@"up"]) {
        command = [NSString stringWithFormat:@"vagrant up%@", instance.providerIdentifier ? [NSString stringWithFormat:@" --provider=%@", instance.providerIdentifier] : @""];
    } else if([action isEqualToString:@"reload"]) {
        command = @"vagrant reload";
    } else if([action isEqualToString:@"suspend"]) {
        command = @"vagrant suspend";
    } else if([action isEqualToString:@"halt"]) {
        command = @"vagrant halt";
    } else if([action isEqualToString:@"provision"]) {
        command = @"vagrant provision";
    } else if([action isEqualToString:@"destroy"]) {
        command = @"vagrant destroy -f";
    } else {
        return;
    }
    
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/bash"];
    
    NSString *taskCommand = [NSString stringWithFormat:@"\\cd %@; %@", [Util escapeShellArg:instance.path], command];
    
    [task setArguments:@[@"-c", @"-l", taskCommand]];
    
    TaskOutputWindow *outputWindow = [[TaskOutputWindow alloc] initWithWindowNibName:@"TaskOutputWindow"];
    outputWindow.task = task;
    outputWindow.taskCommand = taskCommand;
    outputWindow.target = instance;
    outputWindow.taskAction = command;
    
    [NSApp activateIgnoringOtherApps:YES];
    [outputWindow showWindow:self];
    
    [self addOpenWindow:outputWindow];
}

- (void)runTerminalCommand:(NSString*)command {
    NSString *terminalName = [[NSUserDefaults standardUserDefaults] valueForKey:@"terminalPreference"];
    
    command = [command stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    command = [command stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    
    NSString *s;
    if ([terminalName isEqualToString:@"iTerm"]) {
        s = [NSString stringWithFormat:@"tell application \"iTerm\"\n"
             "tell current terminal\n"
             "launch session \"Default Session\"\n"
             "delay .15\n"
             "activate\n"
             "tell the last session\n"
             "write text \"%@\"\n"
             "end tell\n"
             "end tell\n"
             "end tell\n", command];
    } else {
        s = [NSString stringWithFormat:@"tell application \"Terminal\"\n"
             "activate\n"
             "do script \"%@\"\n"
             "end tell\n", command];
    }
    
    NSAppleScript *as = [[NSAppleScript alloc] initWithSource: s];
    [as executeAndReturnError:nil];
}

#pragma mark - Window management

- (void)addOpenWindow:(id)window {
    @synchronized(openWindows) {
        [openWindows addObject:window];
        [self updateProcessType];
    }
}

- (void)removeOpenWindow:(id)window {
    @synchronized(openWindows) {
        [openWindows removeObject:window];
        [self updateProcessType];
    }
}

- (void)updateProcessType {
    if([openWindows count] == 0) {
        ProcessSerialNumber psn = { 0, kCurrentProcess };
        TransformProcessType(&psn, kProcessTransformToBackgroundApplication);
    } else {
        ProcessSerialNumber psn = { 0, kCurrentProcess };
        TransformProcessType(&psn, kProcessTransformToForegroundApplication);
        SetFrontProcess(&psn);
    }
}

- (NSImage*)getThemedImage:(NSString*)imageName {
    NSImage *image = [NSImage imageNamed:[NSString stringWithFormat:@"%@-%@", imageName, [self getCurrentTheme]]];
    [image setTemplate:YES];
    return image;
}

- (NSString*)getCurrentTheme {
    NSString *theme = [[NSUserDefaults standardUserDefaults] objectForKey:@"statusBarIconTheme"];
    
    NSArray *validThemes = @[@"clean",
                           @"flat"];

    if(!theme) {
        theme = @"clean";
        [[NSUserDefaults standardUserDefaults] setValue:theme forKey:@"statusBarIconTheme"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else if(![validThemes containsObject:theme]) {
        theme = @"clean";
    }

    return theme;
}

- (void)updateRunningVmCount {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"vagrant-manager.update-running-vm-count" object:nil userInfo:@{@"count": [NSNumber numberWithInt:[_manager getRunningVmCount]]}];
}

#pragma mark - Notification center

- (void)showUserNotificationWithTitle:(NSString*)title informativeText:(NSString*)informativeText taskWindowUUID:(NSString*)taskWindowUUID {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"showTaskNotification"]) {
        return;
    }
    
    //show user notification
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = title;
    notification.informativeText = informativeText;
    if (taskWindowUUID) {
        notification.userInfo = @{@"taskWindowUUID": taskWindowUUID};
    }
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification {
    return YES;
}

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification {
    if(notification.userInfo && [notification.userInfo objectForKey:@"taskWindowUUID"]) {
        NSString *taskWindowUUID = [notification.userInfo objectForKey:@"taskWindowUUID"];
        NSArray *windows;
        
        @synchronized(openWindows) {
            windows = [NSArray arrayWithArray:openWindows];
        }
        
        //find task output window that posted this notification
        for(id window in windows) {
            if([window isKindOfClass:[TaskOutputWindow class]]) {
                TaskOutputWindow *taskOutputWindow = window;
                
                if([taskOutputWindow.windowUUID isEqualToString:taskWindowUUID]) {
                    if([taskOutputWindow.window isVisible]) {
                        //show task output window
                        [NSApp activateIgnoringOtherApps:YES];
                        [taskOutputWindow.window makeKeyAndOrderFront:self];
                        [taskOutputWindow.window setOrderedIndex:0];
                    }
                }
            }
        }
    }
}

#pragma mark - Sparkle updater delegates

- (NSArray*)feedParametersForUpdater:(SUUpdater *)updater sendingSystemProfile:(BOOL)sendingProfile {
    NSMutableArray *data = [[NSMutableArray alloc] init];
    [data addObject:@{@"key": @"machineid", @"value": [Util getMachineId]}];
    [data addObject:@{@"key": @"appversion", @"value": [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]}];
    if(sendingProfile) {
        [data addObject:@{@"key": @"profile", @"value": @"1"}];
    }

    return data;
}

- (void)updater:(SUUpdater *)updater didFindValidUpdate:(SUAppcastItem *)update {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"dontShowUpdateNotification"]) {
         [[NSNotificationCenter defaultCenter] postNotificationName:@"vagrant-manager.update-available" object:nil userInfo:@{@"is_update_available": [NSNumber numberWithBool:YES]}];
    }
}

- (void)updaterDidNotFindUpdate:(SUUpdater *)update {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"vagrant-manager.update-available" object:nil userInfo:@{@"is_update_available": [NSNumber numberWithBool:NO]}];
}

- (id<SUVersionComparison>)versionComparatorForUpdater:(SUUpdater *)updater {
    return [[VersionComparison alloc] init];
}

- (SUAppcastItem *)bestValidUpdateInAppcast:(SUAppcast *)appcast forUpdater:(SUUpdater *)bundle {
    SUAppcastItem *bestItem = nil;
    
    NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    
    for(SUAppcastItem *item in [appcast items]) {
        if([Util compareVersion:appVersion toVersion:item.versionString] == NSOrderedAscending) {
            if([Util getUpdateStabilityScore:[Util getVersionStability:item.versionString]] <= [Util getUpdateStabilityScore:[Util getUpdateStability]]) {
                if(!bestItem || [Util compareVersion:bestItem.versionString toVersion:item.versionString] == NSOrderedAscending) {
                    bestItem = item;
                }
            }
        }
    }
    
    return bestItem;
}

@end
