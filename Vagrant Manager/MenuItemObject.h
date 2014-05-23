//
//  MenuItemObject.h
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MenuItemObject : NSObject

@property (strong) id target;
@property BOOL isExpanded;

- initWithTarget:(id)target;

@end
