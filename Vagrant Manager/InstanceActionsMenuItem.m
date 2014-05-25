//
//  InstanceActionsMenuItem.m
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import "InstanceActionsMenuItem.h"

@implementation InstanceActionsMenuItem

- (void)drawRect:(NSRect)dirtyRect {
    [[NSColor colorWithCalibratedRed:.66f green:.74f blue:.83f alpha:1.0f] setFill];
    NSRectFillUsingOperation(self.bounds, NSCompositeSourceOver);
}

- (IBAction)upButtonClicked:(id)sender {
    [self.delegate instanceActionsMenuItem:self vagrantAction:@"up"];
}

- (IBAction)reloadButtonClicked:(id)sender {
    [self.delegate instanceActionsMenuItem:self vagrantAction:@"reload"];
}

- (IBAction)suspendButtonClicked:(id)sender {
    [self.delegate instanceActionsMenuItem:self vagrantAction:@"suspend"];
}

- (IBAction)haltButtonClicked:(id)sender {
    [self.delegate instanceActionsMenuItem:self vagrantAction:@"halt"];
}

- (IBAction)provisionButtonClicked:(id)sender {
    [self.delegate instanceActionsMenuItem:self vagrantAction:@"provision"];
}

- (IBAction)destroyButtonClicked:(id)sender {
    [self.delegate instanceActionsMenuItem:self vagrantAction:@"destroy"];
}

@end
