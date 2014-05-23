//
//  StatusItemPopup.h
//  StatusItemPopup
//
//  Created by Alexander Schuch on 06/03/13.
//  Copyright (c) 2013 Alexander Schuch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class PopupContentViewController;

@interface AXStatusItemPopup : NSView

// properties
@property(assign, nonatomic, getter=isActive) BOOL active;
@property(assign, nonatomic) BOOL animated;
@property(strong, nonatomic) NSImage *image;
@property(strong, nonatomic) NSImage *alternateImage;
@property(strong, nonatomic) NSStatusItem *statusItem;


// init
- (id)initWithViewController:(PopupContentViewController *)controller;
- (id)initWithViewController:(PopupContentViewController *)controller image:(NSImage *)image;
- (id)initWithViewController:(PopupContentViewController *)controller image:(NSImage *)image alternateImage:(NSImage *)alternateImage;

- (void)setTitle:(NSString*)title;

// show / hide popover
- (void)showPopover;
- (void)showPopoverAnimated:(BOOL)animated;
- (void)hidePopover;
- (NSPopover*)getPopover;

// view size
- (void)setContentSize:(CGSize)size;

@end
