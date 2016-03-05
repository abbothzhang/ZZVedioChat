//
//  VideoRenderView.h
//  QAVSDKDemo_P
//
//  Created by TOBINCHEN on 14-11-21.
//  Copyright (c) 2014年 TOBINCHEN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoRenderView : UIView{
    NSMutableArray* _views;
    UIView* _selectedView;
    UIScrollView* _listView;
}
@property (nonatomic,readonly)UIView* selectedView;
-(void)addRenderView:(UIView*)aView;
-(void)removeRenderView:(UIView*)aView;
@end