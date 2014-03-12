//
//  Bookmark.m
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import "Bookmark.h"

@implementation Bookmark

- (void)loadId {
    NSString *idFilePath = [self.path stringByAppendingPathComponent:@"/.vagrant/machines/default/virtualbox/id"];
    
    if([[NSFileManager defaultManager] isReadableFileAtPath:idFilePath]) {
        NSError *err;
        NSString *machineId = [NSString stringWithContentsOfFile:idFilePath encoding:NSUTF8StringEncoding error:&err];
        
        if(!err) {
            self.uuid = machineId;
        }
    }
}

@end
