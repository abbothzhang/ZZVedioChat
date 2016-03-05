//
//  TipsViewController.h
//  QAVSDKDemo_P
//
//  Created by TOBINCHEN on 14-12-3.
//  Copyright (c) 2014年 TOBINCHEN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface TipsViewController : UIViewController{
    MBProgressHUD* _tipsView;
}
-(void)showTips:(NSString*)msg;
-(void)hideTips;
-(void)hideTips:(NSString*)msg afterDelay:(NSTimeInterval)delay;
@end
