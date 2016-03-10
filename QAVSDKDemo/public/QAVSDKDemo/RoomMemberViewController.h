//
//  RoomMenberViewController.h
//  QAVSDKDemo_P
//
//

#import <UIKit/UIKit.h>
#import "MultiRoomMemberModel.h"


@interface RoomMemberViewController : UITableViewController{
    MultiRoomMemberModel* _model;
}

@property (nonatomic,retain) MultiRoomMemberModel* model;
@end
