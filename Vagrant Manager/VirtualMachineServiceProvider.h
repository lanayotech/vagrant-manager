//
//  VirtualMachineServiceProvider.h
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import <Foundation/Foundation.h>
@class VirtualMachineInfo;

@protocol VirtualMachineServiceProvider <NSObject>
- (NSArray*)getAllVagrantMachines;
- (VirtualMachineInfo*)getVagrantMachineInfo :(NSString*)uuid;
@end