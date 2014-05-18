//
//  SlideMenuView.m
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import "SlideMenuView.h"

@implementation SlideMenuView {
    NSScrollView *_scrollView;
    NSView *_scrollDocumentView;
    
    NSMutableArray *_instanceMenuItems;
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        //create scroll view
        _scrollView = [[NSScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [_scrollView setBorderType:NSNoBorder];
        [_scrollView setVerticalScrollElasticity:NSScrollElasticityNone];
        [_scrollView setHorizontalScrollElasticity:NSScrollElasticityNone];
        _scrollView.drawsBackground = NO;
        [self addSubview:_scrollView];
        
        //create scroll document view
        _scrollDocumentView = [[NSView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        
        [_scrollView setDocumentView:_scrollDocumentView];
        [self addSubview:_scrollView];
        
        [_scrollView setHasVerticalScroller:_scrollDocumentView.frame.size.height > _scrollView.frame.size.height];
        [_scrollView setHasHorizontalScroller:_scrollDocumentView.frame.size.width > _scrollView.frame.size.width];
        [_scrollView setScrollerStyle:NSScrollerStyleOverlay];

        _instanceMenuItems = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addInstance:(VagrantInstance*)instance {
    InstanceMenuItem *item = [[InstanceMenuItem alloc] initWithNibName:@"InstanceMenuItem" bundle:nil];
    
    item.displayName = instance.displayName;
    
    CGRect frame = item.view.frame;
    
    float y;
    if(_instanceMenuItems.count > 0) {
        InstanceMenuItem *prevItem = [_instanceMenuItems lastObject];
        y = prevItem.view.frame.origin.y + prevItem.view.frame.size.height;
    } else {
        y = 0;
    }
    
    frame.origin.x = 0;
    frame.origin.y = y;
    frame.size.width = self.frame.size.width;
    item.view.frame = frame;
    
    [_instanceMenuItems addObject:item];
    [_scrollDocumentView addSubview:item.view];
    
    [self positionMenuItems];
}

- (void)updateMenuHeight {
    float height = 0;
    for(InstanceMenuItem *item in _instanceMenuItems) {
        height += item.view.frame.size.height;
    }

    float heightDiff = height - _scrollDocumentView.frame.size.height;

    [_scrollDocumentView setFrameSize:CGSizeMake(_scrollDocumentView.frame.size.width, height)];
    
    float outerHeight = MIN(100, height);
    CGRect frame = self.frame;
    frame.size.height = outerHeight;
    self.frame = frame;
    frame = _scrollView.frame;
    frame.size.height = outerHeight;
    _scrollView.frame = frame;
    
    [_scrollView setHasVerticalScroller:_scrollDocumentView.frame.size.height > _scrollView.frame.size.height];
    [_scrollView setHasHorizontalScroller:_scrollDocumentView.frame.size.width > _scrollView.frame.size.width];
    
    if(heightDiff != 0) {
        NSRect scrollRect = _scrollView.contentView.documentVisibleRect;
        scrollRect.origin.y += heightDiff;
        [[_scrollView documentView] scrollPoint:scrollRect.origin];
    }
}

- (void)positionMenuItems {
    [self updateMenuHeight];
    
    float y = _scrollDocumentView.frame.size.height;
    for(InstanceMenuItem *item in _instanceMenuItems) {
        CGRect frame = item.view.frame;
        frame.origin.y = y - frame.size.height;
        y -= frame.size.height;
        item.view.frame = frame;
    }
    
    [self.delegate slideMenuHeightUpdated:self];
}

- (void)scrollToTop {
    NSPoint newScrollOrigin;
    
    if ([[_scrollView documentView] isFlipped]) {
        newScrollOrigin=NSMakePoint(0.0,0.0);
    } else {
        newScrollOrigin=NSMakePoint(0.0,NSMaxY([[_scrollView documentView] frame])
                                    -NSHeight([[_scrollView contentView] bounds]));
    }
    
    [[_scrollView documentView] scrollPoint:newScrollOrigin];
}

- (void)resizeToFitSubviews:(NSView*)view {
    float width = 0;
    float height = 0;
    for(NSView *subview in view.subviews) {
        CGRect frame = subview.frame;
        
        if(frame.origin.x < 0) {
            width -= frame.origin.x;
            frame.origin.x = 0;
        }
        if(frame.origin.y < 0) {
            height -= frame.origin.y;
            frame.origin.y = 0;
        }
        
        if(subview.frame.origin.x + subview.frame.size.width > width) {
            width = subview.frame.origin.x + subview.frame.size.width;
        }
        if(subview.frame.origin.y + subview.frame.size.height > height) {
            height = subview.frame.origin.y + subview.frame.size.height;
        }
    }
    
    [view setFrameSize:NSMakeSize(width, height)];
}

@end
