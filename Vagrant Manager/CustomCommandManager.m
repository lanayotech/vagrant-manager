//
//  CustomCommandManager.m
//  Vagrant Manager
//
//  Copyright (c) 2015 Lanayo. All rights reserved.
//

#import "CustomCommandManager.h"

@implementation CustomCommandManager

+ (CustomCommandManager*)sharedManager {
    static CustomCommandManager *manager;
    @synchronized(self) {
        if(manager == nil) {
            manager = [[CustomCommandManager alloc] init];
        }
    }
    
    return manager;
}

- (id)init {
    self = [super init];
    
    if(self) {
        _commands = [[NSMutableArray alloc] init];
    }
    
    return self;
}

//load commands from shared preferences
- (void)loadCustomCommands {
    @synchronized(_commands) {
        [_commands removeAllObjects];
        
        NSArray *savedCommands = [[NSUserDefaults standardUserDefaults] arrayForKey:@"customCommands"];
        if(savedCommands) {
            for(NSDictionary *savedCommand in savedCommands) {
                [self addCustomCommandWithDisplayName:[savedCommand objectForKey:@"displayName"] command:[savedCommand objectForKey:@"command"] runInTerminal:[[savedCommand objectForKey:@"runInTerminal"] boolValue]];
            }
        }
    }
}

//save commands to shared preferences
- (void)saveCustomCommands {
    @synchronized(_commands) {
        NSMutableArray *customCommands = [self getCustomCommands];
        if(customCommands) {
            NSMutableArray *arr = [[NSMutableArray alloc] init];
            for(CustomCommand *c in customCommands) {
                [arr addObject:@{@"displayName":c.displayName, @"command":c.command, @"runInTerminal":[NSNumber numberWithBool:c.runInTerminal]}];
            }
            
            [[NSUserDefaults standardUserDefaults] setObject:arr forKey:@"customCommands"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}

- (void)clearCustomCommands {
    @synchronized(_commands) {
        [_commands removeAllObjects];
    }
}

- (CustomCommand*)addCustomCommand:(CustomCommand *)command {
    @synchronized(_commands) {
        [_commands addObject:command];
    }
    
    return command;
}

- (void)setCustomCommands:(NSArray*)customCommands {
    @synchronized(_commands) {
        [_commands removeAllObjects];
        for(id customCommand in customCommands) {
            if([customCommand isKindOfClass:[CustomCommand class]]) {
                [_commands addObject:customCommand];
            }
        }
    }
}

- (NSMutableArray*)getCustomCommands {
    NSMutableArray *commands;
    @synchronized(_commands) {
        commands = [NSMutableArray arrayWithArray:_commands];
    }
    return commands;
}

- (CustomCommand*)addCustomCommandWithDisplayName:(NSString*)displayName command:(NSString*)command runInTerminal:(BOOL)runInTerminal {
    CustomCommand *customCommand = [[CustomCommand alloc] init];
    customCommand.displayName = displayName;
    customCommand.command = command;
    customCommand.runInTerminal = runInTerminal;
    
    @synchronized(_commands) {
        [_commands addObject:customCommand];
    }
    
    return customCommand;
}

- (void)removeCustomCommand:(CustomCommand *)command {
    @synchronized(_commands) {
        [_commands removeObject:command];
    }
}

@end
