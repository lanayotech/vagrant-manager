//
//  SlideMenuView.h
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "InstanceMenuItem.h"
#import "VagrantInstance.h"

@class SlideMenuView;

@protocol SlideMenuDelegate <NSObject>

- (void)slideMenuHeightUpdated:(SlideMenuView*)slideMenuView;

@end

@interface SlideMenuView : NSView

@property (weak) id<SlideMenuDelegate> delegate;

- (BOOL)hasMoreUp;
- (BOOL)hasMoreDown;

- (void)addInstance:(VagrantInstance*)instance;

@end
