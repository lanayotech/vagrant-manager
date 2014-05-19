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
        
        [_scrollView.contentView setPostsBoundsChangedNotifications:YES];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollBoundsDidChange:) name:NSViewBoundsDidChangeNotification object:_scrollView.contentView];
        
        [_scrollView setDocumentView:_scrollDocumentView];
        [self addSubview:_scrollView];
        
        [_scrollView setHasVerticalScroller:_scrollDocumentView.frame.size.height > _scrollView.frame.size.height];
        [_scrollView setHasHorizontalScroller:_scrollDocumentView.frame.size.width > _scrollView.frame.size.width];
        [_scrollView setScrollerStyle:NSScrollerStyleOverlay];

        _instanceMenuItems = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)scrollBoundsDidChange:(id)sender {
    [self.delegate slideMenuHeightUpdated:self];
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
    float width = 200;
    for(InstanceMenuItem *item in _instanceMenuItems) {
        height += item.view.frame.size.height;
        
        NSAttributedString *string = [[NSAttributedString alloc] initWithString:item.nameTextField.stringValue attributes:@{NSFontAttributeName: item.nameTextField.font}];
        CGRect rect = [string boundingRectWithSize:(CGSize){CGFLOAT_MAX, item.nameTextField.frame.size.height} options:0];
        //not sure why the extra 36 is needed, it seem to be missing 18 of the width for some reason, and then I added some padding
        float itemWidth = ceil(item.nameTextField.frame.origin.x + rect.size.width + 36);
        
        if(itemWidth > width) {
            width = itemWidth;
        }
    }

    float heightDiff = height - _scrollDocumentView.frame.size.height;

    [_scrollDocumentView setFrameSize:CGSizeMake(width, height)];
    
    float maxHeight = [[NSScreen mainScreen] frame].size.height - [NSStatusBar systemStatusBar].thickness - 60;
    maxHeight = 200;
    
    float outerHeight = MIN(maxHeight, height);
    CGRect frame = self.frame;
    frame.size.height = outerHeight;
    frame.size.width = width;
    self.frame = frame;
    frame = _scrollView.frame;
    frame.size.height = outerHeight;
    frame.size.width = width;
    _scrollView.frame = frame;
    
    [_scrollView setHasVerticalScroller:_scrollDocumentView.frame.size.height > _scrollView.frame.size.height];
    [_scrollView setHasHorizontalScroller:_scrollDocumentView.frame.size.width > _scrollView.frame.size.width];
    
    if(heightDiff != 0) {
        NSRect scrollRect = _scrollView.contentView.documentVisibleRect;
        scrollRect.origin.y += heightDiff;
        [[_scrollView documentView] scrollPoint:scrollRect.origin];
    }
    
    for(InstanceMenuItem *item in _instanceMenuItems) {
        CGRect frame = item.view.frame;
        frame.size.width = width;
        item.view.frame = frame;
    }
}

- (BOOL)hasMoreUp {
    NSRect scrollRect = _scrollView.contentView.documentVisibleRect;
    return scrollRect.origin.y < (_scrollDocumentView.frame.size.height - _scrollView.frame.size.height);
}

- (BOOL)hasMoreDown {
    NSRect scrollRect = _scrollView.contentView.documentVisibleRect;
    return scrollRect.origin.y > 0;
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
