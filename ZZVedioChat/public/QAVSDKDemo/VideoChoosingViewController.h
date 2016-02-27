//
//  VideoChoosingViewController.h
//  QAVSDKDemo
//
//  Created by roger lin on 15/8/31.
//  Copyright (c) 2015年 TOBINCHEN. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol VideoChoosingDelegate ;
@interface VideoChoosingViewController : UIViewController <UITableViewDelegate, UITableViewDataSource,UITextFieldDelegate>
{
}

@property (nonatomic,retain) id<VideoChoosingDelegate>chooseDelegate;

@end
@protocol VideoChoosingDelegate <NSObject>
- (void)playVideoWithVideo:(NSString*)video AndFrame:(NSString*)frame;
@end