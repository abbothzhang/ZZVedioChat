//
//  CallView.m
//  QAVSDKDemo_P
//
//  Created by TOBINCHEN on 14-10-29.
//  Copyright (c) 2014年 TOBINCHEN. All rights reserved.
//

#import "CallView.h"

@implementation CallView
-(id)init{
    return [self initWithFrame:CGRectMake(0, 0, 200, 120)];
}
-(id)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        CGFloat fixedW=200,fixedH=120;
        UIView* contentView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        contentView.backgroundColor=[UIColor whiteColor];
        contentView.layer.cornerRadius = 5.f;
        contentView.layer.borderColor = [UIColor blackColor].CGColor;
        contentView.layer.borderWidth = 1.f;
        
        _activityIndicatorView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _activityIndicatorView.color=[UIColor grayColor];
        _activityIndicatorView.center=CGPointMake(fixedW/2, 20);
        _activityIndicatorView.autoresizingMask=UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
        [_activityIndicatorView startAnimating];
        [contentView addSubview:_activityIndicatorView];
        
        _msgLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, fixedH-80, fixedW, 40)];
        _msgLabel.textAlignment=NSTextAlignmentCenter;
        _msgLabel.text=@"等待对方接听...";
        _msgLabel.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
        [contentView addSubview:_msgLabel];
        
        
        _cancelButton=[[UIButton alloc] initWithFrame:CGRectMake(0, fixedH-40,fixedW , 40)];
        _cancelButton.backgroundColor=[UIColor grayColor];
        [_cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [_cancelButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [contentView addSubview:_cancelButton];
        
        self.customView=contentView;
        self.mode = MBProgressHUDModeCustomView;
        self.margin=0;
        self.color=[UIColor clearColor];
    }
    return self;
}

@end



@implementation RecvCallView
-(id)init{
    return [self initWithFrame:CGRectMake(0, 10, 280, 120)];
}
-(id)initWithFrame:(CGRect)frame{
    
    self=[super initWithFrame:frame];
    if (self) {
        CGFloat fixedW=280,fixedH=120;
        UIView* contentView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        contentView.backgroundColor=[UIColor whiteColor];
        contentView.layer.cornerRadius = 5.f;
        contentView.layer.borderColor = [UIColor blackColor].CGColor;
        contentView.layer.borderWidth = 1.f;
        
        _msgLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, fixedW, fixedH-60)];
        _msgLabel.textAlignment=NSTextAlignmentCenter;
        _msgLabel.text=@"";
        _msgLabel.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
        [contentView addSubview:_msgLabel];
        
        
        _acceptButton=[[UIButton alloc] initWithFrame:CGRectMake(10, fixedH-60,80 , 40)];
        _acceptButton.backgroundColor=[UIColor greenColor];
        [_acceptButton setTitle:@"Accept" forState:UIControlStateNormal];
        [_acceptButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [contentView addSubview:_acceptButton];
        
        _refuseButton=[[UIButton alloc] initWithFrame:CGRectMake(0, 0,80 , 40)];
        _refuseButton.backgroundColor=[UIColor redColor];
        _refuseButton.center=CGPointMake(fixedW/2,fixedH-60+40/2);
        [_refuseButton setTitle:@"Refuse" forState:UIControlStateNormal];
        [_refuseButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [contentView addSubview:_refuseButton];
        
        _ignoreButton=[[UIButton alloc] initWithFrame:CGRectMake(fixedW-80-10, fixedH-60,80 , 40)];
        _ignoreButton.backgroundColor=[UIColor grayColor];
        [_ignoreButton setTitle:@"Ignore" forState:UIControlStateNormal];
        [_ignoreButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [contentView addSubview:_ignoreButton];

        self.customView=contentView;
        self.mode = MBProgressHUDModeCustomView;
        self.margin=0;
        self.color=[UIColor clearColor];
    }
    return self;
}

@end
