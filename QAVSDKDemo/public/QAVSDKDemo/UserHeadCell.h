//
//  UserHeadCell.h
//  QAVSDKDemo_P
//
//  Created by TOBINCHEN on 14-11-17.
//  Copyright (c) 2014年 TOBINCHEN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MultiRoomMemberModel.h"


extern NSString* const UserHeadCellID;


@interface UserHeadCell : UICollectionViewCell{
    UIImageView* _headView;
    UILabel* _nameLabel;
    UIImageView* _statusView;
    EndpointStateType _endpointStateTypes;
}
@property (retain,readonly,nonatomic) UIImageView* headView;
@property (retain,readonly,nonatomic) UILabel* nameLabel;
@property (assign,nonatomic) EndpointStateType endpointStateTypes;
@property (assign,readonly,nonatomic) EndpointStateType selectedSrcType;
@end


