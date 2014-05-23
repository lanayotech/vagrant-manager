//
//  MachineMenuItem.m
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import "MachineMenuItem.h"

@implementation MachineMenuItem

- (void)drawRect:(NSRect)dirtyRect {
    [[NSColor darkGrayColor] setFill];
    NSRectFillUsingOperation(self.bounds, NSCompositeSourceOver);
}

@end
