//
//  TextMenuItem.h
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TextMenuItem : NSView

@property (strong, nonatomic) NSString *itemId;
@property BOOL hasTopBorder;

@property (weak) IBOutlet NSImageView *imageView;
@property (weak) IBOutlet NSTextField *textField;

@end
