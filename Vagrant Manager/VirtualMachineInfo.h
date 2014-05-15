//
//  VirtualMachineInfo.h
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VirtualMachineServiceProvider.h"

typedef enum {running,suspended,off} PossibleVmStates;

@interface VirtualMachineInfo : NSObject

@property (strong, nonatomic) NSString *uuid;
@property (nonatomic) int state;
@property (strong, nonatomic) NSString *stateString;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *os;
@property (strong, nonatomic) NSDictionary *sharedFolders;
@property (strong, nonatomic) NSDictionary *properties;
@property id<VirtualMachineServiceProvider> provider;

- (NSString*)getSharedFolderPathWithName:(NSString*)name;
- (BOOL)isState:(PossibleVmStates)state;
- (BOOL)isRunning;
- (BOOL)isSuspended;
- (BOOL)isOff;
- (id<VirtualMachineServiceProvider>)getProvider;

@end
