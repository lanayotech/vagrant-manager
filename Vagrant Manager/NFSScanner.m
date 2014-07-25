//
//  NfsScanner.m
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import "NFSScanner.h"

@implementation NFSScanner

- (NSArray*)getNFSInstancePaths {
    NSMutableArray *paths = [[NSMutableArray alloc] init];
    
    //get contents of /etc/exports
    NSError *err;
    NSString *fileContents = [NSString stringWithContentsOfFile:@"/etc/exports" encoding:NSUTF8StringEncoding error:&err];
    
    if(fileContents) {
        //search for vagrant NFS paths
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"#\\s+VAGRANT-BEGIN[^\\n]*\n\"([^\"]*)\"[^\\n]*\\n#\\s+VAGRANT-END" options:0 error:NULL];
        NSArray *matches = [regex matchesInString:fileContents options:0 range:NSMakeRange(0, [fileContents length])];
        for(NSTextCheckingResult *match in matches) {
            NSRange pathRange = [match rangeAtIndex:1];
            
            //found valid NFS path definition, check for Vagrantfile
            NSString *path = [fileContents substringWithRange:pathRange];
            
            if([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/Vagrantfile", path]]) {
                [paths addObject:path];
            }
        }
    }
    
    return [NSArray arrayWithArray:paths];
}

@end
