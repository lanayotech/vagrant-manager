//
//  Bookmark.m
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import "Bookmark.h"

@implementation Bookmark

- (id)copyWithZone:(NSZone*)zone {
    Bookmark *bookmark = [[[self class] allocWithZone:zone] init];
    
    if(bookmark) {
        bookmark.displayName = self.displayName;
        bookmark.path = self.path;
        bookmark.providerIdentifier = self.providerIdentifier;
    }
    
    return bookmark;
}

@end
