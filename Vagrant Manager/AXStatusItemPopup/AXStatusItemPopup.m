//
//  StatusItemPopup.m
//  StatusItemPopup
//
//  Created by Alexander Schuch on 06/03/13.
//  Copyright (c) 2013 Alexander Schuch. All rights reserved.
//

#import "AXStatusItemPopup.h"
#import "AXTextView.h"

#define kMinViewWidth 22

//
// Private variables
//
@interface AXStatusItemPopup () {
    NSViewController *_viewController;
    BOOL _active;
    NSImageView *_imageView;
    NSTextView *_titleView;
    NSStatusItem *_statusItem;
    NSPopover *_popover;
    id _popoverTransiencyMonitor;
}
@end

///////////////////////////////////

//
// Implementation
//
@implementation AXStatusItemPopup

- (id)initWithViewController:(NSViewController *)controller
{
    return [self initWithViewController:controller image:nil];
}

- (id)initWithViewController:(NSViewController *)controller image:(NSImage *)image
{
    return [self initWithViewController:controller image:image alternateImage:nil];
}

- (id)initWithViewController:(NSViewController *)controller image:(NSImage *)image alternateImage:(NSImage *)alternateImage
{
    CGFloat height = [NSStatusBar systemStatusBar].thickness;
    
    self = [super initWithFrame:NSMakeRect(0, 0, kMinViewWidth*2, height)];
    if (self) {
        _viewController = controller;
        
        self.image = image;
        self.alternateImage = alternateImage;
        
        _imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, kMinViewWidth, height)];
        [self addSubview:_imageView];
        
        _titleView = [[AXTextView alloc] initWithFrame:NSMakeRect(kMinViewWidth, 0, 20, height)];
        [self addSubview:_titleView];
        [_titleView setString:@""];
        _titleView.font = [NSFont boldSystemFontOfSize:12];
        [_titleView.textContainer setLineFragmentPadding:0];
        [_titleView setTextContainerInset:NSMakeSize(0, 0)];
        [_titleView setBackgroundColor:[NSColor clearColor]];
        
        self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
        self.statusItem.view = self;
        
        _active = NO;
        _animated = YES;
    }
    return self;
}

- (void)setTitle:(NSString*)title {
    NSAttributedString *string = [[NSAttributedString alloc] initWithString:title attributes:@{NSFontAttributeName: _titleView.font}];
    CGRect rect = [string boundingRectWithSize:(CGSize){CGFLOAT_MAX, self.frame.size.height} options:NSStringDrawingUsesLineFragmentOrigin];
    
    
    CGRect frame = _titleView.frame;
    frame.size.width = rect.size.width;
    frame.size.height = rect.size.height;
    frame.origin.y = (self.frame.size.height - frame.size.height) / 2;
    _titleView.frame = frame;
    _titleView.string = title;
    [self updateViewFrame];
}


////////////////////////////////////
#pragma mark - Drawing
////////////////////////////////////

- (void)drawRect:(NSRect)dirtyRect
{
    // set view background color
    if (_active) {
        [[NSColor selectedMenuItemColor] setFill];
    } else {
        [[NSColor clearColor] setFill];
    }
    NSRectFill(dirtyRect);
    
    // set image
    NSImage *image = (_active ? _alternateImage : _image);
    _imageView.image = image;
    
    if(_active) {
        _titleView.textColor = [NSColor whiteColor];
    } else {
        _titleView.textColor = [NSColor blackColor];
    }
}

////////////////////////////////////
#pragma mark - Position / Size
////////////////////////////////////

- (void)setContentSize:(CGSize)size
{
    _popover.contentSize = size;
}

////////////////////////////////////
#pragma mark - Mouse Actions
////////////////////////////////////

- (void)mouseDown:(NSEvent *)theEvent
{
    if (_popover.isShown) {
        [self hidePopover];
    } else {
        [self showPopover];
    }    
}

////////////////////////////////////
#pragma mark - Setter
////////////////////////////////////

- (void)setActive:(BOOL)active
{
    _active = active;
    [self setNeedsDisplay:YES];
}

- (void)setImage:(NSImage *)image
{
    _image = image;
    [self updateViewFrame];
}

- (void)setAlternateImage:(NSImage *)image
{
    _alternateImage = image;
    if (!image && _image) {
        _alternateImage = _image;
    }
    [self updateViewFrame];
}

////////////////////////////////////
#pragma mark - Helper
////////////////////////////////////

- (void)updateViewFrame
{
    CGFloat width = MAX(MAX(kMinViewWidth, self.alternateImage.size.width), self.image.size.width);
    
    if([_titleView string].length > 0) {
        width += _titleView.frame.size.width;
    }
    
    CGFloat height = [NSStatusBar systemStatusBar].thickness;
    
    NSRect frame = NSMakeRect(0, 0, width, height);
    self.frame = frame;
    
    [self setNeedsDisplay:YES];
}


////////////////////////////////////
#pragma mark - Show / Hide Popover
////////////////////////////////////

- (void)showPopover
{
    [self showPopoverAnimated:_animated];
}

- (void)showPopoverAnimated:(BOOL)animated
{
    self.active = YES;
    
    if (!_popover) {
        _popover = [[NSPopover alloc] init];
        _popover.contentViewController = _viewController;
    }
    
    if (!_popover.isShown) {
        _popover.animates = animated;
        [_popover showRelativeToRect:self.frame ofView:self preferredEdge:NSMinYEdge];
        _popoverTransiencyMonitor = [NSEvent addGlobalMonitorForEventsMatchingMask:NSLeftMouseDownMask|NSRightMouseDownMask handler:^(NSEvent* event) {
            [self hidePopover];
        }];
    }
}

- (void)hidePopover
{
    self.active = NO;
    
    if (_popover && _popover.isShown) {
        [_popover close];

		if (_popoverTransiencyMonitor) {
            [NSEvent removeMonitor:_popoverTransiencyMonitor];
            _popoverTransiencyMonitor = nil;
        }
    }
}

@end

