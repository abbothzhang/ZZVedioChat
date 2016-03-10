//
//  RoomConfigViewController.h
//  QAVSDKDemo_P
//
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
