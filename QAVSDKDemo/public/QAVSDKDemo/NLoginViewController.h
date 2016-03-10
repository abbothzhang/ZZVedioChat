//
//  LoginViewController.h
//  QAVSDKDemo_P
//
//  Created by TOBINCHEN on 14-11-17.
//  Copyright (c) 2014年 TOBINCHEN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserSelectViewController.h"
#import "QAVSDK/QAVContext.h"
#import "InputTableViewCell.h"

@interface NLoginViewController : UITableViewController<UserSelectViewControllerDelegate, UIAlertViewDelegate>{
    InputTableViewCell *roomCell;
    InputTableViewCell *roomRoleCell;
    BOOL _bMulti;
}
-(IBAction)setting:(id)sender;
@end
