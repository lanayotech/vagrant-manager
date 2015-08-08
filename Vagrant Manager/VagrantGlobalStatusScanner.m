//
//  VagrantGlobalStatusScanner.m
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import "VagrantGlobalStatusScanner.h"

@implementation VagrantGlobalStatusScanner

//find vagrant instances listed in the vagrant global-status command output
- (NSMutableDictionary*)getInstances {
    NSMutableDictionary *instancePathDict = [NSMutableDictionary dictionary];
    
    //get output of vagrant global-status
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/bash"];
    [task setArguments:@[@"-l", @"-c", @"vagrant global-status --prune 2> /dev/null"]];
    
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardInput:[NSPipe pipe]];
    [task setStandardOutput:pipe];
    
    [task launch];
    [task waitUntilExit];
    
    if(task.terminationStatus == 0) {
        //parse instance info from global-status output
        NSData *outputData = [[pipe fileHandleForReading] readDataToEndOfFile];
        NSString *outputString = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
        
        NSRange headerRange = [[NSRegularExpression regularExpressionWithPattern:@"^id\\s+name\\s+provider\\s+state\\s+directory" options:NSRegularExpressionAnchorsMatchLines error:nil] rangeOfFirstMatchInString:outputString options:0 range:NSMakeRange(0, outputString.length)];
        
        if (headerRange.location == NSNotFound) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[Util getApp] showNotificationWithTitle:@"Invalid Output" informativeText:@"`vagrant global-status --prune` output invalid, run command in terminal window to verify" taskWindowUUID:nil];
            });
            
            return instancePathDict;
        }
        
        NSString *header = [outputString substringWithRange:headerRange];
        
        NSRange range = [header rangeOfString:@"name"];
        NSInteger nameIndex = (unsigned long)range.location;
        
        range = [header rangeOfString:@"provider"];
        NSInteger providerIndex = (unsigned long)range.location;
        
        range = [header rangeOfString:@"state"];
        NSInteger stateIndex = (unsigned long)range.location;
        
        range = [header rangeOfString:@"directory"];
        NSInteger directoryIndex = (unsigned long)range.location;
        
        //search for machine state in output string
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^([a-z0-9]{7}\\s.*)" options:NSRegularExpressionAnchorsMatchLines error:NULL];
        NSArray *matches = [regex matchesInString:outputString options:0 range:NSMakeRange(0, [outputString length])];
        
        for(NSTextCheckingResult *match in matches) {
            NSRange matchRange = [match rangeAtIndex:1];
            NSString *line = [[outputString substringWithRange:matchRange] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            NSString *machineName = [[line substringWithRange: NSMakeRange(nameIndex, providerIndex-nameIndex)] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            NSString *machineProvider = [[line substringWithRange: NSMakeRange(providerIndex, stateIndex-providerIndex)] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            NSString *machineState = [[line substringWithRange: NSMakeRange(stateIndex, directoryIndex-stateIndex)] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            NSString *machineDirectory = [[line substringWithRange: NSMakeRange(directoryIndex, line.length-directoryIndex)] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            BOOL vagrantFileExists = [[NSFileManager defaultManager] fileExistsAtPath:[NSString pathWithComponents:@[machineDirectory, @"/Vagrantfile"]]];
            
            if(vagrantFileExists) {
                VagrantInstance *instance = nil;
                
                if ([instancePathDict objectForKey:machineDirectory]) {
                    instance = [instancePathDict valueForKey:machineDirectory];
                } else {
                    instance = [[VagrantInstance alloc] initWithPath:machineDirectory providerIdentifier:machineProvider];
                }
                
                VagrantMachine *machine = [[VagrantMachine alloc] initWithInstance:instance name:machineName state:UnknownState];
                machine.stateString = machineState;
                
                [instance.machines addObject:machine];
                instancePathDict[machineDirectory] = instance;
            }
        }
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[Util getApp] showNotificationWithTitle:@"Refresh Error" informativeText:@"`vagrant global-status --prune` command encountered an error, run command in a terminal window to debug" taskWindowUUID:nil];
        });
    }
    
    return instancePathDict;
}

@end
