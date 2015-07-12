//
//  VagrantInstance.h
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VagrantMachine.h"

@interface VagrantInstance : NSObject

@property (readonly) NSString *path;
@property (readonly) NSString *displayName;
@property (strong, nonatomic) NSMutableArray *machines;
@property (strong, nonatomic) NSString *providerIdentifier;

- (id)initWithPath:(NSString*)path providerIdentifier:(NSString*)providerIdentifier;
- (id)initWithPath:(NSString*)path displayName:(NSString*)displayName providerIdentifier:(NSString*)providerIdentifier;

- (VagrantMachine*)getMachineWithName:(NSString*)name;
- (int)getRunningMachineCount;
- (int)getMachineCountWithState:(VagrantMachineState)state;
- (BOOL)hasVagrantfile;

- (NSString*)getPath;

@end
