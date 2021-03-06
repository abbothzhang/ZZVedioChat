//
//  RoomConfigViewController.h
//  QAVSDKDemo_P
//
//  Created by TOBINCHEN on 14-11-19.
//  Copyright (c) 2014年 TOBINCHEN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoChoosingViewController.h"
#import "ChangeAuthorityController.h"
#import "NMultiVideoViewController.h"
#import "QAVSDK/QAVContext.h"
@class AVUtilController;
@interface MultiRoomConfigViewController : UITableViewController<VideoChoosingDelegate,QAVAudioPreviewDelegate,ChangeAuthorityDelegate>
{
    VideoChoosingViewController* videoChoosingView;
    QAVContext *_avContext;
    NSTimer*_timer;
    ChangeAuthorityController* changeAuthirtyView;
    AVUtilController*avUtil;
}

@property (assign,nonatomic) NMultiVideoViewController* videoController;
-(void)unInit;
@end
