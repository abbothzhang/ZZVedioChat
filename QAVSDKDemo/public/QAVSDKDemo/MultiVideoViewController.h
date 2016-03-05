//
//  FirstViewController.h
//  AVTest
//
//  Created by TOBINCHEN on 14-8-13.
//  Copyright (c) 2014年 TOBINCHEN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AVMultiManager.h"


@interface PlayerView : UIView{
    UIView* _videoView;
}
@property (nonatomic,retain) UIView* videoView;
@end

@interface MultiVideoViewController : UIViewController<AVMultiManagerDelegate>{
    IBOutlet UICollectionView* _collectionView;
    IBOutlet PlayerView* _videoView;
    IBOutlet PlayerView* _videoView1;
    IBOutlet UIControl* _previewView;
    IBOutlet UIButton* _btnCreateRoom;
    IBOutlet UIButton* _btnEnterRoom;
    IBOutlet UIButton* _btnLeaveRoom;
    IBOutlet UIButton* _btnDissolveRoom;
    IBOutlet UITextField* _tfdRoomNumber;
    IBOutlet UILabel* _lbUid;
    NSMutableArray* _users;
    BOOL _bFullScreen;
    AVRender* _render;
    AVRender* _subRender;
    AVEndpointInfo* _currentVideoEndpoint;
    AVCaptureVideoPreviewLayer* _previewLayer;
}
-(IBAction)createRoom:(id)sender;
-(IBAction)enterRoom:(id)sender;
-(IBAction)leaveRoom:(id)sender;
-(IBAction)dissolveRoom:(id)sender;
-(IBAction)toggleMic:(id)sender;
-(IBAction)toggleSpeaker:(id)sender;
-(IBAction)toggleCamera:(id)sender;
-(IBAction)switchCamera:(id)sender;
-(IBAction)switchOutputMode:(id)sender;
-(IBAction)inputFinished:(id)sender;
@end
