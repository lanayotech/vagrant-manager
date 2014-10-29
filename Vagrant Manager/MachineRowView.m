//
//  MachineRowView.m
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import "MachineRowView.h"

@implementation MachineRowView {
    NSTrackingArea *_trackingArea;
    BOOL _mouseInside;
}

- (void)updateTrackingAreas {
    if(_trackingArea != nil) {
        [self removeTrackingArea:_trackingArea];
    }
    
    int opts = (NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved | NSTrackingActiveAlways | NSTrackingEnabledDuringMouseDrag);
    _trackingArea = [[NSTrackingArea alloc] initWithRect:[self bounds] options:opts owner:self userInfo:nil];
    
    [self addTrackingArea:_trackingArea];
    [super updateTrackingAreas];
    
    [self checkHover];
}

- (void)drawSelectionInRect:(NSRect)dirtyRect {
    
}

- (void)drawBackgroundInRect:(NSRect)dirtyRect {
    [self.backgroundColor set];
    NSRectFillUsingOperation(self.bounds, NSCompositeSourceOver);
    
    if(_mouseInside) {
        NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithRed:0 green:0 blue:1 alpha:.5] endingColor:[NSColor colorWithRed:0 green:0 blue:1 alpha:.2]];
        [gradient drawInRect:self.bounds angle:0];
    }
}

- (void)mouseEntered:(NSEvent *)theEvent {
    _mouseInside = YES;
    [self setNeedsDisplay:YES];
}

- (void)mouseExited:(NSEvent *)theEvent {
    _mouseInside = NO;
    [self setNeedsDisplay:YES];
}

- (void)checkHover {
    NSPoint mouseLocation = [[self window] mouseLocationOutsideOfEventStream];
    mouseLocation = [self convertPoint:mouseLocation fromView:nil];
    
    if(NSPointInRect(mouseLocation, [self bounds])) {
        [self mouseEntered: nil];
    } else {
        [self mouseExited: nil];
    }
}

@end
