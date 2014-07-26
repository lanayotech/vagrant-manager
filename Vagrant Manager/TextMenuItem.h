//
//  TextMenuItem.h
//  Vagrant Manager
//
//  Created by Chris Ayoub on 7/26/14.
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TextMenuItem : NSView

@property (strong, nonatomic) NSString *itemId;
@property BOOL hasTopBorder;

@property (weak) IBOutlet NSImageView *imageView;
@property (weak) IBOutlet NSTextField *textField;

@end
