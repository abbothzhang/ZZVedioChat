//
//  UserConfig.m
//  AVTest
//
//

#import "UserConfig.h"

NSString* DefaultUserIDKey=@"DefaultUser.Id";

NSString* Identifier=@"id";

NSString* UserOpenIdKey=@"id";
NSString* UserNameKey=@"name";
NSString* UserTokenKey=@"sdkAppIdToken";

@implementation UserConfig

+(UserConfig*)shareConfig
{
    static UserConfig* userConfig=nil;
    if (userConfig==nil) {
        userConfig=[[UserConfig alloc] init];
        
        [userConfig loadAppSetting];

        if(userConfig.sdkAppId==nil){
            [userConfig resetAppSetting];
        }
#if _BUILD_FOR_TLS
        NSArray* users = [NSArray array];
#else
        NSArray* users= [NSArray arrayWithObjects:
                                                    @{@"id":@"辉哥"},
                                                  @{@"id":@"st"},
                                                  @{@"id":@"2208137703"},
                                                  @{@"id":@"2378730536"},
                                                  @{@"id":@"3201632112"},
                                                  @{@"id":@"2411439453"},
                                                  @{@"id":@"2873331836"},
                                                  @{@"id":@"2310998392"},
                                                  @{@"id":@"31726276"},
                                                  @{@"id":@"2696020827"},
                                                  @{@"id":@"这里的用户名可以随便填"},
                                                    nil];
#endif

        [userConfig.testUsers addObjectsFromArray:users];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDirectory = [paths objectAtIndex:0];
        NSString *docPath = [documentDirectory stringByAppendingPathComponent:@"user_config.plist"];
        
        NSArray* fileUsers=[NSArray arrayWithContentsOfFile:docPath];
        if (fileUsers.count==0) {
            // todo
        }else{
            [userConfig.testUsers addObjectsFromArray:fileUsers];
        }
        
        
        NSString* userId=[[NSUserDefaults standardUserDefaults] objectForKey:DefaultUserIDKey];
        
        [userConfig setCurrentUserWithOpenId:userId];
    }
    
    return userConfig;
}
-(id)init
{
    self=[super init];
    if (self) {
        _testUsers=[[NSMutableArray alloc] init];
    }
    return self;
}
-(void)dealloc{
    [_testUsers release];
    [_currentUser release];
    [super dealloc];
}
-(void)setCurrentUserWithOpenId:(NSString*)openId
{
    NSDictionary* defaultUser=nil;
    if (openId!=nil) {
        NSPredicate *aPredicate = [NSPredicate predicateWithFormat:@"SELF.id=%@", openId];
        NSArray* defaultUsers=[self.testUsers filteredArrayUsingPredicate:aPredicate];
        if (defaultUsers.count>0) {
            defaultUser=[defaultUsers objectAtIndex:0];
        }
    }
    if ([self.testUsers count] == 0)
        return;
    if (!defaultUser) {
        defaultUser=[self.testUsers objectAtIndex:0];
    }
    
    self.currentUser=defaultUser;
    
    [[NSUserDefaults standardUserDefaults] setObject:self.currentUser[@"id"] forKey:DefaultUserIDKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
-(void)addUserToConfigWithId:(NSString*)openId
{
    NSDictionary* user=[NSDictionary dictionaryWithObjectsAndKeys:openId,@"id", nil];
    [_testUsers addObject:user];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSString *docPath = [documentDirectory stringByAppendingPathComponent:@"user_config.plist"];
    
    NSMutableArray* fileUsers=[NSMutableArray arrayWithContentsOfFile:docPath];
    if ([fileUsers count] == 0){
        NSArray* example=[NSArray arrayWithObject:@{@"id":openId}];
        [example writeToFile:docPath atomically:YES];
        
        NSMutableArray* fileUsers=[NSMutableArray arrayWithContentsOfFile:docPath];
    }
    
    [fileUsers addObject:user];
    [fileUsers writeToFile:docPath atomically:YES];

}
-(void)loadAppSetting{
    self.AppIdThird=[[NSUserDefaults standardUserDefaults] objectForKey:@"openAppId"];
    self.sdkAppId=[[NSUserDefaults standardUserDefaults] objectForKey:@"sdkAppId"];
    self.accountType= [[NSUserDefaults standardUserDefaults] objectForKey:@"uidType"];
    self.isTestServer = [[NSUserDefaults standardUserDefaults] boolForKey:@"testserver"];
    self.roomId = [[NSUserDefaults standardUserDefaults] integerForKey:@"roomid"];
    self.audioInputName= [[NSUserDefaults standardUserDefaults] objectForKey:@"audioInputName"];
    self.audioOutputName= [[NSUserDefaults standardUserDefaults] objectForKey:@"audioOutputName"];
    self.audioSr= [[NSUserDefaults standardUserDefaults] objectForKey:@"audioSr"];
    self.audioChn= [[NSUserDefaults standardUserDefaults] objectForKey:@"audioChn"];
    self.sdkAppIdToken=[[NSUserDefaults standardUserDefaults] objectForKey:@"sdkAppIdToken"];
    self.authAudioSend= [[NSUserDefaults standardUserDefaults] boolForKey:@"authAudioSend"];
    self.authAudioRev= [[NSUserDefaults standardUserDefaults] boolForKey:@"authAudioRev"];
    self.authVideoSend= [[NSUserDefaults standardUserDefaults] boolForKey:@"authVideoSend"];
    self.authVideoRev= [[NSUserDefaults standardUserDefaults] boolForKey:@"authVideoRev"];
    self.categoryNum = 0;
}

-(void)saveAppSetting{
    [[NSUserDefaults standardUserDefaults] setObject:self.AppIdThird forKey:@"openAppId"];
    [[NSUserDefaults standardUserDefaults] setObject:self.sdkAppId forKey:@"sdkAppId"];
    [[NSUserDefaults standardUserDefaults] setObject:self.accountType forKey:@"uidType"];
    [[NSUserDefaults standardUserDefaults] setBool:self.isTestServer forKey:@"testserver"];
    [[NSUserDefaults standardUserDefaults] setInteger:self.roomId forKey:@"roomid"];
    [[NSUserDefaults standardUserDefaults] setObject:self.audioOutputName forKey:@"audioOutputName"];
    [[NSUserDefaults standardUserDefaults] setObject:self.audioInputName forKey:@"audioInputName"];
    [[NSUserDefaults standardUserDefaults] setObject:self.audioChn forKey:@"audioChn"];
    [[NSUserDefaults standardUserDefaults] setObject:self.audioSr forKey:@"audioSr"];
    [[NSUserDefaults standardUserDefaults] setObject:self.sdkAppIdToken forKey:@"sdkAppIdToken"];
    [[NSUserDefaults standardUserDefaults] setBool:self.authAudioSend forKey:@"authAudioSend"];
     [[NSUserDefaults standardUserDefaults] setBool:self.authAudioRev forKey:@"authAudioRev"];
    [[NSUserDefaults standardUserDefaults] setBool:self.authVideoSend forKey:@"authVideoSend"];
    [[NSUserDefaults standardUserDefaults] setBool:self.authVideoRev forKey:@"authVideoRev"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
-(void)resetAppSetting
{

    self.AppIdThird = kAVSDKDemo_AppIdThird;
    self.sdkAppId = kAVSDKDemo_AppIdThird;
    self.accountType = kAVSDKDemo_AccountType;
    
    self.isTestServer = NO;
    self.roomId = 200001;
    self.categoryNum = 0;
    self.audioInputName = @"";
    self.audioOutputName = @"";
    self.audioSr = @"";
    self.audioChn = @"";
    self.authAudioSend = TRUE;
    self.authAudioRev = TRUE;
    self.authVideoSend = TRUE;
    self.authVideoRev = TRUE;
    [self saveAppSetting];
}

- (NSDictionary *)currentUser
{
    if (!_currentUser)
    {
        _currentUser = [[NSMutableDictionary dictionary] retain];
        [self.testUsers addObject:_currentUser];
    }
    return _currentUser;
}

-(void)clearAllUsers{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSString *docPath = [documentDirectory stringByAppendingPathComponent:@"user_config.plist"];
    NSMutableArray* fileUsers=[NSMutableArray arrayWithContentsOfFile:docPath];
    [fileUsers removeAllObjects];
    //NSMutableArray* fileUsers = nil;
    self.currentUser = nil;
    [self.testUsers removeAllObjects];
    [fileUsers writeToFile:docPath atomically:YES];
}
@end
