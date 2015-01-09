//
//  MenuDelegate.h
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import "VagrantInstance.h"
#import "VagrantMachine.h"
#import "CustomCommand.h"

@protocol MenuDelegate <NSObject>

- (void)performVagrantAction:(NSString*)action withInstance:(VagrantInstance*)instance;
- (void)performVagrantAction:(NSString*)action withMachine:(VagrantMachine*)machine;
- (void)performCustomCommand:(CustomCommand*)customCommand withInstance:(VagrantInstance*)instance;
- (void)performCustomCommand:(CustomCommand*)customCommand withMachine:(VagrantMachine*)machine;
- (void)openInstanceInFinder:(VagrantInstance*)instance;
- (void)openInstanceInTerminal:(VagrantInstance*)instance;
- (void)addBookmarkWithInstance:(VagrantInstance*)instance;
- (void)removeBookmarkWithInstance:(VagrantInstance*)instance;

@end