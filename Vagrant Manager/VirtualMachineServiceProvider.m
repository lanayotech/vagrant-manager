//
//  VirtualMachineServiceProvider.m
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import "VirtualMachineServiceProvider.h"

@implementation VirtualMachineServiceProvider

+ (NSArray*)getAllVirtualMachinesWithInfo {
    NSMutableArray *vagrantMachines = [[NSMutableArray alloc] init];
    
    NSMutableArray *vmUuids = [self getAllVirtualMachineUuids];
    
    NSArray *nfsVirtualMachines = [self getAllNFSVagrantMachinesWithInfo];
    
    for (VirtualMachineInfo *vmInfo in nfsVirtualMachines) {
        [vmUuids removeObject:vmInfo.uuid];
    }
    
    NSArray *otherVirtualMachines = [self getAllVagrantMachinesWithInfo:vmUuids];
    
    [vagrantMachines addObjectsFromArray:nfsVirtualMachines];
    [vagrantMachines addObjectsFromArray:otherVirtualMachines];
    
    return [[NSArray alloc] initWithArray:vagrantMachines];
}

+ (VirtualMachineInfo*)getNFSVirtualMachineInfo:(NSString*)uuid NFSPath:(NSString*)NFSPath {
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
    
    outputString = [NSString stringWithFormat:@"%@%@\n%@", outputString, @"SharedFolderNameMachineMapping1=\"/vagrant\"", [NSString stringWithFormat:@"SharedFolderPathMachineMapping1=\"%@\"", NFSPath]];
    
    if(task.terminationStatus != 0) {
        return nil;
    }
    
    VirtualMachineInfo *vmInfo = [VirtualMachineInfo fromInfo:outputString];
    
    return vmInfo;
}

+ (VirtualMachineInfo*)getVirtualMachineInfo:(NSString*)uuid {
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
    
    if(task.terminationStatus != 0) {
        return nil;
    }
    
    VirtualMachineInfo *vmInfo = [VirtualMachineInfo fromInfo:outputString];
    
    return vmInfo;
}

+ (NSMutableArray*)getAllVirtualMachineUuids {
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/bash"];
    
    [task setArguments:@[@"-c", @"VBoxManage list vms | grep -Eo '[^ ]+$' | sed -e 's/[{}]//g'"]];
    
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardInput:[NSPipe pipe]];
    [task setStandardOutput:pipe];
    
    [task launch];
    [task waitUntilExit];
    
    NSData *outputData = [[pipe fileHandleForReading] readDataToEndOfFile];
    NSString *outputString = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
    
    NSMutableArray *vmUuids = [[outputString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] mutableCopy];
    [vmUuids removeObject:@""];
    
    return vmUuids;
}

+ (NSArray*)getAllVagrantMachinesWithInfo :(NSArray*)uuids {
    NSMutableArray *vagrantMachines = [[NSMutableArray alloc] init];
    
    for (NSString *uuid in uuids) {
         [vagrantMachines addObject:[self getVirtualMachineInfo:uuid]];
    }
    
    return [[NSArray alloc] initWithArray:vagrantMachines];
}

+ (NSArray*)getAllNFSVagrantMachinesWithInfo {
    NSMutableArray *virtualMachines = [[NSMutableArray alloc] init];
    
    if (![[NSFileManager defaultManager] isReadableFileAtPath:@"/etc/exports"]) {
        return [NSArray arrayWithArray:virtualMachines];
    }
    
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/bash"];
    [task setArguments:@[@"-c", @"cat /etc/exports"]];
    
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardInput:[NSPipe pipe]];
    [task setStandardOutput:pipe];
    
    [task launch];
    [task waitUntilExit];
    
    NSData *outputData = [[pipe fileHandleForReading] readDataToEndOfFile];
    NSString *outputString = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
    
    NSMutableArray *lines = [[outputString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] mutableCopy];
    [lines removeObject:@""];
    
    NSString *uuid = @"";
    for(NSString *line in lines) {
        
        if([line rangeOfString:@"# VAGRANT-"].location != NSNotFound) {
            uuid = [[line componentsSeparatedByString:@" "] lastObject];
            continue;
        }
        
        //get path
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(?<=\").*(?=\"\\ [0-9\\.]+)" options:0 error:nil];
        NSArray *pathArr = [regex matchesInString:line options:0 range:NSMakeRange(0, [line length])];
        if (pathArr.count == 1) {
            NSTextCheckingResult *pathResult = [pathArr objectAtIndex:0];
            NSString *path = [line substringWithRange:pathResult.range];
            
            BOOL vagrantFileExists = [[NSFileManager defaultManager] fileExistsAtPath:[NSString pathWithComponents:@[path, @"Vagrantfile"]]];
            
            if (vagrantFileExists && uuid.length) {
                VirtualMachineInfo *vmInfo = [self getNFSVirtualMachineInfo:uuid NFSPath:path];
                if(vmInfo) {
                    [virtualMachines addObject:vmInfo];
                }
            }
        }
    }
    
    return [NSArray arrayWithArray:virtualMachines];
}

+ (NSMutableArray*)sortVirtualMachines:(NSArray*)virtualMachines {
    //sort alphabetically with running machines at the top
    return [[virtualMachines sortedArrayUsingComparator:^(id obj1, id obj2) {
        if ([obj1 isKindOfClass:[VirtualMachineInfo class]] && [obj2 isKindOfClass:[VirtualMachineInfo class]]) {
            VirtualMachineInfo *m1 = obj1;
            VirtualMachineInfo *m2 = obj2;
            
            if ([m1 isRunning] && ![m2 isRunning]) {
                return (NSComparisonResult)NSOrderedAscending;
            } else if (m2.isRunning && !m1.isRunning) {
                return (NSComparisonResult)NSOrderedDescending;
            }
            
            return [m1.name caseInsensitiveCompare:m2.name];
        }
        
        return NSOrderedSame;
    }] mutableCopy];
}


@end
