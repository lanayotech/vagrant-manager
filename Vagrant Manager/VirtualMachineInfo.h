//
//  VirtualMachineInfo.h
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VirtualMachineServiceProvider.h"

@interface VirtualMachineInfo : NSObject

@property (strong, nonatomic) NSString *uuid;
@property (strong, nonatomic) NSString *state;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *os;
@property (strong, nonatomic) NSDictionary *sharedFolders;
@property (strong, nonatomic) NSDictionary *properties;
@property id<VirtualMachineServiceProvider> provider;

- (NSString*)getSharedFolderPathWithName:(NSString*)name;
- (BOOL)isRunning;
- (BOOL)isSuspended;
- (id<VirtualMachineServiceProvider>)getProvider;

@end
