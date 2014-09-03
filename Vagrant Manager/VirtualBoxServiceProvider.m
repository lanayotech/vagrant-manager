//
//  VirtualBoxServiceProvider.m
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import "VirtualBoxServiceProvider.h"

@implementation VirtualBoxServiceProvider

- (NSString*)getProviderIdentifier {
    return @"virtualbox";
}

//find all vagrant instances that VirtualBox knows about
- (NSArray*)getVagrantInstancePaths {
    NSMutableArray *paths = [[NSMutableArray alloc] init];
    
    //get all virtual machines UUIDs from VirtualBox
    NSArray *uuids = [self getAllVirtualMachineUUIDs];
    
    //check each machine by uuid
    for(NSString *uuid in uuids) {
        //get virtual machine info from VirtualBox
        VirtualBoxMachineInfo *machineInfo = [self getVirtualMachineInfoFromUUID:uuid];
        
        if(machineInfo) {
            //check for path mapped to /vagrant
            NSString *instancePath = [Util trimTrailingSlash:[machineInfo getSharedFolderPathWithName:@"/vagrant"]];
            
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

//get machine ids of all VirtualBox VMs
- (NSArray*)getAllVirtualMachineUUIDs {
    NSMutableArray *uuids = [[NSMutableArray alloc] init];
    
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/bash"];
    
    [task setArguments:@[@"-c", @"VBoxManage list vms"]];
    
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardInput:[NSPipe pipe]];
    [task setStandardOutput:pipe];
    
    [task launch];
    [task waitUntilExit];
    
    NSData *outputData = [[pipe fileHandleForReading] readDataToEndOfFile];
    NSString *outputString = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
    
    if(task.terminationStatus == 0) {
        //search for machine UUIDs
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\"[^\"]+\"\\s+\\{([^\\}]+)\\}" options:0 error:NULL];
        NSArray *matches = [regex matchesInString:outputString options:0 range:NSMakeRange(0, [outputString length])];
        for(NSTextCheckingResult *match in matches) {
            NSRange uuidRange = [match rangeAtIndex:1];
            
            [uuids addObject:[outputString substringWithRange:uuidRange]];
        }
    }
    
    return [[NSArray alloc] initWithArray:uuids];
}

//get machine info for a VirtualBox VM
- (VirtualBoxMachineInfo*)getVirtualMachineInfoFromUUID:(NSString*)uuid {
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/bash"];
    [task setArguments:@[@"-c", [NSString stringWithFormat:@"VBoxManage showvminfo %@ --machinereadable", uuid]]];
    
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardInput:[NSPipe pipe]];
    [task setStandardOutput:pipe];
    
    [task launch];
    [task waitUntilExit];
    
    NSData *outputData = [[pipe fileHandleForReading] readDataToEndOfFile];
    NSString *outputString = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
    
    if(task.terminationStatus == 0) {
        return [VirtualBoxMachineInfo initWithInfo:outputString];
    } else {
        return nil;
    }
}

@end
