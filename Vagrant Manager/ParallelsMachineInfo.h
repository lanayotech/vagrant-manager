//
//  ParallelsMachineInfo.h
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ParallelsMachineInfo : VirtualMachineInfo

+ (ParallelsMachineInfo*)initWithInfo:(NSDictionary*)infoDictionary;

- (NSString*)getSharedFolderPathWithName:(NSString*)name;

@end
