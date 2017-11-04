//
//  VagrantInstanceCollection.m
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import "VagrantManager.h"
#import "NFSScanner.h"
#import "VagrantGlobalStatusScanner.h"
#import "BookmarkManager.h"

@implementation VagrantManager {
    //all known vagrant instances
    NSMutableArray *_instances;
    
    //map provider identifiers to providers
    NSMutableDictionary *_providers;
    
    //this is the first time the machines are being refreshed
    BOOL _isFirstRefresh;
}

+ (VagrantManager*)sharedManager {
    static VagrantManager *manager;
    @synchronized(self) {
        if(manager == nil) {
            manager = [[VagrantManager alloc] init];
        }
    }
    
    return manager;
}

- (id)init {
    self = [super init];
    
    if(self) {
        _instances = [[NSMutableArray alloc] init];
        _providers = [[NSMutableDictionary alloc] init];
        _isFirstRefresh = YES;
    }
    
    return self;
}

//get all instances
- (NSArray*)getInstances {
    return [NSArray arrayWithArray:_instances];
}

//get count of machines in running state
- (int)getRunningVmCount {
    int count = 0;
    
    @synchronized(_instances) {
        for(VagrantInstance *instance in _instances) {
            for(VagrantMachine *machine in instance.machines) {
                if(machine.state == RunningState) {
                    ++count;
                }
            }
        }
    }
    
    return count;
}

//get count of machines in a particular state
- (NSArray*)getMachinesWithState:(VagrantMachineState)state {
    NSMutableArray *machines = [[NSMutableArray alloc] init];
    for(VagrantInstance *instance in _instances) {
        for(VagrantMachine *machine in instance.machines) {
            if(machine.state == state) {
                [machines addObject:machine];
            }
        }
    }
    
    return machines;
}

//register a new service provider
- (void)registerServiceProvider:(id<VirtualMachineServiceProvider>)provider {
    [_providers setObject:provider forKey:[provider getProviderIdentifier]];
}

//get instance at a particular path
- (VagrantInstance*)getInstanceForPath:(NSString*)path {
    path = [Util trimTrailingSlash:path];
    
    for(VagrantInstance *instance in _instances) {
        if([instance.path isEqualToString:path]) {
            return instance;
        }
    }
    
    return nil;
}

//refresh list of instances by querying bookmarks, service providers, and NFS
- (void)refreshInstances {
    NSMutableArray *instances = [[NSMutableArray alloc] init];
    
    BookmarkManager *bookmarkManager = [BookmarkManager sharedManager];

    //create instance for each bookmark
    NSMutableArray *bookmarks = [[BookmarkManager sharedManager] getBookmarks];
    for(Bookmark *bookmark in bookmarks) {
        [instances addObject:[[VagrantInstance alloc] initWithPath:bookmark.path displayName:bookmark.displayName providerIdentifier:bookmark.providerIdentifier]];
    }
    
    NSMutableArray *allPaths = [[NSMutableArray alloc] init];
    
    //scan for NFS exports
    NFSScanner *nfsScanner = [[NFSScanner alloc] init];
    for(NSString *path in [nfsScanner getNFSInstancePaths]) {
        //make sure it is not a bookmark and has not already been detected
        if(![bookmarkManager getBookmarkWithPath:path] && ![allPaths containsObject:path]) {
            [allPaths addObject:path];
            [instances addObject:[[VagrantInstance alloc] initWithPath:path providerIdentifier:nil]];
        }
    }
    
    //scan vagrant global-status output
    VagrantGlobalStatusScanner *globalStatusScanner = [[VagrantGlobalStatusScanner alloc] init];
    for(NSString *path in [globalStatusScanner getInstancePaths]) {
        //make sure it is not a bookmark and has not already been detected
        if(![bookmarkManager getBookmarkWithPath:path] && ![allPaths containsObject:path]) {
            [allPaths addObject:path];
            [instances addObject:[[VagrantInstance alloc] initWithPath:path providerIdentifier:nil]];
        }
    }
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"useProviderMachineDetection"]) {
        //create instance for each detected path
        NSDictionary *detectedPaths = [self detectInstancePaths];
        for(NSString *providerIdentifier in [detectedPaths allKeys]) {
            NSArray *paths = [detectedPaths objectForKey:providerIdentifier];
            for(NSString *path in paths) {
                //make sure it is not a bookmark and has not already been detected
                if(![bookmarkManager getBookmarkWithPath:path] && ![allPaths containsObject:path]) {
                    [allPaths addObject:path];
                    [instances addObject:[[VagrantInstance alloc] initWithPath:path providerIdentifier:providerIdentifier]];
                }
            }
        }
    }

    //TODO: implement "last seen" functionality. Store paths of previously seen Vagrantfiles and check if they still exist
    
    NSMutableArray *validPaths = [[NSMutableArray alloc] init];
    
    //query all known instances for machines, process in parallel
    dispatch_group_t queryMachinesGroup = dispatch_group_create();
    dispatch_queue_t queryMachinesQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    for(VagrantInstance *instance in instances) {
        dispatch_group_async(queryMachinesGroup, queryMachinesQueue, ^{
            //query instance machines
            [instance queryMachines];
            
            @synchronized(_instances) {
                VagrantInstance *existingInstance = [self getInstanceForPath:instance.path];
                if(existingInstance) {
                    //instance already exists, check for changes
                    int idx = (int)[_instances indexOfObject:existingInstance];
                    if(instance.machines.count != existingInstance.machines.count || ![existingInstance.displayName isEqualToString:instance.displayName] || ![existingInstance.providerIdentifier isEqualToString:instance.providerIdentifier]) {
                        //instance has updated
                        [_instances replaceObjectAtIndex:idx withObject:instance];
                        [self.delegate vagrantManager:self instanceUpdated:existingInstance withInstance:instance];
                    } else {
                        for(VagrantMachine *machine in instance.machines) {
                            VagrantMachine *existingMachine = [existingInstance getMachineWithName:machine.name];
                            
                            if(!existingMachine || ![existingMachine.stateString isEqualToString:machine.stateString]) {
                                //machine did not exist, or state has changed
                                [_instances replaceObjectAtIndex:idx withObject:instance];
                                [self.delegate vagrantManager:self instanceUpdated:existingInstance withInstance:instance];
                            }
                        }
                    }
                } else {
                    //new instance
                    [_instances addObject:instance];
                    [self.delegate vagrantManager:self instanceAdded:instance];
                }
                
                //add path to list for pruning stale instances
                [validPaths addObject:instance.path];
            }
        });
    }
    
    //wait for the machine queries to finish
    dispatch_group_wait(queryMachinesGroup, DISPATCH_TIME_FOREVER);
    
    for(int i=(int)_instances.count-1; i>=0; --i) {
        VagrantInstance *instance = [_instances objectAtIndex:i];
        if(![validPaths containsObject:instance.path]) {
            [_instances removeObjectAtIndex:i];
            [self.delegate vagrantManager:self instanceRemoved:instance];
            
            //TODO: "last seen" functionality may have to be implemented here as well so that this instance doesn't disappear from the list during this pass
        } else {
            if(_isFirstRefresh) {
                Bookmark *bookmark = [[BookmarkManager sharedManager] getBookmarkWithPath:instance.path];
                
                if(bookmark && bookmark.launchOnStartup) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[Util getApp] performVagrantAction:@"up" withInstance:instance];
                    });
                }
            }
        }
    }
    
    _isFirstRefresh = NO;
}

//query all service providers for instances
- (NSDictionary*)detectInstancePaths {
    NSMutableArray *allPaths = [[NSMutableArray alloc] init];
    NSMutableDictionary *keyedPaths = [[NSMutableDictionary alloc] init];
    
    //find Vagrant instances for each registered provider
    for(id<VirtualMachineServiceProvider> provider in [_providers allValues]) {
        NSArray *paths = [provider getVagrantInstancePaths];
        NSMutableArray *uniquePaths = [[NSMutableArray alloc] init];
        //make sure we haven't already detected this path
        for(NSString *path in paths) {
            NSString *p = [Util trimTrailingSlash:path];
            if(![allPaths containsObject:p]) {
                [allPaths addObject:p];
                [uniquePaths addObject:p];
            }
        }
        [keyedPaths setObject:uniquePaths forKey:[provider getProviderIdentifier]];
    }
    
    return [NSDictionary dictionaryWithDictionary:keyedPaths];
}

//try to determine the vagrant provider for an instance
- (NSString*)detectVagrantProvider:(NSString*)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSArray *machinePaths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[NSString stringWithFormat:@"%@/.vagrant/machines", path] error:&error];
    
    // check for virtual machine id
    if(!error && machinePaths) {
        for(NSString *machinePath in machinePaths) {
            for(NSString *providerIdentifier in [self getProviderIdentifiers]) {
                if([fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@/.vagrant/machines/%@/%@/id", path, machinePath, providerIdentifier]]) {
                    return providerIdentifier;
                }
            }
        }
    }
    
    // no virtual machine id, check for just an existing provider folder as a fallback
    if(!error && machinePaths) {
        for(NSString *machinePath in machinePaths) {
            for(NSString *providerIdentifier in [self getProviderIdentifiers]) {
                if([fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@/.vagrant/machines/%@/%@", path, machinePath, providerIdentifier]]) {
                    return providerIdentifier;
                }
            }
        }
    }

    return @"virtualbox";
}

- (NSArray*)getProviderIdentifiers {
    NSMutableArray *providerIdentifiers = [NSMutableArray arrayWithArray:[_providers allKeys]];
    [providerIdentifiers addObject:@"vmware_workstation"];
    [providerIdentifiers addObject:@"vmware_fusion"];
    [providerIdentifiers addObject:@"docker"];
    return providerIdentifiers;
}

@end
