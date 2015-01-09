//
//  CustomCommandManager.m
//  Vagrant Manager
//
//  Copyright (c) 2015 Lanayo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CustomCommand.h"

@interface CustomCommandManager : NSObject {
    NSMutableArray *_commands;
}

+ (CustomCommandManager*)sharedManager;

- (void)loadCustomCommands;
- (void)saveCustomCommands;
- (void)clearCustomCommands;
- (NSMutableArray*)getCustomCommands;
- (CustomCommand*)addCustomCommand:(CustomCommand*)command;
- (CustomCommand*)addCustomCommandWithDisplayName:(NSString*)displayName command:(NSString*)command runInTerminal:(BOOL)runInTerminal;
- (void)removeCustomCommand:(CustomCommand*)command;
- (void)setCustomCommands:(NSArray*)customCommands;

@end
