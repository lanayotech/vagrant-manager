//
//  VagrantInstanceCollection.m
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import "VagrantManager.h"
#import "VagrantGlobalStatusScanner.h"
#import "BookmarkManager.h"

@implementation VagrantManager {
    //all known vagrant instances
    NSMutableArray *_instances;
    
    //map provider identifiers to providers
    NSMutableDictionary *_providers;
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
    
    //scan vagrant global-status output
    VagrantGlobalStatusScanner *globalStatusScanner = [[VagrantGlobalStatusScanner alloc] init];
    NSMutableDictionary *instancesPathDict = [globalStatusScanner getInstances];
    
    BookmarkManager *bookmarkManager = [BookmarkManager sharedManager];
    NSArray *bookmarks = [bookmarkManager getBookmarks];
    
    //add bookmark instances and go through all bookmarks to override display name and provider identifier
    for (Bookmark *bookmark in bookmarks) {
        if ([instancesPathDict objectForKey:bookmark.path]) {
            VagrantInstance *instance = [instancesPathDict objectForKey:bookmark.path];
            instance.displayName = bookmark.displayName;
            instance.providerIdentifier = bookmark.providerIdentifier;
        } else {
            instancesPathDict[bookmark.path] = [[VagrantInstance alloc] initWithPath:bookmark.path displayName:bookmark.displayName providerIdentifier:bookmark.providerIdentifier];
        }
    }

    //TODO: implement "last seen" functionality. Store paths of previously seen Vagrantfiles and check if they still exist
    NSMutableArray *validPaths = [[NSMutableArray alloc] init];
    
    //query all known instances for machines, process in parallel
    dispatch_group_t queryMachinesGroup = dispatch_group_create();
    dispatch_queue_t queryMachinesQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    for(VagrantInstance *instance in [instancesPathDict allValues]) {
        dispatch_group_async(queryMachinesGroup, queryMachinesQueue, ^{
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
        }
    }
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
