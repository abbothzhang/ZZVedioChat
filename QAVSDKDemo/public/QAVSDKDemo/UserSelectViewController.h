//
//  UserSelectViewController.h
//  QAVSDKDemo_P
//
//  Created by TOBINCHEN on 14-12-3.
//  Copyright (c) 2014年 TOBINCHEN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserConfig.h"

@protocol UserSelectViewControllerDelegate <NSObject>

-(void)userSelected:(NSString*)openId;
@end


@interface UserSelectViewController : UITableViewController{
    UIButton*_addBtn;
    UIButton*_cancelbtn;
    id<UserSelectViewControllerDelegate> _delegate;
}
@property (nonatomic,assign) id<UserSelectViewControllerDelegate> delegate;
@end
