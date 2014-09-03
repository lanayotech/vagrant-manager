//
//  ParallelsMachineInfo.h
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ParallelsMachineInfo : VirtualMachineInfo


@property (strong, nonatomic) NSString *uuid;
@property (strong, nonatomic) NSString *stateString;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *os;
@property (strong, nonatomic) NSDictionary *sharedFolders;
@property (strong, nonatomic) NSDictionary *properties;

+ (ParallelsMachineInfo*)initWithInfo:(NSDictionary*)infoDictionary;

- (NSString*)getSharedFolderPathWithName:(NSString*)name;

@end
