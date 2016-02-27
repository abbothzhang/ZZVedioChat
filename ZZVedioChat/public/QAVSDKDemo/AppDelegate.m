//
//  AppDelegate.m
//  AVTest
//
//  Created by TOBINCHEN on 14-8-13.
//  Copyright (c) 2014年 TOBINCHEN. All rights reserved.
//

#import "AppDelegate.h"
#import "UserConfig.h"

//#import "CocoaLumberjack.h"

#import <ImSDK/ImSDK.h>
#import <TLSSDK/TLSAccountHelper.h>
#import <TLSSDK/TLSLoginHelper.h>
#import "UserConfig.h"
#import "AVTLSLoginViewController.h"

//DDFileLogger* fileLogger=nil;
//
//static int my_exp_callback() {
//    if (fileLogger) {
//        NSString* logString=[NSString stringWithContentsOfFile:[fileLogger currentLogFileInfo].filePath encoding:NSUTF8StringEncoding error:nil];
//#define CRASH_ATT_LOG_MAXLEN 20 * 1024
//        int maxLen = CRASH_ATT_LOG_MAXLEN;
//        
//    }
//    
//    return 1;
//}


@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
//    [DDLog addLogger:[DDASLLogger sharedInstance]];
//    [DDLog addLogger:[DDTTYLogger sharedInstance]];
//    
//    fileLogger = [[DDFileLogger alloc] init];
//    fileLogger.rollingFrequency = 60 * 60 * 24;
//    fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
//    
//    [DDLog addLogger:fileLogger];
//    
//    DDLogInfo(@"QAVSDK Demo did Finish Launching");
//    
//    DDLogInfo(@"log path:%@",[fileLogger currentLogFileInfo].filePath);
    
    
    //    [[CrashReporter sharedInstance] enableLog:YES];
    //    [[CrashReporter sharedInstance] installWithAppkey:@"com.tencent.qavsdkdemo"];
    //    [[CrashReporter sharedInstance] setChannel:@"RDM"];
    
    
    //exp_call_back_func = &my_exp_callback;
    
    //设置userid，可选, 用于标识用户
    //[[CrashReporter sharedInstance] setUserId:@”youruserid”];
    //deviceid, 可选，默认rqd会自己生产一个deviceid。如果用户想使用自己的deviceid，可以设置
    //[[CrashReporter sharedInstance] setDeviceId:@"yourDeviceId"];
    
#if _BUILD_FOR_TLS
    int envValue = [UserConfig shareConfig].isTestServer ? 1:0;
    
    [[TIMManager sharedInstance] setEnv:envValue];
    //    [[TIMManager sharedInstance]setEnv:1];
    [[TIMManager sharedInstance] initSdk:TLS_SDK_APPID accountType:kAVSDKDemo_AccountType];
    
    
    // Override point for customization after application launch.
    [[TLSLoginHelper getInstance] init:TLS_SDK_APPID andAccountType:TLS_SDK_ACCOUNT_TYPE andAppVer:APP_VERSION];
    [[TLSAccountHelper getInstance] init:TLS_SDK_APPID andAccountType:TLS_SDK_ACCOUNT_TYPE andAppVer:APP_VERSION];
    [[TLSLoginHelper getInstance] setLogcat:YES];
    //    [[TLSLoginHelper getInstance] setTestHost:@"113.108.64.238" andPort:443];
    //    [TLSLoginHelper getInstance]
    self.openQQ = [[TencentOAuth alloc] initWithAppId:QQ_OPEN_ID andDelegate:self];
    [WXApi registerApp:WX_OPEN_ID];
    
    
    [self switchToLoginView];
#else
    [self switchToMain];
#endif
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)switchToLoginView
{
    if (!self.window)
    {
        self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    }
    AVTLSLoginViewController *vc = [[AVTLSLoginViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
}


- (void)switchToMain
{
    if (!self.window)
    {
        self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    }
    self.window.backgroundColor = [UIColor whiteColor];
    // 获取指定的Storyboard，name填写Storyboard的文件名
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.window.rootViewController = storyboard.instantiateInitialViewController;
    [self.window makeKeyAndVisible];
}



-(void)tencentDidNotNetWork{
    NSLog(@"%s", __func__);
}
-(void)tencentDidLogin{
    NSLog(@"%s", __func__);
    
}
-(void)tencentDidNotLogin:(BOOL)cancelled{
    NSLog(@"%s %d", __func__, cancelled);
}

-(void)onResp:(BaseResp *)resp{
    NSLog(@"%d %@ %d",resp.errCode, resp.errStr, resp.type);
    if ([resp isKindOfClass:[SendAuthResp class]]) {
        if(self.tlsuiwx != nil)
            [self.tlsuiwx onResp:resp];
    }
}


-(BOOL)application:(UIApplication*)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    NSLog(@"%s %@", __func__, url);
    if ([url.scheme compare:QQ_OPEN_SCHEMA] == NSOrderedSame) {
        
        return [TencentOAuth HandleOpenURL:url];
        
    }
    else if([url.scheme compare:WX_OPEN_ID] == NSOrderedSame){
        
        [WXApi handleOpenURL:url delegate:self];
        
    }
    return YES;
}
-(BOOL)application:(UIApplication*)application handleOpenURL:(NSURL *)url{
    NSLog(@"%s %@", __func__, url);
    if ([url.scheme compare:QQ_OPEN_SCHEMA] == NSOrderedSame) {
        
        return [TencentOAuth HandleOpenURL:url];
        
    }
    else if([url.scheme compare:WX_OPEN_ID] == NSOrderedSame){
        
        [WXApi handleOpenURL:url delegate:self];
        
    }
    return YES;
}

@end