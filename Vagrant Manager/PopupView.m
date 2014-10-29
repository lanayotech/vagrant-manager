//
//  PopupView.m
//  Vagrant Manager
//
//  Created by Chris Ayoub on 10/3/14.
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import "PopupView.h"

@implementation PopupView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.wantsLayer = YES;
        self.layer.frame = self.frame;
        [self.layer setCornerRadius:3.0];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [[NSColor whiteColor] setFill];
    NSRectFill(dirtyRect);
    [super drawRect:dirtyRect];
}

@end
