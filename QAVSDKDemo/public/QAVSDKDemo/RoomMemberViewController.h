//
//  RoomMenberViewController.h
//  QAVSDKDemo_P
//
//  Created by TOBINCHEN on 14-11-19.
//  Copyright (c) 2014年 TOBINCHEN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MultiRoomMemberModel.h"


@interface RoomMemberViewController : UITableViewController{
    MultiRoomMemberModel* _model;
}

@property (nonatomic,retain) MultiRoomMemberModel* model;
@end
