//
//  AVPairManagerImp.h
//  QAVSDKDemo_P
//
//  Created by TOBINCHEN on 14-10-27.
//  Copyright (c) 2014年 TOBINCHEN. All rights reserved.
//

#import "AVRoomDeletateImp.h"
#import "AVLog.h"

@interface NSObject (PairRoomDelegate)
-(void)_OnRoomPeerEnter:(int)result;
-(void)_OnRoomPeerLeave:(int)result;
-(void)_OnRoomPeerUpdate:(BOOL)bMic isCamOpen:(BOOL)bCam;
-(void)_OnCameraStart:(int)result;
-(void)_OnCameraClose:(int)result;
-(void)_OnMicStart:(int)result;
-(void)_OnMicClose:(int)result;
-(void)_OnPeerAvShift:(int)result;
@end

/**
 *  双人特有的回调转发
 */
class AVPairRoomDelegateImp:public AVBasicRoomDeletateImp,public tencent::av::AVRoomPair::Delegate{
public:
    AVPairRoomDelegateImp(){_bMic = FALSE, _bCam = FALSE;};
    ~AVPairRoomDelegateImp(){};
    
public:
    
    virtual void OnEnterRoomComplete(int result){
        AVBasicRoomDeletateImp::OnEnterRoomComplete(result);
    }
    
    virtual void OnExitRoomComplete(int result){
        AVBasicRoomDeletateImp::OnExitRoomComplete(result);
    }
 /*
    virtual void OnEndpointsEnterRoom(int endpoint_count, tencent::av::AVEndpoint* endpoint_list[]) {
        [this->roomDelegate() _OnRoomPeerEnter:tencent::av::AV_OK];
        if(endpoint_list != NULL) delete [] endpoint_list;//需要业务侧主动释放这个数组。
    }
    virtual void OnEndpointsExitRoom(int endpoint_count, tencent::av::AVEndpoint* endpoint_list[]) {
        [this->roomDelegate() _OnRoomPeerLeave:tencent::av::AV_OK];
        if(endpoint_list != NULL) delete [] endpoint_list;//需要业务侧主动释放这个数组。
    }

    virtual void OnEndpointsUpdateInfo(int endpoint_count, tencent::av::AVEndpoint* endpoint_list[]) {
        if (endpoint_count == 0)
            return;
        
        tencent::av::AVEndpoint* pPoint = endpoint_list[0];
        
        BOOL bMic = pPoint->HasAudio();
        BOOL bCam = pPoint->HasVideo();
        
        [this->roomDelegate() _OnRoomPeerUpdate:bMic isCamOpen:bCam];
        if(endpoint_list != NULL) delete [] endpoint_list;//需要业务侧主动释放这个数组。
    }*/
    
    virtual void OnEndpointsUpdateInfo(tencent::av::AVRoom::EndpointEventId eventid, std::vector<std::string> updatelist){
        if(eventid == tencent::av::AVRoom::EVENT_ID_ENDPOINT_ENTER)
        {
            [this->roomDelegate() _OnRoomPeerEnter:tencent::av::AV_OK];
        }
        else if (eventid == tencent::av::AVRoom::EVENT_ID_ENDPOINT_EXIT)
        {
            [this->roomDelegate() _OnRoomPeerLeave:tencent::av::AV_OK];
        }
        else if(eventid == tencent::av::AVRoom::EVENT_ID_ENDPOINT_HAS_VIDEO)
        {
            _bCam = TRUE;
            [this->roomDelegate() _OnRoomPeerUpdate:_bMic isCamOpen:_bCam];
            
        }
        else if(eventid == tencent::av::AVRoom::EVENT_ID_ENDPOINT_NO_VIDEO)
        {
            _bCam = FALSE;
            [this->roomDelegate() _OnRoomPeerUpdate:_bMic isCamOpen:_bCam];
        }
        else if(eventid == tencent::av::AVRoom::EVENT_ID_ENDPOINT_HAS_AUDIO)
        {
            _bMic = TRUE;
            [this->roomDelegate() _OnRoomPeerUpdate:_bMic isCamOpen:_bCam];
        }
        else if(eventid == tencent::av::AVRoom::EVENT_ID_ENDPOINT_NO_AUDIO)
        {
            _bMic = FALSE;
            [this->roomDelegate() _OnRoomPeerUpdate:_bMic isCamOpen:_bCam];
        }
    }
    
    virtual void OnPrivilegeDiffNotify(int32 privilege)
    {
        //TODO
    }
    
    virtual void OnCameraStart(){
        [this->roomDelegate() _OnCameraStart:tencent::av::AV_OK];
    }
    virtual void OnCameraClose(){
        [this->roomDelegate() _OnCameraClose:tencent::av::AV_OK];
    }
    virtual void OnMicStart(){
        [this->roomDelegate() _OnMicStart:tencent::av::AV_OK];
    }
    virtual void OnMicClose(){
        [this->roomDelegate() _OnMicClose:tencent::av::AV_OK];
    }
    virtual void OnPeerAvShift(){
        [this->roomDelegate() _OnPeerAvShift:tencent::av::AV_OK];
    }
private:
    id roomDelegate()
    {
        return _roomDelegate;
    }
    
    BOOL _bMic;
    BOOL _bCam;
};