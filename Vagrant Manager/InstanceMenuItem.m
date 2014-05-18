//
//  InstanceMenuItem.m
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import "InstanceMenuItem.h"

@interface InstanceMenuItem ()

@end

@implementation InstanceMenuItem

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.displayName = @"";
    }
    return self;
}

- (void)loadView {
    [super loadView];
    
    [self.nameTextField setStringValue:self.displayName];
}

@end
