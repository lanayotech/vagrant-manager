//
//  CustomCommandManager.m
//  Vagrant Manager
//
//  Copyright (c) 2015 Lanayo. All rights reserved.
//

#import "CustomCommand.h"

@implementation CustomCommand

- (id)init {
    self = [super init];
    
    if(self) {
        self.displayName = @"";
        self.command = @"";
    }
    
    return self;
}

- (id)copyWithZone:(NSZone*)zone {
    CustomCommand *command = [[[self class] allocWithZone:zone] init];
    
    if(command) {
        command.displayName = self.displayName;
        command.command = self.command;
        command.runInTerminal = self.runInTerminal;
    }
    
    return command;
}

@end
