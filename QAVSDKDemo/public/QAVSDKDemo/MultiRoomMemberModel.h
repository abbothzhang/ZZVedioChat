//
//  MultiRoomMemberModel.h
//  QAVSDKDemo_P
//
//

#import <Foundation/Foundation.h>

extern NSString* EndpointStateUpdate;

/**
 *  成员状态
 */
typedef NS_OPTIONS(NSUInteger, EndpointStateType){
    /**
     *  为定义状态
     */
    EndpointStateTypeNull = 0,
    /**
     *  开启语音
     */
    EndpointStateTypeAudio = 1 << 0,
    /**
     *  开启摄像头
     */
    EndpointStateTypeCamera= 1 << 1,
	
	/**
     *  开启屏幕分享
     */
    EndpointStateTypeScreen= 1 << 2,
};


@interface MemberData:NSObject{
    
}
@property(copy,nonatomic) NSString* identifier;
@property(assign,nonatomic)BOOL isCameraVideo;
@property(assign,nonatomic)BOOL isScreenVideo;
@property(assign,nonatomic)BOOL isAudio;
@end

@interface MultiRoomMemberModel : NSObject{
    NSMutableArray* _audioAndCameraEndpoints;
    NSMutableArray* _screenEndpoints;
    NSMutableArray* _endpoints;
    NSInteger _roomId;
}
@property (nonatomic,readonly,retain) NSMutableArray* endpoints;
@property (nonatomic,assign) NSInteger roomId;

-(void)updateAudioAndCameraMember:(NSArray*)identifiers;
-(void)updateScreenMember:(NSArray*)identifiers;

@end
