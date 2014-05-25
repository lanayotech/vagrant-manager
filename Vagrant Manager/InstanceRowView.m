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

- (void)drawBackgroundInRect:(NSRect)dirtyRect {
    [self.backgroundColor set];
    NSRectFillUsingOperation(self.bounds, NSCompositeSourceOver);
    
    if(_mouseInside) {
        NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:.7 alpha:.5] endingColor:[NSColor colorWithCalibratedWhite:.7 alpha:.2]];
        [gradient drawInRect:self.bounds angle:0];
    }
}

- (void)drawSelectionInRect:(NSRect)dirtyRect {
    NSRect selectionRect = self.bounds;
    [[NSColor colorWithCalibratedWhite:.72 alpha:1.0] setStroke];
    [[NSColor colorWithCalibratedWhite:.82 alpha:1.0] setFill];
    NSBezierPath *selectionPath = [NSBezierPath bezierPathWithRoundedRect:selectionRect xRadius:4 yRadius:4];
    /*
    NSBezierPath *selectionPath = [NSBezierPath bezierPath];
    
    // Draw top border and a top-right rounded corner
    NSPoint topRightCorner = NSMakePoint(NSMaxX(self.bounds), NSMinY(self.bounds));
    [path lineToPoint:NSMakePoint(NSMaxX(self.bounds) - cornerRadius, NSMinY(self.bounds))];
    [path curveToPoint:NSMakePoint(NSMaxX(self.bounds), NSMinY(self.bounds) + cornerRadius)
         controlPoint1:topRightCorner
         controlPoint2:topRightCorner];
    
    // Draw right border, bottom border and left border
    [path lineToPoint:NSMakePoint(NSMaxX(self.bounds), NSMaxY(self.bounds))];
    [path lineToPoint:NSMakePoint(NSMinX(self.bounds), NSMaxY(self.bounds))];
    [path lineToPoint:NSMakePoint(NSMinX(self.bounds), NSMinY(self.bounds))];
    
    [selectionPath moveToPoint:NSMinX(self.bounds), NSMinY(self.bounds)];
     */
    [selectionPath fill];
    [selectionPath stroke];
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
