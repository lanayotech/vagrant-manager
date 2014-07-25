//
//  MachineMenuItem.m
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import "MachineMenuItem.h"

@implementation MachineMenuItem

- (void)drawRect:(NSRect)dirtyRect {
    [[NSColor darkGrayColor] setFill];
    NSRectFillUsingOperation(self.bounds, NSCompositeSourceOver);
}

- (IBAction)sshButtonClicked:(id)sender {
    [self.delegate machineMenuItem:self vagrantAction:@"ssh"];
}

- (IBAction)upButtonClicked:(id)sender {
    [self.delegate machineMenuItem:self vagrantAction:@"up"];
}

- (IBAction)reloadButtonClicked:(id)sender {
    [self.delegate machineMenuItem:self vagrantAction:@"reload"];
}

- (IBAction)suspendButtonClicked:(id)sender {
    [self.delegate machineMenuItem:self vagrantAction:@"suspend"];
}

- (IBAction)haltButtonClicked:(id)sender {
    [self.delegate machineMenuItem:self vagrantAction:@"halt"];
}

- (IBAction)provisionButtonClicked:(id)sender {
    [self.delegate machineMenuItem:self vagrantAction:@"provision"];
}

- (IBAction)destroyButtonClicked:(id)sender {
    NSAlert *confirmAlert = [NSAlert alertWithMessageText:@"Are you sure you want to destroy this vagrant machine?" defaultButton:@"Confirm" alternateButton:@"Cancel" otherButton:nil informativeTextWithFormat:@""];
    NSInteger button = [confirmAlert runModal];
    
    if(button == NSAlertDefaultReturn) {
        [self.delegate machineMenuItem:self vagrantAction:@"destroy"];
    }
}

@end
