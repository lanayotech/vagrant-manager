//
//  VirtualBoxMachineInfo.h
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import "VirtualMachineInfo.h"

@interface VirtualBoxMachineInfo : VirtualMachineInfo

+ (VirtualBoxMachineInfo*)initWithInfo:(NSString*)infoString :(id<VirtualMachineServiceProvider>)provider;

@end
