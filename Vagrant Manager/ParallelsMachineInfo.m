//
//  ParallelsMachineInfo.m
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import "ParallelsMachineInfo.h"

@implementation ParallelsMachineInfo

//get a shared folder path by its name
- (NSString*)getSharedFolderPathWithName:(NSString*)name {
    NSString *folder = [self.sharedFolders objectForKey:name];
    if(!folder && [[name substringToIndex:1] isEqualToString:@"/"]) {
        folder = [self.sharedFolders objectForKey:[name substringFromIndex:1]];
    }
    
    return folder;
}

//parse Parallels machine info
+ (ParallelsMachineInfo*)initWithInfo:(NSDictionary*)infoDictionary {
    ParallelsMachineInfo *vm = [[ParallelsMachineInfo alloc] init];
    
    NSMutableDictionary *sharedFolders = [[NSMutableDictionary alloc] init];
    
    vm.name = [infoDictionary objectForKey:@"Name"];
    vm.os = [infoDictionary objectForKey:@"OS"];
    vm.uuid = [infoDictionary objectForKey:@"ID"];
    vm.stateString = [infoDictionary objectForKey:@"State"];
    for(NSString *shareName in [[infoDictionary objectForKey:@"Host Shared Folders"] allKeys]) {
        id shareData = [[infoDictionary objectForKey:@"Host Shared Folders"] objectForKey:shareName];
        if([shareData isKindOfClass:[NSDictionary class]] && [shareData objectForKey:@"path"]) {
            [sharedFolders setObject:[shareData objectForKey:@"path"] forKey:shareName];
        }
    }
    
    //TODO: parse the rest of the properties into a single dimensional array
    //vm.properties = [NSDictionary dictionaryWithDictionary:infoPairs];
    
    vm.sharedFolders = sharedFolders;
    
    return vm;
}

@end
