//
//  VagrantMachine.h
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VagrantInstance;

typedef enum {
    UnknownState,
    NotCreatedState,
    PowerOffState,
    SavedState,
    RunningState,
    RestoringState
} VagrantMachineState;

@interface VagrantMachine : NSObject

@property (weak) VagrantInstance *instance;
@property (strong) NSString *name;
@property (nonatomic) VagrantMachineState state;
@property (strong, nonatomic) NSString *stateString;

- (id)initWithInstance:(VagrantInstance*)instance name:(NSString*)name state:(VagrantMachineState)state;

+ (NSString*)getStringForState:(VagrantMachineState)state;
+ (VagrantMachineState)getStateForString:(NSString*)stateString;

@end
