#import "Environment.h"

@implementation Environment

static Environment *sharedInstance = nil;

- (void)initSharedInstance {
    self.configurationName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"Configuration"];
    
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *envsPListPath = [bundle pathForResource:@"Environments" ofType:@"plist"];
    
    self.environments = [[NSDictionary alloc] initWithContentsOfFile:envsPListPath];
    
    self.aboutURL = [self getStringForKey:@"about_url"];
    self.githubURL = [self getStringForKey:@"github_url"];
    self.appInfoURL = [self getStringForKey:@"app_info_url"];
}

+ (Environment*)sharedInstance {
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [[self alloc] init];
            [sharedInstance initSharedInstance];
        }
        return sharedInstance;
    }
}

- (NSString*)getStringForKey:(NSString*)key {
    return [self getStringForKey:key withDefaultValue:nil];
}

- (NSString*)getStringForKey:(NSString*)key withDefaultValue:(NSString*)defaultValue {
    NSString *val = [[self.environments objectForKey:self.configurationName] objectForKey:key];
    
    if(!val) {
        val = [[self.environments objectForKey:@"_default"] objectForKey:key];
    }
    
    if(!val) {
        val = defaultValue;
    }
    
    return val;
}

@end
