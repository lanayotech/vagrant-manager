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
@property (readonly) NSArray *machines;
@property (readonly) NSString *providerIdentifier;

- (id)initWithPath:(NSString*)path providerIdentifier:(NSString*)providerIdentifier;
- (id)initWithPath:(NSString*)path displayName:(NSString*)displayName providerIdentifier:(NSString*)providerIdentifier;

- (VagrantMachine*)getMachineWithName:(NSString*)name;
- (void)queryMachines;

- (NSString*)getPath;

@end
