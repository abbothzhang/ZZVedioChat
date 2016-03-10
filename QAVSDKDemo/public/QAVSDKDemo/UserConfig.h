//
//  UserConfig.h
//  AVTest
//
//

#import <Foundation/Foundation.h>


extern NSString* Identifier;

extern NSString* UserOpenIdKey;
extern NSString* UserNameKey;
extern NSString* UserTokenKey;

@interface UserConfig : NSObject
{
    NSDictionary* _currentUser;
    NSMutableArray* _testUsers;
}

@property (copy,nonatomic)  NSString* AppIdThird;       //App使用的OAuth授权体系分配的AppId。
@property (copy,nonatomic)  NSString* sdkAppId;         //腾讯为每个使用SDK的App分配多AppId。
@property (copy,nonatomic)  NSString* accountType;      //腾讯为每个接入方分配的账号类型。
@property (copy,nonatomic)  NSString* sdkAppIdToken;

@property (copy,nonatomic)  NSString* audioInputName;
@property (copy,nonatomic)  NSString* audioOutputName;
@property (copy,nonatomic)  NSString* audioSr;
@property (copy,nonatomic)  NSString* audioChn;

@property (assign,nonatomic)BOOL      authAudioSend;
@property (assign,nonatomic)BOOL      authAudioRev;
@property (assign,nonatomic)BOOL      authVideoSend;
@property (assign,nonatomic)BOOL      authVideoRev;

@property (assign,nonatomic)BOOL      isTestServer;
@property (assign,nonatomic)NSInteger roomId;
@property (copy,nonatomic)  NSString* roomRole;
@property (nonatomic)       NSInteger categoryNum;

@property (readonly,nonatomic)  NSMutableArray* testUsers;
@property (retain,nonatomic)  NSDictionary* currentUser;

+(UserConfig*)shareConfig;
-(void)setCurrentUserWithOpenId:(NSString*)openId;

-(void)addUserToConfigWithId:(NSString*)openId;
-(void)saveAppSetting;
-(void)resetAppSetting;
-(void)clearAllUsers;
@end
