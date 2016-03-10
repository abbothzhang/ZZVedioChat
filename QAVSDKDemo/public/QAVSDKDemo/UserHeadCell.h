//
//  UserHeadCell.h
//  QAVSDKDemo_P
//
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


