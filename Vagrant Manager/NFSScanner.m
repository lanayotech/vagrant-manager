//
//  NfsScanner.m
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import "NFSScanner.h"

@implementation NFSScanner

//find vagrant instances in the NFS exports file
- (NSArray*)getNFSInstancePaths {
    NSMutableArray *paths = [[NSMutableArray alloc] init];
    
    //get contents of /etc/exports
    NSError *err;
    NSString *fileContents = [NSString stringWithContentsOfFile:@"/etc/exports" encoding:NSUTF8StringEncoding error:&err];
    
    if(fileContents) {
        //search for vagrant NFS paths
        NSMutableArray *lines = [[fileContents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] mutableCopy];
        [lines removeObject:@""];
        
        for(NSString *line in lines) {
            
            if([line rangeOfString:@"# VAGRANT-"].location != NSNotFound) {
                continue;
            }
            
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(?<!\\\\)\"((?:\\\\\"|[^\"])*+)\"" options:0 error:nil];
            NSArray *pathArr = [regex matchesInString:line options:0 range:NSMakeRange(0, [line length])];
            for (NSTextCheckingResult *pathResult in pathArr) {
                if (pathResult.range.length > 1) {
                    NSString *path = [line substringWithRange:[pathResult rangeAtIndex:1]];
                    BOOL vagrantFileExists = [[NSFileManager defaultManager] fileExistsAtPath:[NSString pathWithComponents:@[path, @"Vagrantfile"]]];
                    
                    if(vagrantFileExists) {
                        [paths addObject:path];
                    }
                }
            }
        }
    }
    
    return [NSArray arrayWithArray:paths];
}

@end
