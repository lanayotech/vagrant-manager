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
    
    //check NFS exports file for machines that did not have mapped paths
    NSArray *nfsPaths = [self getNFSInstancePaths];
    for(NSString *path in nfsPaths) {
        if(![paths containsObject:path]) {
            [paths addObject:path];
        }
    }
    
    return paths;
}

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

- (NSArray*)getNFSInstancePaths {
    NSMutableArray *paths = [[NSMutableArray alloc] init];
    
    //get contents of /etc/exports
    NSError *err;
    NSString *fileContents = [NSString stringWithContentsOfFile:@"/etc/exports" encoding:NSUTF8StringEncoding error:&err];
    
    if(fileContents) {
        //search for vagrant NFS paths
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"#\\s+VAGRANT-BEGIN[^\\n]*\n\"([^\"]*)\"[^\\n]*\\n#\\s+VAGRANT-END" options:0 error:NULL];
        NSArray *matches = [regex matchesInString:fileContents options:0 range:NSMakeRange(0, [fileContents length])];
        for(NSTextCheckingResult *match in matches) {
            NSRange pathRange = [match rangeAtIndex:1];
            
            //found valid NFS path definition, check for Vagrantfile
            NSString *path = [fileContents substringWithRange:pathRange];
            
            if([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/Vagrantfile", path]]) {
                [paths addObject:path];
            }
        }
    }
    
    return [NSArray arrayWithArray:paths];
}

@end
