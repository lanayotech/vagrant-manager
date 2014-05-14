//
//  VirtualMachineServiceProvider.h
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VirtualMachineServiceProvider : NSObject

+ (NSArray*)getAllVirtualMachinesWithInfo;
+ (VirtualMachineInfo*)getNFSVirtualMachineInfo:(NSString*)uuid NFSPath:(NSString*)NFSPath;
+ (VirtualMachineInfo*)getVirtualMachineInfo:(NSString*)uuid;
+ (NSArray*)getAllNFSVagrantMachinesWithInfo;
+ (NSMutableArray*)sortVirtualMachines:(NSArray*)virtualMachines;

@end
