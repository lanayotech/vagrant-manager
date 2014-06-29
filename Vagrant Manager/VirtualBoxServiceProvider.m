//
//  VirtualBoxServiceProvider.m
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import "VirtualBoxServiceProvider.h"

@implementation VirtualBoxServiceProvider

- (NSArray*)getAllVagrantMachines {
    NSMutableArray *virtualMachines = [self getAllVirtualMachinesWithInfo];
    NSMutableArray *vagrantMachines = [[NSMutableArray alloc] init];
    
    for(VirtualBoxMachineInfo *vmInfo in virtualMachines) {
        Bookmark *bookmark = [[Util getApp] getBookmarkById:vmInfo.uuid];
        if(bookmark) {
            bookmark.machine = vmInfo;
        } else if([vmInfo getSharedFolderPathWithName:@"/vagrant"]) {
            [vagrantMachines addObject:vmInfo];
        }
    }
    
    return vagrantMachines;
}

- (VirtualBoxMachineInfo*)getVagrantMachineInfo:(NSString *)uuid {
    return [self getVirtualMachineInfo:uuid];
}

- (VirtualBoxMachineInfo*)getVagrantMachineInfo:(NSString *)uuid :(NSString*)NFSPath {
    return [self getVirtualMachineInfo:uuid NFSPath:NFSPath];
}

- (NSMutableArray*)getAllVirtualMachinesWithInfo {
    NSMutableArray *vagrantMachines = [[NSMutableArray alloc] init];
    
    NSMutableArray *vmUuids = [self getAllVirtualMachineUuids];
    
    NSArray *nfsVirtualMachines = [self getAllNFSVagrantMachinesWithInfo];
    
    for (VirtualBoxMachineInfo *vmInfo in nfsVirtualMachines) {
        [vmUuids removeObject:vmInfo.uuid];
    }
    
    NSArray *otherVirtualMachines = [self getAllVagrantMachinesWithInfo:vmUuids];
    
    [vagrantMachines addObjectsFromArray:nfsVirtualMachines];
    [vagrantMachines addObjectsFromArray:otherVirtualMachines];
    
    return vagrantMachines;
}

- (VirtualBoxMachineInfo*)getVirtualMachineInfo:(NSString*)uuid NFSPath:(NSString*)NFSPath {
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
    
    VirtualBoxMachineInfo *vmInfo = [VirtualBoxMachineInfo initWithInfo:outputString :[[[Util getApp] getServiceProviders] objectForKey:@"VirtualBoxServiceProvider"]];
    
    return vmInfo;
}

- (VirtualBoxMachineInfo*)getVirtualMachineInfo:(NSString*)uuid {
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
    
    VirtualBoxMachineInfo *vmInfo = [VirtualBoxMachineInfo initWithInfo:outputString :[[[Util getApp] getServiceProviders] objectForKey:@"VirtualBoxServiceProvider"]];
    
    return vmInfo;
}

- (NSMutableArray*)getAllVirtualMachineUuids {
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

- (NSArray*)getAllVagrantMachinesWithInfo :(NSArray*)uuids {
    NSMutableArray *vagrantMachines = [[NSMutableArray alloc] init];
    
    for (NSString *uuid in uuids) {
        [vagrantMachines addObject:[self getVirtualMachineInfo:uuid]];
    }
    
    return [[NSArray alloc] initWithArray:vagrantMachines];
}

- (NSArray*)getAllNFSVagrantMachinesWithInfo {
    NSMutableArray *virtualMachines = [[NSMutableArray alloc] init];
    
    if (![[NSFileManager defaultManager] isReadableFileAtPath:@"/etc/exports"]) {
        return [NSArray arrayWithArray:virtualMachines];
    }
    
    NSString *exports = [NSString stringWithContentsOfFile:@"/etc/exports" encoding:NSUTF8StringEncoding error:nil];
    
    NSMutableArray *lines = [[exports componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] mutableCopy];
    [lines removeObject:@""];
    
    NSString *uuid = @"";
    for(NSString *line in lines) {
        
        if([line rangeOfString:@"# VAGRANT-"].location != NSNotFound) {
            uuid = [[line componentsSeparatedByString:@" "] lastObject];
            continue;
        }
        
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(?<!\\\\)\"((?:\\\\\"|[^\"])*+)\"" options:0 error:nil];
        NSArray *pathArr = [regex matchesInString:line options:0 range:NSMakeRange(0, [line length])];
        for (NSTextCheckingResult *pathResult in pathArr) {
            if (pathResult.range.length > 1) {
                NSString *path = [line substringWithRange:[pathResult rangeAtIndex:1]];
                BOOL vagrantFileExists = [[NSFileManager defaultManager] fileExistsAtPath:[NSString pathWithComponents:@[path, @"Vagrantfile"]]];
                
                if (vagrantFileExists && uuid.length) {
                    VirtualBoxMachineInfo *vmInfo = [self getVirtualMachineInfo:uuid NFSPath:path];
                    if(vmInfo) {
                        [virtualMachines addObject:vmInfo];
                    }
                }
            }
        }
    }
    
    return [NSArray arrayWithArray:virtualMachines];
}

@end
