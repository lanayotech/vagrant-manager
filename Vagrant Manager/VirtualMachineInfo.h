//
//  VirtualMachineInfo.h
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Bookmark.h"

@interface VirtualMachineInfo : NSObject

@property (strong, nonatomic) Bookmark *bookmark;
@property (strong, nonatomic) NSString *uuid;
@property (strong, nonatomic) NSString *state;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *os;
@property (strong, nonatomic) NSDictionary *sharedFolders;
@property (strong, nonatomic) NSDictionary *properties;

+ (VirtualMachineInfo*)fromInfo:(NSString*)infoString;

- (NSString*)getSharedFolderPathWithName:(NSString*)name;
- (BOOL)isRunning;

@end
