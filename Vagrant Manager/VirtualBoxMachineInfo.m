//
//  VirtualBoxMachineInfo.m
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import "VirtualBoxMachineInfo.h"

@implementation VirtualBoxMachineInfo

+ (VirtualBoxMachineInfo*)initWithInfo:(NSString*)infoString :(id<VirtualMachineServiceProvider>)provider {
    VirtualBoxMachineInfo *vm = [[VirtualBoxMachineInfo alloc] init];
    
    NSArray *infoArray = [infoString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    NSMutableDictionary *infoPairs = [[NSMutableDictionary alloc] init];
    
    NSMutableDictionary *sharedFolders = [[NSMutableDictionary alloc] init];
    
    for(NSString *infoLine in infoArray) {
        NSString *name;
        NSString *value;
        
        NSRange equalRange = [infoLine rangeOfString:@"="];
        if(equalRange.length == 0) {
            continue;
        }
        
        name = [infoLine substringToIndex:equalRange.location];
        value = [infoLine substringFromIndex:equalRange.location + 1];
        
        if([[name substringToIndex:1] isEqualToString:@"\""]) {
            name = [name substringWithRange:NSMakeRange(1, name.length - 2)];
        }
        
        if([[value substringToIndex:1] isEqualToString:@"\""]) {
            value = [value substringWithRange:NSMakeRange(1, value.length - 2)];
        }
        
        if([name isEqualToString:@"name"]) {
            vm.name = value;
        } else if([name isEqualToString:@"ostype"]) {
            vm.os = value;
        } else if([name isEqualToString:@"UUID"]) {
            vm.uuid = value;
        } else if([name isEqualToString:@"VMState"]) {
            vm.state = value;
        } else if([name hasPrefix:@"SharedFolderNameMachineMapping"] || [name hasPrefix:@"SharedFolderPathMachineMapping"]) {
            NSString *mappingId = [name substringFromIndex:30];
            if(![sharedFolders objectForKey:mappingId]) {
                [sharedFolders setObject:[[NSMutableDictionary alloc] init] forKey:mappingId];
            }
            if([name hasPrefix:@"SharedFolderNameMachineMapping"]) {
                [[sharedFolders objectForKey:mappingId] setObject:value forKey:@"name"];
            } else if([name hasPrefix:@"SharedFolderPathMachineMapping"]) {
                [[sharedFolders objectForKey:mappingId] setObject:value forKey:@"path"];
            }
        } else {
            [infoPairs setObject:value forKey:name];
        }
    }
    
    NSMutableDictionary *validSharedFolders = [[NSMutableDictionary alloc] init];
    for(NSMutableDictionary *sharedFolderKey in sharedFolders) {
        NSMutableDictionary *sharedFolder = [sharedFolders objectForKey:sharedFolderKey];
        [validSharedFolders setObject:[sharedFolder objectForKey:@"path"] forKey:[sharedFolder objectForKey:@"name"]];
    }
    
    vm.properties = [NSDictionary dictionaryWithDictionary:infoPairs];
    vm.sharedFolders = [NSDictionary dictionaryWithDictionary:validSharedFolders];
    vm.provider = provider;
    
    return vm;
}

@end
