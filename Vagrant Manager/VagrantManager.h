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

- (void)addServiceProvider:(id<VirtualMachineServiceProvider>)provider;
- (void)addBookmarkWithPath:(NSString*)path displayName:(NSString*)displayName;
- (void)refreshInstances;
- (Bookmark*)getBookmarkForPath:(NSString*)path;
- (VagrantInstance*)getInstanceForPath:(NSString*)path;
- (int)getRunningVmCount;

@end
