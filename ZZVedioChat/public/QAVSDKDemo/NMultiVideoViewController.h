//
//  NMultiVideoViewController.h
//  ZZVCSDKDemo_P
//
//  Created by TOBINCHEN on 14-11-17.
//  Copyright (c) 2014?ﾦ￐ TOBINCHEN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MultiRoomMemberModel.h"
#import "TipsViewController.h"
#import "AVGLBaseView.h"
#import "AVFrameDispatcher.h"
#import "ZZVideoChat.h"


@class MultiRoomConfigViewController;
@class RoomMemberViewController;
@class PreviewView;
@interface NMultiVideoViewController : TipsViewController<UICollectionViewDataSource,UICollectionViewDelegate,QAVRoomDelegate,ZZVCRemoteVideoDelegate, ZZVCScreenVideoDelegate>{

    MultiRoomMemberModel* _model;
    UICollectionView* _memberCollectionView;
    MemberData* _currentViewEndpoint;
    UIScrollView* _videoScrollView;
    PreviewView* _previewView;
    UIButton*_cameraBtn;
    NSTimer*_timerUpdateTips;
    int _tipsCount;
    AVGLBaseView *_imageView;
    NSMutableArray *_identifierList;
    NSMutableArray *_srcTypeList;
    AVSingleFrameDispatcher* _frameDispatcher;
    
    BOOL _inBackGround;
}
@property (nonatomic,retain) MultiRoomMemberModel* model;
@property (nonatomic, retain)RoomMemberViewController*roomMemberController;
@property (nonatomic, retain)MultiRoomConfigViewController*roomConfigController;

- (void)playVideoWithVideo:(NSString*)video AndFrame:(NSString*)frame;
@end
