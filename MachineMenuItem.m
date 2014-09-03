//
//  MachineMenuItem.m
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import "MachineMenuItem.h"

@implementation MachineMenuItem

- (void)drawRect:(NSRect)dirtyRect {
    [[NSColor colorWithRed:.8 green:.8 blue:.8 alpha:.5] set];
    NSRectFillUsingOperation(self.bounds, NSCompositeSourceOver);
}

@end
