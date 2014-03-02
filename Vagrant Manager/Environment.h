@interface Environment : NSObject

@property (strong, nonatomic) NSString *buyURL;
@property (strong, nonatomic) NSString *aboutURL;
@property (strong, nonatomic) NSDictionary *environments;
@property (strong, nonatomic) NSString *configurationName;

+ (Environment*)sharedInstance;

@end
