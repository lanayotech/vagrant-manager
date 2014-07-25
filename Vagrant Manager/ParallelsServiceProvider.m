//
//  ParallelsServiceProvider.m
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import "ParallelsServiceProvider.h"
#import "ParallelsMachineInfo.h"

@implementation ParallelsServiceProvider

- (NSString*)getProviderIdentifier {
    return @"parallels";
}

- (NSArray*)getVagrantInstancePaths {
    NSMutableArray *paths = [[NSMutableArray alloc] init];
    
    //get all virtual machines UUIDs from Parallels
    NSArray *infos = [self getAllVirtualMachineInfos];
    
    //check each machine by uuid
    for(ParallelsMachineInfo *machineInfo in infos) {
        if(machineInfo) {
            //check for path mapped to /vagrant
            NSString *instancePath = [Util trimTrailingSlash:[machineInfo getSharedFolderPathWithName:@"vagrant"]];
            
            if(instancePath) {
                if([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/Vagrantfile", instancePath]] && ![paths containsObject:instancePath]) {
                    //mapped path found, and not already added to list
                    [paths addObject:instancePath];
                }
            }
        }
    }
    
    return paths;
}

- (NSArray*)getAllVirtualMachineInfos {
    NSMutableArray *infos = [[NSMutableArray alloc] init];
    
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/bash"];
    
    [task setArguments:@[@"-c", @"prlctl list --info --all --json"]];
    
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardInput:[NSPipe pipe]];
    [task setStandardOutput:pipe];
    
    [task launch];
    [task waitUntilExit];
    
    NSData *outputData = [[pipe fileHandleForReading] readDataToEndOfFile];
    
    if(task.terminationStatus == 0) {
        NSError *error = nil;
        NSArray *machineObjects = [NSJSONSerialization JSONObjectWithData:outputData options:0 error:&error];
        
        if(!error && [machineObjects isKindOfClass:[NSArray class]]) {
            for(id machineObject in machineObjects) {
                if([machineObject isKindOfClass:[NSDictionary class]]) {
                    [infos addObject:[ParallelsMachineInfo initWithInfo:machineObject]];
                }
            }
        }
    }
    
    return [[NSArray alloc] initWithArray:infos];
}

@end
