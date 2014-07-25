//
//  InstanceMenuItem.h
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "VagrantInstance.h"

@class InstanceMenuItem;

@protocol InstanceMenuItemDelegate <NSObject>

- (void)instanceMenuItem:(InstanceMenuItem*)menuItem toggleOpenButtonClicked:(id)sender;

@end

@interface InstanceMenuItem : NSView

@property id<InstanceMenuItemDelegate> delegate;

@property (weak) IBOutlet NSImageView *stateImageView;
@property (weak) IBOutlet NSTextField *nameTextField;
@property (weak) IBOutlet NSButton *toggleOpenButton;

@property (strong, nonatomic) VagrantInstance *instance;

- (IBAction)toggleOpenButtonClicked:(id)sender;

@end
