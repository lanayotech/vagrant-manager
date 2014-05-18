//
//  SlideMenuView.m
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import "SlideMenuView.h"
#import "MachineMenuItem.h"

@implementation SlideMenuView {
    NSScrollView *scrollView;
    NSTrackingArea *trackingArea;
    BOOL isHighlighted;
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        //create scroll view
        scrollView = [[NSScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [scrollView setBorderType:NSNoBorder];
        [scrollView setHasVerticalScroller:YES];
        [scrollView setVerticalScrollElasticity:NSScrollElasticityNone];
        [scrollView setHorizontalScrollElasticity:NSScrollElasticityNone];
        
        //create scroll document view
        NSView *scrollDocumentView = [[NSView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        
        NSTextView *textView = [[NSTextView alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
        textView.backgroundColor = [NSColor redColor];
        [scrollDocumentView addSubview:textView];
        textView = [[NSTextView alloc] initWithFrame:CGRectMake(0, 40, 100, 30)];
        textView.backgroundColor = [NSColor blueColor];
        [scrollDocumentView addSubview:textView];

        [self resizeToFitSubviews:scrollDocumentView];
        [scrollView setDocumentView:scrollDocumentView];
        [self addSubview:scrollView];
        //initially scroll to top
        [self scrollToTop];
    }
    return self;
}

- (void)addMenuItem:(MachineMenuItem*)item {
    /*
    item.statusImageView.image = [NSImage imageNamed:@"NSStatusUnavailable"];
    [item.machineNameTextField setStringValue:@"Lanayo_default_123"];
    item.view.frame = CGRectMake(0, 0, scrollDocumentView.frame.size.width, item.view.frame.size.height);
    [scrollDocumentView addSubview:item.view];
    
    //resize scroll document view to fit children and add to scroll view
    [self resizeToFitSubviews:scrollDocumentView];
     */
}

- (void)scrollToTop {
    NSPoint newScrollOrigin;
    
    if ([[scrollView documentView] isFlipped]) {
        newScrollOrigin=NSMakePoint(0.0,0.0);
    } else {
        newScrollOrigin=NSMakePoint(0.0,NSMaxY([[scrollView documentView] frame])
                                    -NSHeight([[scrollView contentView] bounds]));
    }
    
    [[scrollView documentView] scrollPoint:newScrollOrigin];
}

- (void)resizeToFitSubviews:(NSView*)view {
    float width = 0;
    float height = 0;
    for(NSView *subview in view.subviews) {
        if(subview.frame.origin.x + subview.frame.size.width > width) {
            width = subview.frame.origin.x + subview.frame.size.width;
        }
        if(subview.frame.origin.y + subview.frame.size.height > height) {
            height = subview.frame.origin.y + subview.frame.size.height;
        }
    }
    
    [view setFrameSize:NSMakeSize(width, height)];
}

- (void)updateTrackingAreas {
    if(trackingArea != nil) {
        [self removeTrackingArea:trackingArea];
    }
    
    int opts = (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways);
    trackingArea = [[NSTrackingArea alloc] initWithRect:[self bounds] options:opts owner:self userInfo:nil];
    [self addTrackingArea:trackingArea];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    if(isHighlighted) {
        [[NSColor lightGrayColor] setFill];
    } else {
        [[NSColor clearColor] setFill];
    }
    
    NSRectFillUsingOperation(dirtyRect, NSCompositeSourceOver);
}

- (void)mouseEntered:(NSEvent *)theEvent {
    isHighlighted = YES;
    [self setNeedsDisplay:YES];
    NSLog(@"entered");
}

- (void)mouseExited:(NSEvent *)theEvent {
    isHighlighted = NO;
    [self setNeedsDisplay:YES];
    NSLog(@"exited");
}

- (void)mouseDown:(NSEvent *)theEvent {
    NSLog(@"down");
}

- (void)mouseUp:(NSEvent *)theEvent {
    NSLog(@"up");
    if(isHighlighted) {
        NSLog(@"click");
    }
}

@end
