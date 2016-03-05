//
//  AVPairManager.m
//  QAVSDKDemo_P
//
//  Created by TOBINCHEN on 14-10-27.
//  Copyright (c) 2014年 TOBINCHEN. All rights reserved.
//

#import "AVPairManager.h"
#import "AVManager_Protected.h"
#import "AVPairRoomDelegateImp.h"


@interface AVPairManager (){
}
@property (nonatomic,assign,readonly)AVPairRoomDelegateImp* delegateImp;
@end

@implementation AVPairManager
+(AVPairManager*)shareManager{
    static AVPairManager* manager=nil;
    if (manager==nil) {
        manager= [[AVPairManager alloc] init];
    }
    return manager;
}
-(id)init{
    self=[super init];
    if (self) {
        _roomType=AVRoomType_Pair;
        _delegateImp=new AVPairRoomDelegateImp;
        self.delegateImp->setContextDelegate(self);
    }
    return self;
}
-(void)dealloc
{
    [super dealloc];
}

-(BOOL)createRoom:(NSString*)rid withMode:(Mode)mode completion:(AVCompletion)completion
{
    tencent::av::AVRoomPair::EnterRoomParam pairRoomParam;
    pairRoomParam.peer_identifier = (char*) rid.UTF8String;
    if (mode == MODE_AUDIO) {
        pairRoomParam.mode = tencent::av::AVRoomPair::MODE_AUDIO;
    }
    else if (mode == MODE_VIDEO)
    {
        pairRoomParam.mode = tencent::av::AVRoomPair::MODE_VIDEO;
    }
    
    return [super _createRoom:&pairRoomParam completion:completion];
}

-(BOOL)joinRoom:(unsigned long long)roomId rid:(NSString*)rid completion:(AVCompletion)completion
{
    tencent::av::AVRoomPair::EnterRoomParam pairJoinRoomParam;
    pairJoinRoomParam.peer_identifier = (char*) rid.UTF8String;
    pairJoinRoomParam.room_id = roomId;
    pairJoinRoomParam.mode = tencent::av::AVRoom::MODE_AUDIO;
    
    return [super _createRoom:&pairJoinRoomParam completion:completion];
}

-(AVPairRoomDelegateImp*)delegateImp{
    return (AVPairRoomDelegateImp*)_delegateImp;
}
-(BOOL)doRequestView:(NSArray*)identifier_list
{
    if (!self.avContect) {
        return NO;
    }
 /*
    tencent::av::AVEndpoint::View view;
    if (endpointStateType==EndpointStateTypeCamera) {
        view.video_src_type=tencent::av::VIDEO_SRC_TYPE_CAMERA;//TODO:转换视频源类型
    }*/
#ifdef _ENABLE_PAIR_ROOM
    tencent::av::AVRoomPair* pairRoom=dynamic_cast<tencent::av::AVRoomPair*>(self.avContect->GetRoom());
    if (pairRoom) {
//        tencent::av::AVEndpoint* endpoint=pairRoom->GetEndpoint();
//        if (endpoint) {
//            return endpoint->RequestView(view, AVBasicRoomDeletateImp::RequestViewCompleteCallback, _delegateImp)== tencent::av::AV_OK;
//        }
    }
#endif
    return NO;
}
-(BOOL)doCancelView:(AVEndpointInfo*)aEndpoint;
{
    if (!self.avContect) {
        return NO;
    }
#ifdef _ENABLE_PAIR_ROOM
    tencent::av::AVRoomPair* pairRoom=dynamic_cast<tencent::av::AVRoomPair*>(self.avContect->GetRoom());
    if (pairRoom) {
//        tencent::av::AVEndpoint* endpoint=pairRoom->GetEndpoint();
//        if (endpoint) {
//            return endpoint->CancelView(AVBasicRoomDeletateImp::CancelViewCompleteCallback, _delegateImp)==tencent::av::AV_OK;
//        }
    }
#endif
    return NO;
}

-(void)initRenderDevice
{
    [super initRenderDevice];
    
    if (!self.avContect) {
        return ;
    }
    tencent::av::AVRoomPair* pairRoom=dynamic_cast<tencent::av::AVRoomPair*>(self.avContect->GetRoom());
    if (pairRoom) {
        //TODO add by darrenhe
        //pairRoom->StartRemoteVideoRender();
    }
}
-(void)uninitRenderDevice
{
    tencent::av::AVRoomPair* pairRoom=dynamic_cast<tencent::av::AVRoomPair*>(self.avContect->GetRoom());
    if (pairRoom) {
        //TODO add by darrenhe
        //pairRoom->StopRemoteVideoRender();
    }
    
    [super uninitRenderDevice];
    
    if (!self.avContect) {
        return ;
    }
}

#pragma mark - 接受邀请时判断语音还是视频从而开启摄像头 -
- (void)getRoomModeWhileReceving
{
    tencent::av::AVRoomPair* pairRoom = dynamic_cast<tencent::av::AVRoomPair*>(self.avContect->GetRoom());
    if (pairRoom) {
        tencent::av::AVRoomPair::Info *info = (tencent::av::AVRoomPair::Info*)pairRoom->GetRoomInfo();
        tencent::av::AVRoomPair::Mode mode = info->mode;
        if (mode == tencent::av::AVRoomPair::MODE_AUDIO) {
            [AVPairManager shareManager].currentMode = MODE_AUDIO;
        }
        else if (mode == tencent::av::AVRoomPair::MODE_VIDEO)
        {
            [AVPairManager shareManager].currentMode = MODE_VIDEO;
        }
    }
}


#pragma mark 底层通知
-(void)_OnRoomPeerEnter:(int)result
{
    self.roomState=AVRoomStateInRoom;
    [self getRoomModeWhileReceving];
    
    [_delegate OnRoomPeerEnter];
}

-(void)_OnRoomPeerLeave:(int)result
{
    self.roomState=AVRoomStateOutRoom;
    [_delegate OnRoomPeerLeave];
}

-(void)_OnRoomPeerUpdate:(BOOL)bMic isCamOpen:(BOOL)bCam
{
    [_delegate _OnRoomPeerUpdate:bMic isCamOpen:bCam];
}


-(void)_OnCameraStart:(int)result{
        [_delegate OnPeerAvShift:YES];
}
-(void)_OnCameraClose:(int)result{
        [_delegate OnPeerAvShift:NO];
}
-(void)_OnMicStart:(int)result{
       [_delegate OnMicShift:YES];
}
-(void)_OnMicClose:(int)result{
       [_delegate OnMicShift:NO];
}

-(void)_OnPeerAvShift:(int)result{
    [self uninitRenderDevice];
}

-(NSString*)GetVideoTips{
    if (self.avContect){
        tencent::av::AVVideoCtrl*pCtrl = self.avContect->GetVideoCtrl();
        if (pCtrl){
            NSString*strTips = [NSString stringWithFormat:
                                @"%s",
                                pCtrl->GetQualityTips().c_str()];
            
            
            return strTips;
        }
        
        
    }
    return @"multi";
}

-(AVRoomInfo*)roomInfo
{
    if (!self.avContect) {
        return nil;
    }
    
    tencent::av::AVRoom *pRoom =  self.avContect->GetRoom();
    if (!pRoom)
        return NULL;
    tencent::av::AVRoomPair::Info *info = (tencent::av::AVRoomPair::Info*)pRoom->GetRoomInfo();

    AVRoomInfo* roomInfo= (AVRoomInfo*)[[AVRoomInfo alloc] initWithInfo:info];
    return roomInfo;
}

@end
