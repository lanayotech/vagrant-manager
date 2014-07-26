//
//  TextMenuItem.m
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import "TextMenuItem.h"

@implementation TextMenuItem

- (void)drawRect:(NSRect)dirtyRect {
    if(self.hasTopBorder) {
        [[NSColor colorWithRed:.8 green:.8 blue:.8 alpha:1] set];
        NSRectFillUsingOperation(NSMakeRect(self.bounds.origin.x, self.bounds.origin.y + self.bounds.size.height - 1, self.bounds.origin.x + self.bounds.size.width, self.bounds.origin.y + self.bounds.size.height - 1), NSCompositeSourceOver);
    } else {
        [super drawRect:dirtyRect];
    }
}

@end
