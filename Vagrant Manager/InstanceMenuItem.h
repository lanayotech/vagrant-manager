//
//  InstanceMenuItem.h
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface InstanceMenuItem : NSViewController

@property (strong) NSString *instancePath;
@property (strong) NSString *displayName;

@property (weak) IBOutlet NSImageView *stateImageView;
@property (weak) IBOutlet NSTextField *nameTextField;
@property BOOL hasChildren;

@end
