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

- (IBAction)toggleOpenButtonClicked:(id)sender {
    [self.delegate instanceMenuItem:self toggleOpenButtonClicked:sender];
}

@end
