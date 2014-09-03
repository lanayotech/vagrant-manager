//
//  VagrantMachine.m
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import "VagrantMachine.h"

@implementation VagrantMachine

- (id)initWithInstance:(VagrantInstance*)instance name:(NSString*)name state:(VagrantMachineState)state {
    self = [super init];
    
    if(self) {
        self.instance = instance;
        self.name = name;
        _state = state;
        _stateString = [VagrantMachine getStringForState:state];
    }
    
    return self;
}

+ (NSString*)getStringForState:(VagrantMachineState)state {
    if(state == NotCreatedState) {
        return @"not created";
    } else if(state == PowerOffState) {
        return @"poweroff";
    } else if(state == SavedState) {
        return @"saved";
    } else if(state == RunningState) {
        return @"running";
    } else if(state == RestoringState) {
        return @"restoring";
    } else {
        return @"unknown";
    }
}

+ (VagrantMachineState)getStateForString:(NSString*)stateString {
    if([stateString isEqualToString:@"not created"]) {
        return NotCreatedState;
    } else if([stateString isEqualToString:@"poweroff"]) {
        return PowerOffState;
    } else if([stateString isEqualToString:@"saved"]) {
        return SavedState;
    } else if([stateString isEqualToString:@"running"]) {
        return RunningState;
    } else if([stateString isEqualToString:@"restoring"]) {
        return RestoringState;
    } else {
        return UnknownState;
    }
}

- (void)setStateString:(NSString*)stateString {
    _stateString = stateString;
    _state = [VagrantMachine getStateForString:stateString];
}

- (VagrantMachineState)getState {
    return _state;
}

- (void)setState:(VagrantMachineState)state {
    _state = state;
    _stateString = [VagrantMachine getStringForState:state];
}

- (NSString*)getStateString {
    return _stateString;
}

@end
