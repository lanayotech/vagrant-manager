//
//  VirtualMachineInfo.m
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import "VirtualMachineInfo.h"

@implementation VirtualMachineInfo

- (NSString*)getSharedFolderPathWithName:(NSString*)name {
    NSString *folder = [self.sharedFolders objectForKey:name];
    if(!folder && [[name substringToIndex:1] isEqualToString:@"/"]) {
        folder = [self.sharedFolders objectForKey:[name substringFromIndex:1]];
    }
    
    return folder;
}

- (BOOL)isState:(PossibleVmStates)state {
    return self.state == state;
}

- (BOOL)isRunning {
    return self.state == running;
}

- (BOOL)isSuspended {
    return self.state == suspended;
}

- (BOOL)isOff {
    return self.state == off;
}

- (id<VirtualMachineServiceProvider>)getProvider {
    return self.provider;
}

@end
