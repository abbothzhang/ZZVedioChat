//
//  UserHeadCell.m
//  QAVSDKDemo_P
//
//

#import "UserHeadCell.h"

NSString* const UserHeadCellID=@"UserHeadCellID";


@implementation UserHeadCell

-(id)initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    if (self) {
        _headView=[[UIImageView alloc] init];
        _headView.layer.cornerRadius=30;
        _headView.clipsToBounds=YES;
        _headView.backgroundColor=[UIColor whiteColor];
        [self.contentView addSubview:_headView];
        
        _statusView=[[UIImageView alloc] init];
        [self.contentView addSubview:_statusView];
        
        _nameLabel=[[UILabel alloc] init];
        _nameLabel.font=[UIFont systemFontOfSize:10];
        _nameLabel.textAlignment=NSTextAlignmentCenter;
        _nameLabel.textColor=[UIColor whiteColor];
        [self.contentView addSubview:_nameLabel];
        
        self.clipsToBounds=YES;
        //self.backgroundColor=[UIColor grayColor];
    }
    return self;
}
- (void)prepareForReuse
{
    [super prepareForReuse];
    self.endpointStateTypes=EndpointStateTypeNull;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect selfBounds=self.bounds;
    _headView.frame=CGRectMake(0, 0, selfBounds.size.width, selfBounds.size.width);
    _nameLabel.frame=CGRectMake(0-20, selfBounds.size.width, selfBounds.size.width+40, selfBounds.size.height-selfBounds.size.width);
    _statusView.frame=CGRectMake(0, 0, selfBounds.size.width, selfBounds.size.width);
}
-(void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    if (highlighted) {
        self.backgroundColor=[UIColor redColor];
    }else{
        self.backgroundColor=[UIColor clearColor];
    }
}
-(void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    if (selected) {
        _headView.backgroundColor=[UIColor blueColor];
    }else{
        _headView.backgroundColor=[UIColor whiteColor];
    }
}
-(void)setEndpointStateTypes:(EndpointStateType)endpointStateTypes
{
    _endpointStateTypes=endpointStateTypes;
    if (_endpointStateTypes==EndpointStateTypeNull) {
        _statusView.image=nil;
        return;
    }
    if (_endpointStateTypes&EndpointStateTypeCamera) {
        _statusView.image=[UIImage imageNamed:@"head_camera"];
        return;
    }
	
	if (_endpointStateTypes&EndpointStateTypeScreen) {
        _statusView.image=[UIImage imageNamed:@"head_screen"];
        return;
    }
}
-(EndpointStateType)selectedSrcType
{
    return _endpointStateTypes;
}
@end
