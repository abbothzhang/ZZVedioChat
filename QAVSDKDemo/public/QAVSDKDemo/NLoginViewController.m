//
//  LoginViewController.m
//  QAVSDKDemo_P
//
//

#import "NLoginViewController.h"
#import "UserConfig.h"
#import "NMultiVideoViewController.h"
#import "MSDynamicsDrawerViewController.h"
#import "MultiRoomConfigViewController.h"
#import "RoomMemberViewController.h"

#import "UserAddViewController.h"
#import "UserSelectViewController.h"
#import "DemoTableViewController.h"

#import "SettingViewController.h"
#import "MSDynamicsDrawerViewController.h"

#import <ImSDK/IMSdkInt.h>
#import <ImSDK/TIMManager.h>
#import "AVUtil.h"
#import <TLSSDK/TLSLoginHelper.h>
#import "AppDelegate.h"
#import "InputTableViewCell.h"


@interface NLoginViewController (){
    BOOL _isLogin;
}

@end

@implementation NLoginViewController

-(void)UpdateMultiUI{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _isLogin  = NO;
    
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.backBarButtonItem = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)startContext{
    [[UserConfig shareConfig] saveAppSetting];
    //AVMultimanager
    
    int envValue = [UserConfig shareConfig].isTestServer ? 1:0;
    
    [[TIMManager sharedInstance]setEnv:envValue];
    [[TIMManager sharedInstance]initSdk];
    TIMLoginParam * login_param = [[TIMLoginParam alloc ]init];
    login_param.accountType = [UserConfig shareConfig].accountType;
    login_param.identifier = [UserConfig shareConfig].currentUser[Identifier];
    login_param.appidAt3rd = [UserConfig shareConfig].AppIdThird;
    login_param.sdkAppId = [[UserConfig shareConfig].sdkAppId intValue];
    
#if _BUILD_FOR_TLS
    //user_sig随便加一下，不然登不了
    login_param.userSig = [UserConfig shareConfig].sdkAppIdToken;
#else
    login_param.userSig = @"123";
#endif
    
    [[TIMManager sharedInstance] login:login_param succ:^(){
        NSString*strServerNotice = @"成功登上正式环境";
        if (envValue != 0)
            strServerNotice = @"成功登上测试环境";
        
        UIAlertView*alert = [[UIAlertView alloc]initWithTitle:@"注意"
                                                      message:strServerNotice
                                                     delegate:nil
                                            cancelButtonTitle:@"确定"
                                            otherButtonTitles:nil];
        [alert show];
        
        if (![AVUtil sharedContext]){
            return;
        }
        
        [[AVUtil sharedContext] startContext:^(QAVResult result) {
            if(result == QAV_OK)
            {
                //创建model
                MultiRoomMemberModel* model=[[[MultiRoomMemberModel alloc] init] autorelease];
                model.roomId= [UserConfig shareConfig].roomId;
                
                NMultiVideoViewController* multiVideoViewController=[[[NMultiVideoViewController alloc] init]autorelease];
                
                MSDynamicsDrawerViewController* drawerController=[[MSDynamicsDrawerViewController alloc] init];
                [drawerController setRevealWidth:120 forDirection:MSDynamicsDrawerDirectionRight];
                
                MultiRoomConfigViewController* roomConfigController=[[[MultiRoomConfigViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
                RoomMemberViewController* roomMenberController=[[[RoomMemberViewController alloc] initWithStyle:UITableViewStyleGrouped]autorelease ];
                roomMenberController.model=model;
                
                multiVideoViewController.model=model;
                multiVideoViewController.roomMemberController = roomMenberController;
                multiVideoViewController.roomConfigController = roomConfigController;
                //设置成员列表控制器、设置操作列表控制器、设置显示控制器
                [drawerController setDrawerViewController:roomConfigController forDirection:MSDynamicsDrawerDirectionRight];
                [drawerController setDrawerViewController:roomMenberController forDirection:MSDynamicsDrawerDirectionLeft];
                [drawerController setPaneViewController:multiVideoViewController];
                
                [self presentViewController:drawerController animated:YES completion:^{
                    
                }];
            }
        }];
        _isLogin = NO;
    }
     
                                  fail:^(int code, NSString * err) {
                                      
                                      NSString*strError = [NSString stringWithFormat:@"登录失败，错误码:%d 错误信息:%@", code, err];
                                      UIAlertView*alert = [[UIAlertView alloc]initWithTitle:@"注意"
                                                                                    message:strError
                                                                                   delegate:nil
                                                                          cancelButtonTitle:@"确定"
                                                                          otherButtonTitles:nil];
                                      [alert show];
                                      _isLogin = NO;
                                  }];
    
}


-(IBAction)login:(id)sender
{
    if (_isLogin)
        return;
    
    [UserConfig shareConfig].roomId = roomCell.roomId.text.integerValue ;
    [UserConfig shareConfig].roomRole = roomRoleCell.roomId.text ;
    [self startContext];
    _isLogin = YES;
}

-(IBAction)moreDemo:(id)sender
{
    if ([UserConfig shareConfig].currentUser == nil)
    {
        [self UserAlert];
        return;
    }
    
    if ([AVUtil sharedContext]) {
        if (![[AVUtil sharedContext] stopContext:^(QAVResult result) {
            
            MSDynamicsDrawerViewController* drawerController=[[MSDynamicsDrawerViewController alloc] init];
            [drawerController setRevealWidth:120 forDirection:MSDynamicsDrawerDirectionRight];
            [self presentViewController:drawerController animated:YES completion:^{
                
            }];
            
            return;
        }]){
        }
    }else{
        
        MSDynamicsDrawerViewController* drawerController=[[MSDynamicsDrawerViewController alloc] init];
        [drawerController setRevealWidth:120 forDirection:MSDynamicsDrawerDirectionRight];
        
        [self presentViewController:drawerController animated:YES completion:^{
            
        }];
        
        return;
    }
}
-(IBAction)setting:(id)sender
{
    UIStoryboard* storyboard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SettingViewController* settingViewController=[storyboard instantiateViewControllerWithIdentifier:@"SettingViewController"];
    
    [self.navigationController pushViewController:settingViewController animated:YES];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section==0) {
        return 3;
    }else if(section==1){
        return 2;
    }else if(section==2){
        return 1;
    }
#if _BUILD_FOR_TLS
    else if (section == 3)
    {
        return 1;
    }
#endif
    return 0;
}
-(NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section==0) {
        return @"帐号";
    }else if(section==1){
        return @"房间";
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section==0 ) {
        if (indexPath.row==0) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"当前帐号"];
            if (!cell) {
                cell=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"当前帐号"] autorelease];
            }
            cell.textLabel.text=@"当前帐号";
            cell.detailTextLabel.text=[UserConfig shareConfig].currentUser[Identifier];
            return cell;
        }else if (indexPath.row == 1){
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"添加帐号"];
            if (!cell) {
                cell=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"添加帐号"] autorelease];
            }
            cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text=@"添加帐号";
            return cell;
        }else if (indexPath.row == 2){
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"删除所有账号"];
            if (!cell) {
                cell=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"删除所有账号"] autorelease];
            }
            cell.accessoryType=UITableViewCellAccessoryNone;
            cell.textLabel.text=@"删除所有账号";
            return cell;
        }
        return nil;
        
    }else if(indexPath.section==1)
    {
        if (indexPath.row==0) {
            roomCell = [tableView dequeueReusableCellWithIdentifier:@"房间号"];
            if (!roomCell) {
                roomCell=[[[InputTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"房间号"] autorelease];
            }
#ifdef _BUILD_FOR_MULT
            
            if ([UserConfig shareConfig].roomId != 0){
                roomCell.roomId.text = [NSString stringWithFormat:@"%ld",(long)[UserConfig shareConfig].roomId];
            }
            else{
                roomCell.roomId.text = @"200001";
            }
            roomCell.showText.text=@"房间号:";
            roomCell.selectionStyle=UITableViewCellSelectionStyleNone;
#endif
            return roomCell;
            
        }else if (indexPath.row == 1){
            
            roomRoleCell = [tableView dequeueReusableCellWithIdentifier:@"流控角色名"];
            if (!roomRoleCell) {
                roomRoleCell=[[[InputTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"流控角色名"] autorelease];
            }
#ifdef _BUILD_FOR_MULT
            if ([UserConfig shareConfig].roomId != 0){
                roomRoleCell.roomId.text = [NSString stringWithFormat:@"%ld",(long)[UserConfig shareConfig].roomId];
            }
            else{
                roomRoleCell.roomId.text = @"200001";
            }
            roomRoleCell.showText.text=@"流控角色名:";
            roomRoleCell.selectionStyle=UITableViewCellSelectionStyleNone;
            return roomRoleCell;
#endif
        }
        return nil;
    }else if (indexPath.section == 2)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"进入"];
        if (!cell) {
            cell=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"进入"] autorelease];
        }
        
#ifdef _BUILD_FOR_MULT
        cell.textLabel.text=@"进入";
        cell.textLabel.font=[UIFont boldSystemFontOfSize:16];
        cell.textLabel.textColor=[UIColor blueColor];
#endif
        return cell;
    }
    else if (indexPath.section == 3)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"退出"];
        if (!cell) {
            cell=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"退出"] autorelease];
        }
        
#ifdef _BUILD_FOR_MULT
        cell.textLabel.text=@"退出";
        cell.textLabel.font=[UIFont boldSystemFontOfSize:16];
        cell.textLabel.textColor=[UIColor blueColor];
#endif
        return cell;
    }
    return nil;
    
}

-(void)UserAlert{
    UIAlertView*alert = [[UIAlertView alloc]initWithTitle:@"注意"
                                                  message:@"登录前请先添加账号！！"
                                                 delegate:nil
                                        cancelButtonTitle:@"确定"
                                        otherButtonTitles:nil];
    [alert show];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0) {
        if (indexPath.row==0) {
            UserSelectViewController* userSelectViewController=[[[UserSelectViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
            userSelectViewController.delegate=self;
            [self.navigationController pushViewController:userSelectViewController animated:YES];
        }else if (indexPath.row==1) {
            UIStoryboard* storyboard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UserAddViewController* userAddViewController=[storyboard instantiateViewControllerWithIdentifier:@"UserAddViewController"];
            userAddViewController.delegate = self;
            [self.navigationController pushViewController:userAddViewController animated:YES];
        }else if (indexPath.row==2) {
            UIAlertView*alert = [[UIAlertView alloc]initWithTitle:@"注意"
                                                          message:@"继续操作会清除所有！！"
                                                         delegate:self
                                                cancelButtonTitle:@"取消"
                                 
                                                otherButtonTitles:@"确定", nil];
            alert.tag = 1;
            [alert show];
            
            
        }
    }else if (indexPath.section==2){
        if ([UserConfig shareConfig].currentUser == nil)
        {
            [self UserAlert];
            return;
        }
        [self login:nil];
    }
    else if (indexPath.section==3)
    {
        // 退出
        // 登出imsdk
        TLSUserInfo *userinfo = [[TLSLoginHelper getInstance] getLastUserInfo];
        if (userinfo != nil && userinfo.identifier != nil) {
            [[TLSLoginHelper getInstance] clearUserInfo:userinfo.identifier withOption:YES];
        }
        
        [[TIMManager sharedInstance] logout];
        AppDelegate* appDelegate =(AppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate switchToLoginView];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


#pragma mark user selected delegate
-(void)userSelected:(NSString*)openId{
    [[UserConfig shareConfig] setCurrentUserWithOpenId: openId];
    
    [self.tableView reloadData];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1){
        if (alertView.tag == 1){
            [[UserConfig shareConfig] clearAllUsers];
            [self.tableView reloadData];
        }
        [alertView release];
    }
}

- (void)dealloc {
    [super dealloc];
}

@end
