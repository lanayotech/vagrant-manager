//
//  VagrantInstance.m
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import "VagrantInstance.h"

@implementation VagrantInstance {
    NSString *_path;
    NSString *_displayName;
    NSMutableArray *_machines;
}

- (id)initWithPath:(NSString*)path displayName:(NSString*)displayName providerIdentifier:(NSString*)providerIdentifier {
    self = [self initWithPath:path providerIdentifier:providerIdentifier];
    
    if(self) {
        _displayName = displayName;
    }
    
    return self;
}

- (id)initWithPath:(NSString*)path providerIdentifier:(NSString*)providerIdentifier {
    self = [super init];
    
    if(self) {
        //provider identifier not passed in, try to determine it
        if(!providerIdentifier || [providerIdentifier length] == 0) {
            providerIdentifier = [[VagrantManager sharedManager] detectVagrantProvider:path];
        }
        _path = path;
        self.providerIdentifier = providerIdentifier;
        
        //get display name based on last part of path
        NSArray *parts = [path componentsSeparatedByString:@"/"];
        _displayName = [[parts lastObject] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if(_displayName.length < 1) {
            _displayName = @"Unknown";
        }
        
        _machines = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (NSString*)getPath {
    return _path;
}

- (NSString*)getDisplayName {
    return _displayName;
}

- (int)getRunningMachineCount {
    int runningCount = 0;
    for(VagrantMachine *machine in _machines) {
        if(machine.state == RunningState) {
            ++runningCount;
        }
    }
    
    return runningCount;
}

- (BOOL)hasVagrantfile {
    return [self getVagrantfilePath]!=nil;
}

- (NSString*)getVagrantfilePath {
    NSString *filePath = [NSString stringWithFormat:@"%@/Vagrantfile", _path];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return filePath;
    } else {
        return nil;
    }
}

- (VagrantMachine*)getMachineWithName:(NSString*)name {
    for(VagrantMachine *machine in _machines) {
        if([machine.name isEqualToString:name]) {
            return machine;
        }
    }
    
    return nil;
}

- (NSArray*)getMachines {
    return [NSArray arrayWithArray:_machines];
}

- (int)getMachineCountWithState:(VagrantMachineState)state {
    int count = 0;
    
    for(VagrantMachine *machine in _machines) {
        if(machine.state == state) {
            count++;
        }
    }
    
    return count;
}

@end
