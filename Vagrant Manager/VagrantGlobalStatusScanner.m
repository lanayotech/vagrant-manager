//
//  VagrantGlobalStatusScanner.m
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import "VagrantGlobalStatusScanner.h"

@implementation VagrantGlobalStatusScanner

//find vagrant instances listed in the vagrant global-status command output
- (NSArray*)getInstancePaths {
    NSMutableArray *paths = [[NSMutableArray alloc] init];
    
    //get output of vagrant global-status
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/bash"];
    [task setArguments:@[@"-l", @"-c", @"vagrant global-status"]];
    
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardInput:[NSPipe pipe]];
    [task setStandardOutput:pipe];
    
    [task launch];
    [task waitUntilExit];
    
    if(task.terminationStatus == 0) {
        //parse instance info from global-status output
        NSData *outputData = [[pipe fileHandleForReading] readDataToEndOfFile];
        NSString *outputString = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
        
        //search for machine state in output string
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(\\S+)\\s+(\\S+)\\s+(\\S+)\\s+(\\S+)\\s+(\\/.*)(\\n|$)" options:0 error:NULL];
        NSArray *matches = [regex matchesInString:outputString options:0 range:NSMakeRange(0, [outputString length])];
        for(NSTextCheckingResult *match in matches) {
            //NSRange idRange = [match rangeAtIndex:1];
            //NSRange nameRange = [match rangeAtIndex:2];
            //NSRange providerRange = [match rangeAtIndex:3];
            //NSRange stateRange = [match rangeAtIndex:4];
            NSRange pathRange = [match rangeAtIndex:5];
            
            NSString *path = [[outputString substringWithRange:pathRange] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            BOOL vagrantFileExists = [[NSFileManager defaultManager] fileExistsAtPath:[NSString pathWithComponents:@[path, @"/Vagrantfile"]]];
            
            if(vagrantFileExists) {
                [paths addObject:path];
            }
        }
    }
    
    return [NSArray arrayWithArray:paths];
}

@end
