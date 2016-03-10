//
//  UserAddViewController.m
//  QAVSDKDemo_P
//
//

#import "UserAddViewController.h"
#import "UserConfig.h"
@interface UserAddViewController ()

@end

@implementation UserAddViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    static BOOL bShowed = NO;
    if (!bShowed){
        UIAlertView*alert = [[UIAlertView alloc]initWithTitle:@"注意"
                                                      message:@"identifier相当于账号。双人的场景需要呼叫方添加对方的identifier,对方连通了才能呼叫成功。"
                                                     delegate:nil
                                            cancelButtonTitle:@"确定"
                                            otherButtonTitles:nil];
        [alert show];
        bShowed = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)addEndpoint:(id)sender
{
    if (_openIdTextField.text.length==0 ) {
        return;
    }else{
        [[UserConfig shareConfig] addUserToConfigWithId:_openIdTextField.text];
        [[UserConfig shareConfig] setCurrentUserWithOpenId:_openIdTextField.text];
        
        if (_delegate)
            [_delegate userSelected:_openIdTextField.text];
        
        [self.navigationController popViewControllerAnimated:YES];
    }

}
@end
