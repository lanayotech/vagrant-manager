//
//  VagrantMachine.h
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VagrantMachine : NSObject

@property (strong, nonatomic) NSString *vmid;
@property (strong, nonatomic) NSString *displayName;
@property (strong, nonatomic) NSString *path;
@property BOOL isRunning;

@end
