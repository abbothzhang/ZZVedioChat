//
//  UserAddViewController.h
//  QAVSDKDemo_P
//
//  Created by TOBINCHEN on 14-12-3.
//  Copyright (c) 2014年 TOBINCHEN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserSelectViewController.h"

@interface UserAddViewController : UITableViewController{
    IBOutlet UITextField* _openIdTextField;
    id<UserSelectViewControllerDelegate> _delegate;
}
@property (nonatomic,assign) id<UserSelectViewControllerDelegate> delegate;
@end
