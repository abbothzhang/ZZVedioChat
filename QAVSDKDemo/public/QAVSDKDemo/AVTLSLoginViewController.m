//
//  TLSLoginViewController.m
//  QAVSDKDemo
//
//  Created by AlexiChen on 15/8/20.
//  Copyright (c) 2015年 TOBINCHEN. All rights reserved.
//

#import "AVTLSLoginViewController.h"
#import "AppDelegate.h"

#import "NLoginViewController.h"

#import <ImSDK/ImSDK.h>

@interface AVTLSLoginViewController ()

@property (nonatomic, assign) IBOutlet  UIButton *qq;
@property (nonatomic, assign) IBOutlet  UIButton *wx;

@end

@implementation AVTLSLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //    NSString *path = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:@"TLSUI.bundle"];
    //    NSBundle *bundle = [NSBundle bundleWithPath:path];
    //
    //    [_qq setImage:[UIImage imageWithContentsOfFile:[bundle pathForResource:@"qqicon" ofType:@"png"]] forState:UIControlStateNormal];
    //    [_wx setImage:[UIImage imageWithContentsOfFile:[bundle pathForResource:@"icon48_appwx_logo" ofType:@"png"]] forState:UIControlStateNormal];
    _qq.hidden = YES;
    _wx.hidden = YES;
}

- (void)autoLogin
{
    //    if (userinfo)
    //    {
    //        TIMLoginParam *param = [[TIMLoginParam alloc ] init];
    //        param.userSig = [[TLSLoginHelper getInstance] getTLSUserSig:userinfo.identifier];
    //        param.identifier = userinfo.identifier;
    //        param.appidAt3rd = [@TLS_SDK_APPID stringValue];
    //        param.accountType = [NSString stringWithFormat:@"%d", kSdkAccountType];
    //        param.sdkAppId = kSdkAppId;
    //        [self TIMLogin:param];
    //    }
    //
    //    return;
    
    TLSUserInfo *userinfo = [[TLSLoginHelper getInstance] getLastUserInfo];
    UserConfig *config = [UserConfig shareConfig];
    
    [config.currentUser setValue:userinfo.identifier forKey:UserOpenIdKey];
    //    [config.currentUser setValue:@"B414D14DB2AD8A473D4FC3E9F9E97251" forKey:UserTokenKey];
    
    NSString *token = [[TLSLoginHelper getInstance] getTLSUserSig:userinfo.identifier];
    [config.currentUser setValue:token forKey:UserTokenKey];
    [config.currentUser setValue:userinfo.identifier forKey:UserNameKey];
    config.sdkAppIdToken = token;
    
    // 获取指定的Storyboard，name填写Storyboard的文件名
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    // 从Storyboard上按照identifier获取指定的界面（VC），identifier必须是唯一的
//    NLoginViewController *receive = [storyboard instantiateViewControllerWithIdentifier:@"NLoginViewController"];
//    [self.navigationController pushViewController:receive animated:YES];
    [(AppDelegate *)[UIApplication sharedApplication].delegate switchToMain];
}


- (IBAction)login:(id)sender
{
    TLSUserInfo *userinfo = [[TLSLoginHelper getInstance] getLastUserInfo];
    if (userinfo != nil && userinfo.identifier != nil && ![[TLSLoginHelper getInstance] needLogin:userinfo.identifier])
    {
        self.tips.text = [NSString stringWithFormat: @"已经存在登录态%u %@",userinfo.accountType ,userinfo.identifier];
        [self autoLogin];
    }
    else
    {
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        TLSUILoginSetting *setting = [[TLSUILoginSetting alloc] init];
        setting.openQQ = delegate.openQQ;
        setting.qqScope = nil;
        setting.wxScope = @"snsapi_userinfo";
        setting.needBack = YES;
        //设置微信回调对象方便处理微信互联登录
        id<WXApiDelegate> wx = TLSUILogin(self, setting);
        [setting release];
        
        [delegate setTlsuiwx:wx];
        
        //拉起登录框
    }
}

- (IBAction)logout:(id)sender
{
    TLSUserInfo *userinfo = [[TLSLoginHelper getInstance] getLastUserInfo];
    if (userinfo != nil && userinfo.identifier != nil) {
        [[TLSLoginHelper getInstance] clearUserInfo:userinfo.identifier withOption:YES];
    }
    self.tips.text = @"删除成功";
    
}


-(void)OnRefreshTicketSuccess:(TLSUserInfo *)userInfo
{
    NSLog(@"%s", __func__);
}

-(void)OnRefreshTicketFail:(TLSErrInfo *)errInfo
{
    NSLog(@"%s", __func__);
}

-(void)OnRefreshTicketTimeout:(TLSErrInfo *)errInfo
{
    NSLog(@"%s", __func__);
}

-(void)TLSUILoginOK:(TLSUserInfo *)userinfo
{
    
    //回调时已结束登录流程 销毁微信回调对象
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [delegate setTlsuiwx:nil];
    
    //根据登录结果处理
    if (userinfo)
    {
        [self autoLogin];
        self.tips.text = [NSString stringWithFormat:@"登录成功 %u %@", userinfo.accountType, userinfo.identifier];
    }
    else
    {
        self.tips.text = @"返回nil";
    }
}

-(void)TLSUILoginQQOK
{
    //回调时已结束登录流程 销毁微信回调对象
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.tips.text = [NSString stringWithFormat:@"open qq %@", delegate.openQQ.accessToken];
    //    NSLog(@"%@ %@", self.tips.text, delegate.openQQ.openId);
}

-(void)TLSUILoginWXOK:(SendAuthResp *)resp
{
    //回调时已结束登录流程 销毁微信回调对象
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate setTlsuiwx:nil];
    
    self.tips.text = [NSString stringWithFormat:@"open wx %@", resp.code];
    //第一步，创建URL
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code", WX_OPEN_ID, WX_OPEN_KEY, resp.code]];
    //第二步，通过URL创建网络请求
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    //第三步，连接服务器,发送同步请求
    NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSError *error;
    NSDictionary *data = [NSJSONSerialization JSONObjectWithData:received options:NSJSONReadingMutableLeaves error:&error];
    self.tips.text = data[@"access_token"];
    NSLog(@"%@", data);
}

-(void)TLSUILoginCancel{
    
    //回调时已结束登录流程 销毁微信回调对象
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate setTlsuiwx:nil];
    self.tips.text = @"用户取消";
}


@end
