//
//  HighlightView.m
//  Vagrant Manager
//
//  Created by Chris Ayoub on 5/19/14.
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import "HighlightView.h"

@implementation HighlightView

- (id)initWithFrame:(NSRect)frameRect {
    self =[super initWithFrame:frameRect];
    if(self) {
        _backgroundColor = [NSColor clearColor];
    }
    
    return self;
}

- (NSColor*)getBackgroundColor {
    return _backgroundColor;
}

- (void)setBackgroundColor:(NSColor*)backgroundColor {
    _backgroundColor = backgroundColor;
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect {
    [_backgroundColor setFill];
    NSRectFillUsingOperation(dirtyRect, NSCompositeSourceOver);
    [super drawRect:dirtyRect];
}

@end
