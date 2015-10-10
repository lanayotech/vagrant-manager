//
//  NativeMenuItem.h
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VagrantMachine.h"
#import "CustomCommand.h"

@class NativeMenuItem;

@protocol NativeMenuItemDelegate

- (void)nativeMenuItemUpAllMachines:(NativeMenuItem*)menuItem withProvision:(BOOL)provision;
- (void)nativeMenuItemSSHInstance:(NativeMenuItem*)menuItem;
- (void)nativeMenuItemRDPInstance:(NativeMenuItem*)menuItem;
- (void)nativeMenuItemSuspendAllMachines:(NativeMenuItem*)menuItem;
- (void)nativeMenuItemReloadAllMachines:(NativeMenuItem*)menuItem;
- (void)nativeMenuItemHaltAllMachines:(NativeMenuItem*)menuItem;
- (void)nativeMenuItemDestroyAllMachines:(NativeMenuItem*)menuItem;
- (void)nativeMenuItemProvisionAllMachines:(NativeMenuItem*)menuItem;
- (void)nativeMenuItemCustomCommandAllMachines:(NativeMenuItem*)menuItem withCommand:(CustomCommand*)customCommand;
- (void)nativeMenuItemOpenFinder:(NativeMenuItem*)menuItem;
- (void)nativeMenuItemOpenTerminal:(NativeMenuItem*)menuItem;
- (void)nativeMenuItemUpdateProviderIdentifier:(NativeMenuItem*)menuItem withProviderIdentifier:(NSString*)providerIdentifier;
- (void)nativeMenuItemRemoveBookmark:(NativeMenuItem*)menuItem;
- (void)nativeMenuItemAddBookmark:(NativeMenuItem*)menuItem;

- (void)nativeMenuItemUpMachine:(VagrantMachine*)machine withProvision:(BOOL)provision;
- (void)nativeMenuItemSSHMachine:(VagrantMachine*)machine;
- (void)nativeMenuItemRDPMachine:(VagrantMachine*)machine;
- (void)nativeMenuItemSuspendMachine:(VagrantMachine*)machine;
- (void)nativeMenuItemReloadMachine:(VagrantMachine*)machine;
- (void)nativeMenuItemHaltMachine:(VagrantMachine*)machine;
- (void)nativeMenuItemDestroyMachine:(VagrantMachine*)machine;
- (void)nativeMenuItemProvisionMachine:(VagrantMachine*)machine;
- (void)nativeMenuItemCustomCommandMachine:(VagrantMachine*)machine withCommand:(CustomCommand*)customCommand;

@end

@interface NativeMenuItem : NSObject <NSMenuDelegate>

@property id<NativeMenuItemDelegate> delegate;

@property (strong) VagrantInstance *instance;
@property (strong) NSMenuItem *menuItem;

- (void)refresh;

@end
