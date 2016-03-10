//
//  CallView.h
//  QAVSDKDemo_P
//
//  Created by TOBINCHEN on 14-10-29.
//  Copyright (c) 2014年 TOBINCHEN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"


@interface CallView : MBProgressHUD{
    UIActivityIndicatorView* _activityIndicatorView;
    UILabel* _msgLabel;
    UIButton* _cancelButton;
}
@property (nonatomic,readonly,retain) UIActivityIndicatorView* activityIndicatorView;
@property (nonatomic,readonly,retain) UILabel* msgLabel;
@property (nonatomic,readonly,retain) UIButton* cancelButton;
@end


@interface RecvCallView : MBProgressHUD
@property (nonatomic,readonly,retain) UILabel* msgLabel;
@property (nonatomic,readonly,retain) UIButton* acceptButton;
@property (nonatomic,readonly,retain) UIButton* refuseButton;
@property (nonatomic,readonly,retain) UIButton* ignoreButton;
@end



