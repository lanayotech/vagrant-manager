//
//  NativeMenuItem.h
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NativeMenuItem;

@protocol NativeMenuItemDelegate

- (void)nativeMenuItemUpAllMachines:(NativeMenuItem*)menuItem;
- (void)nativeMenuItemSSHInstance:(NativeMenuItem*)menuItem;
- (void)nativeMenuItemSuspendAllMachines:(NativeMenuItem*)menuItem;
- (void)nativeMenuItemReloadAllMachines:(NativeMenuItem*)menuItem;
- (void)nativeMenuItemHaltAllMachines:(NativeMenuItem*)menuItem;
- (void)nativeMenuItemDestroyAllMachines:(NativeMenuItem*)menuItem;
- (void)nativeMenuItemProvisionAllMachines:(NativeMenuItem*)menuItem;
- (void)nativeMenuItemOpenFinder:(NativeMenuItem*)menuItem;
- (void)nativeMenuItemOpenTerminal:(NativeMenuItem*)menuItem;
- (void)nativeMenuItemUpdateProviderIdentifier:(NativeMenuItem*)menuItem withProviderIdentifier:(NSString*)providerIdentifier;
- (void)nativeMenuItemRemoveBookmark:(NativeMenuItem*)menuItem;
- (void)nativeMenuItemAddBookmark:(NativeMenuItem*)menuItem;

@end

@interface NativeMenuItem : NSObject <NSMenuDelegate>

@property id<NativeMenuItemDelegate> delegate;

@property (strong) VagrantInstance *instance;
@property (strong) NSMenuItem *menuItem;

- (void)refresh;

@end
