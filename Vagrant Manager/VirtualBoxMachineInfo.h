//
//  VirtualBoxMachineInfo.h
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

@interface VirtualBoxMachineInfo : NSObject

@property (strong, nonatomic) NSString *uuid;
@property (strong, nonatomic) NSString *stateString;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *os;
@property (strong, nonatomic) NSDictionary *sharedFolders;
@property (strong, nonatomic) NSDictionary *properties;

+ (VirtualBoxMachineInfo*)initWithInfo:(NSString*)infoString;

- (NSString*)getSharedFolderPathWithName:(NSString*)name;

@end
