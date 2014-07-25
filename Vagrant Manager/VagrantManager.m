//
//  VagrantInstanceCollection.m
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import "VagrantManager.h"

@implementation VagrantManager {
    //all known vagrant instances
    NSMutableArray *_instances;
    
    //bookmarks
    NSMutableArray *_bookmarks;
    
    //map provider identifiers to providers
    NSMutableDictionary *_providers;
}

- (id)init {
    self = [super init];
    
    if(self) {
        _instances = [[NSMutableArray alloc] init];
        _bookmarks = [[NSMutableArray alloc] init];
        _providers = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (NSArray*)getInstances {
    return [NSArray arrayWithArray:_instances];
}

- (void)addServiceProvider:(id<VirtualMachineServiceProvider>)provider {
    [_providers setObject:provider forKey:[provider getProviderIdentifier]];
}

- (Bookmark*)getBookmarkForPath:(NSString*)path {
    for(Bookmark *bookmark in _bookmarks) {
        if([bookmark.path isEqualToString:path]) {
            return bookmark;
        }
    }
    
    return nil;
}

- (VagrantInstance*)getInstanceForPath:(NSString*)path {
    path = [Util trimTrailingSlash:path];
    
    for(VagrantInstance *instance in _instances) {
        if([instance.path isEqualToString:path]) {
            return instance;
        }
    }
    
    return nil;
}

- (void)addBookmarkWithPath:(NSString*)path displayName:(NSString*)displayName {
    if(![self getBookmarkForPath:path]) {
        Bookmark *bookmark = [[Bookmark alloc] init];
        bookmark.path = [Util trimTrailingSlash:path];
        bookmark.displayName = displayName;
        [_bookmarks addObject:bookmark];
    }
}

/*
 Detect all Vagrant machine instances
 */
- (void)refreshInstances {
    NSMutableArray *instances = [[NSMutableArray alloc] init];

    //create instance for each bookmark
    for(Bookmark *bookmark in _bookmarks) {
        [instances addObject:[[VagrantInstance alloc] initWithPath:bookmark.path displayName:bookmark.displayName providerIdentifier:bookmark.providerIdentifier]];
    }
    
    //create instance for each detected path
    NSDictionary *detectedPaths = [self detectInstancePaths];
    for(NSString *providerIdentifier in [detectedPaths allKeys]) {
        NSArray *paths = [detectedPaths objectForKey:providerIdentifier];
        for(NSString *path in paths) {
            //make sure it is not a bookmark
            if(![self getBookmarkForPath:path]) {
                [instances addObject:[[VagrantInstance alloc] initWithPath:path providerIdentifier:providerIdentifier]];
            }
        }
    }
    
    //TODO: implement "last seen" functionality. Store paths of previously seen Vagrantfiles and check if they still exist
    
    NSMutableArray *validPaths = [[NSMutableArray alloc] init];
    
    //handle all known instances, process in parallel
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
                    if(instance.machines.count != existingInstance.machines.count) {
                        //different machine count for instance
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
    
    // you can do this to synchronously wait on the current thread:
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

/*
 Query providers for all Vagrant instance paths
 */
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

@end
