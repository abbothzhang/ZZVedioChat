//
//  NMultiVideoViewController.h
//  QAVSDKDemo_P
//
//

#import <UIKit/UIKit.h>
#import "MultiRoomMemberModel.h"
#import "TipsViewController.h"
#import "QAVSDK/QAVContext.h"
#import "QAVSDK/QAVSDK.h"
#import "AVGLBaseView.h"
#import "AVFrameDispatcher.h"


@class MultiRoomConfigViewController;
@class RoomMemberViewController;
@class PreviewView;
@interface NMultiVideoViewController : TipsViewController<UICollectionViewDataSource,UICollectionViewDelegate,QAVRoomDelegate,QAVRemoteVideoDelegate, QAVScreenVideoDelegate>{

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
