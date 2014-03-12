//
//  Bookmark.h
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VirtualMachineInfo.h"

@interface Bookmark : NSObject

@property (strong, nonatomic) NSString *displayName;
@property (strong, nonatomic) NSString *path;
@property (strong, nonatomic) NSString *uuid;

@property (strong, nonatomic) VirtualMachineInfo *machine;

- (void)loadId;

@end
