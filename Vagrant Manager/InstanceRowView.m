//
//  InstanceRowView.m
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import "InstanceRowView.h"
#import "InstanceMenuItem.h"

@implementation InstanceRowView {
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
        NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithRed:.38f green:.53f blue:.97f alpha:1] endingColor:[NSColor colorWithRed:.13f green:.38f blue:.96f alpha:1]];
        [gradient drawInRect:self.bounds angle:90];
    }
}

- (void)mouseEntered:(NSEvent *)theEvent {
    _mouseInside = YES;
    [self setNeedsDisplay:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"vagrant-manager.menu-row-mouse-entered" object:nil userInfo:@{@"row":[NSNumber numberWithInteger:self.rowIdx]}];
}

- (void)mouseExited:(NSEvent *)theEvent {
    _mouseInside = NO;
    [self setNeedsDisplay:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"vagrant-manager.menu-row-mouse-exited" object:nil userInfo:@{@"row":[NSNumber numberWithInteger:self.rowIdx]}];
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
