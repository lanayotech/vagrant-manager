//
//  ClickableView.m
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import "ClickableView.h"

@implementation ClickableView {
    NSTrackingArea *_trackingArea;
    BOOL _isHighlighted;
}

- (void)updateTrackingAreas {
    if(_trackingArea != nil) {
        [self removeTrackingArea:_trackingArea];
    }
    
    int opts = (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways);
    _trackingArea = [[NSTrackingArea alloc] initWithRect:[self bounds] options:opts owner:self userInfo:nil];
    [self addTrackingArea:_trackingArea];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    if(_isHighlighted) {
        [[NSColor lightGrayColor] setFill];
    } else {
        [[NSColor clearColor] setFill];
    }
    
    NSRectFillUsingOperation(dirtyRect, NSCompositeSourceOver);
}

- (void)mouseEntered:(NSEvent *)theEvent {
    _isHighlighted = YES;
    [self setNeedsDisplay:YES];
}

- (void)mouseExited:(NSEvent *)theEvent {
    _isHighlighted = NO;
    [self setNeedsDisplay:YES];
}

- (void)mouseDown:(NSEvent *)theEvent {
}

- (void)mouseUp:(NSEvent *)theEvent {
    if(_isHighlighted) {
    }
}

@end
