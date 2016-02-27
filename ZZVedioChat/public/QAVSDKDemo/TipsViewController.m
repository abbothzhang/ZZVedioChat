//
//  TipsViewController.m
//  QAVSDKDemo_P
//
//  Created by TOBINCHEN on 14-12-3.
//  Copyright (c) 2014年 TOBINCHEN. All rights reserved.
//

#import "TipsViewController.h"

@interface TipsViewController ()

@end

@implementation TipsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tipsView=[[MBProgressHUD alloc] initWithFrame:CGRectMake(0, 0, 300, 200)];
    [self.view addSubview:_tipsView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)showTips:(NSString*)msg{
    [self.view bringSubviewToFront:_tipsView];
    _tipsView.labelText=msg;
    [_tipsView show:YES];
}
-(void)hideTips{
    [_tipsView hide:NO];
}
-(void)hideTips:(NSString*)msg afterDelay:(NSTimeInterval)delay{
    _tipsView.labelText=msg;
    [_tipsView hide:YES afterDelay:0.3];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
