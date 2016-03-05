//
//  util.m
//  QAVSDKDemo
//
//  Created by xianhuanlin on 15/6/25.
//  Copyright (c) 2015年 TOBINCHEN. All rights reserved.
//

#import "AVUtil.h"
#import "UserConfig.h"

BOOL _isEnableRocord = NO;
QAVContext*g_context = nil;

@implementation AVUtil


+(void)ShowMsg:(NSString*)msg{
    UIAlertView*alert = [[UIAlertView alloc]initWithTitle:@"注意"
                                                  message:msg
                                                 delegate:nil
                                        cancelButtonTitle:@"确定"
                                        otherButtonTitles:nil];
    [alert show];
}

+(void)SetEnableRecord:(BOOL)isEnable{
    _isEnableRocord = isEnable;
}

+(BOOL)isEnableRecord{
    return _isEnableRocord;
}

+(QAVContext*)sharedContext{

    if (!g_context){
        
        QAVContextConfig*config = [[[QAVContextConfig alloc]init] autorelease];
        config.sdkAppId = [UserConfig shareConfig].sdkAppId;
        config.appIdAtThird = [UserConfig shareConfig].AppIdThird;
        config.identifier = [UserConfig shareConfig].currentUser[Identifier];
        config.accountType = [UserConfig shareConfig].accountType;

        g_context = [QAVContext CreateContext:config];
    }
    return g_context;
}

+(void)destroyShardContext{
    if (g_context){
        [QAVContext DestroyContext:g_context];
        [g_context release];
        g_context = nil;
    }
}

+(BOOL)isIphone4S:(UIViewController*)controller{
    if (controller.view.bounds.size.height <= 480){
        NSLog(@"is 4s, width:%f", controller.view.bounds.size.width);
        return YES;
    }
    return NO;
}

@end

