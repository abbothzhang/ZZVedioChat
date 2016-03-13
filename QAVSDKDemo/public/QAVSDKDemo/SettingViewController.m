//
//  SettingViewController.m
//  QAVSDKDemo_P
//
//

#import "SettingViewController.h"
#import "UserConfig.h"


@interface SettingViewController ()

@end

@implementation SettingViewController
@synthesize settingTableView;
@synthesize selectedCategory;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([[UserConfig shareConfig].sdkAppId isEqualToString:@"1104620500"])
        [_segType setSelectedSegmentIndex:0];
    else  if ([[UserConfig shareConfig].sdkAppId isEqualToString:@"1104062745"])

        [_segType setSelectedSegmentIndex:1];
    
//    _openAppIdTextField.text=[UserConfig shareConfig].AppIdThird;
//    _sdkAppIdTextField.text=[UserConfig shareConfig].sdkAppId;
//    _uinTypeTextField.text=[UserConfig shareConfig].accountType;
    [_isTestSwitch setOn:[UserConfig shareConfig].isTestServer];
    
    settingTableView.delegate = self;
    settingTableView.dataSource = self;
    selectedCategory = [UserConfig shareConfig].categoryNum;
    
    _authAudioSend.accessoryType = [UserConfig shareConfig].authAudioSend == TRUE ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    _authAudioRev.accessoryType = [UserConfig shareConfig].authAudioRev == TRUE ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    _authVideoSend.accessoryType = [UserConfig shareConfig].authVideoSend == TRUE ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    _authVideoRev.accessoryType = [UserConfig shareConfig].authVideoRev == TRUE ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    [_segType addTarget:self action:@selector(OnSegChange:) forControlEvents:UIControlEventValueChanged];
}


- (void)viewDidAppear:(BOOL)animated
{

}



-(IBAction)OnSegChange:(id)sender{
    NSInteger index = [_segType selectedSegmentIndex];
    if (index == 0){
        [UserConfig shareConfig].AppIdThird = @"1104620500";
        [UserConfig shareConfig].sdkAppId = @"1104620500";
        
    }
    else{
        [UserConfig shareConfig].AppIdThird = @"1104062745";
        [UserConfig shareConfig].sdkAppId = @"1104062745";
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)OnAppidEditEnd:(id)sender {
    UIAlertView*view = [[UIAlertView alloc]initWithTitle:@"注意" message:@"需要向后台申请后才能修改appid" delegate:nil cancelButtonTitle:@"了解" otherButtonTitles:nil, nil];
    
    [view show];
}

-(IBAction)save:(id)sender{
//    NSInteger index = [_segType selectedSegmentIndex];
//    if (index == 0){
//        [UserConfig shareConfig].AppIdThird = @"1104620500";
//        [UserConfig shareConfig].sdkAppId = @"1104620500";
//
//    }
//    else{
//        [UserConfig shareConfig].AppIdThird = @"1104062745";
//        [UserConfig shareConfig].sdkAppId = @"1104062745";
//    }
    [self OnSegChange:_segType];
    
    [UserConfig shareConfig].isTestServer = _isTestSwitch.isOn;
    [UserConfig shareConfig].categoryNum = selectedCategory;
    [[UserConfig shareConfig] saveAppSetting];
    
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)testSwitchChanged:(id)sender {
    [UserConfig shareConfig].isTestServer = _isTestSwitch.isOn;
    [[UserConfig shareConfig] saveAppSetting];
}
-(IBAction)reset:(id)sender{
    [[UserConfig shareConfig] resetAppSetting];
    
    [self.navigationController popViewControllerAnimated:YES];
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2) {
        
        UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
        BOOL selected=NO;
        if(selectedCell.accessoryType==UITableViewCellAccessoryCheckmark){
            selected=NO;
            selectedCell.accessoryType=UITableViewCellAccessoryNone;
        }else{
            selected=YES;
            selectedCell.accessoryType=UITableViewCellAccessoryCheckmark;
        }
        
        if(indexPath.row == 0) {
            [UserConfig shareConfig].authAudioSend = selected;
        }
        else if(indexPath.row == 1) {
            [UserConfig shareConfig].authAudioRev = selected;
        }
        else if(indexPath.row == 2) {
            [UserConfig shareConfig].authVideoSend = selected;
        }
        else if(indexPath.row == 3) {
            [UserConfig shareConfig].authVideoRev = selected;
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 43.0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionTitle = nil;
    if (section == 2) {
        sectionTitle = @"进房间权限";
    }
    return sectionTitle;
}

- (void)dealloc {
    [_isTestSwitch release];
    [settingTableView release];
    [_authVideoSend release];
    [_authVideoRev release];
    [_authAudioSend release];
    [_authAudioRev release];
    [_segType release];
    [super dealloc];
}
- (IBAction)OnAppIDTextChanged:(id)sender {
    

}
@end
