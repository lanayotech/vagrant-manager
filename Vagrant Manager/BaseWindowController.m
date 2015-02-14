//
//  BaseWindowController.m
//  Vagrant Manager
//
//  Copyright (c) 2015 Lanayo. All rights reserved.
//

#import "BaseWindowController.h"

@implementation BaseWindowController

- (void)windowWillClose:(NSNotification *)notification {
    [[Util getApp] removeOpenWindow:self];
    self.isClosed = YES;
}

@end
