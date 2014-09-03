//
//  VagrantInstanceCollection.h
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VagrantInstance.h"
#import "Bookmark.h"
#import "VirtualMachineServiceProvider.h"

@class VagrantManager;

@protocol VagrantManagerDelegate <NSObject>

- (void)vagrantManager:(VagrantManager*)vagrantManger instanceAdded:(VagrantInstance*)instance;
- (void)vagrantManager:(VagrantManager*)vagrantManger instanceRemoved:(VagrantInstance*)instance;
- (void)vagrantManager:(VagrantManager*)vagrantManger instanceUpdated:(VagrantInstance*)oldInstance withInstance:(VagrantInstance*)newInstance;

@end

@interface VagrantManager : NSObject

@property (weak) id<VagrantManagerDelegate> delegate;

@property (readonly) NSArray *instances;

+ (VagrantManager*)sharedManager;

- (NSArray*)getMachinesWithState:(VagrantMachineState)state;
- (void)registerServiceProvider:(id<VirtualMachineServiceProvider>)provider;
- (void)refreshInstances;
- (VagrantInstance*)getInstanceForPath:(NSString*)path;
- (int)getRunningVmCount;
- (NSString*)detectVagrantProvider:(NSString*)path;
- (NSArray*)getProviderIdentifiers;

@end
