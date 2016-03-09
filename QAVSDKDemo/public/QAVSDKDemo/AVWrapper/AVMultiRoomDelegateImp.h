//
//  AVMultiManagerImp.h
//  QAVSDKDemo_P
//
//  Created by TOBINCHEN on 14-10-27.
//  Copyright (c) 2014年 TOBINCHEN. All rights reserved.
//
#import "AVRoomDeletateImp.h"
#import "AVLog.h"


@interface NSObject (MultiRoomDelegate)
-(void)_OnSubVideoframeData:(tencent::av::VideoFrame*)frameData;
-(void)_OnBanComplete:(tencent::av::AVEndpoint*)endpoint result:(int)result;

//-(void)_OnEndpointsEnterRoom:(int)endpoint_count list:(tencent::av::AVEndpoint**)endpoint_list;
//-(void)_OnEndpointsExitRoom:(int)endpoint_count list:(tencent::av::AVEndpoint**)endpoint_list;
-(void)_OnEndpointsUpdateInfo:(int)eventid list:(std::vector<std::string>)updatelist;
-(void)_LocalPreviewCallback:(tencent::av::AudioFrame*)frame;
-(void)_OnEnableExternalCaptureComplete:(bool)is_enable result:(int)result;
-(void)_OnChangeAuthority:(int)ret_code;
@end

/**
 *  多人特有的回调转发
 */
class AVMultiRoomDelegateImp:public AVBasicRoomDeletateImp,public tencent::av::AVRoomMulti::Delegate{
public:
    AVMultiRoomDelegateImp(){};
    ~AVMultiRoomDelegateImp(){};
    
public:
    
    virtual void OnEnterRoomComplete(int result) {
        AVBasicRoomDeletateImp::OnEnterRoomComplete(result);
    }
    
    virtual void OnExitRoomComplete(int result) {
        AVBasicRoomDeletateImp::OnExitRoomComplete(result);
    }
    /*
    virtual void OnEndpointsEnterRoom(int endpoint_count, tencent::av::AVEndpoint* endpoint_list[])
    {
        for (int i = 0; i < endpoint_count; i++) {
            tencent::av::AVEndpoint* point = endpoint_list[i];
            AVLog(@"OnEndpointsEnterRoom:<%d,%s>",i,point->GetId().c_str());
        }
        [this->roomDelegate() _OnEndpointsEnterRoom:endpoint_count list:endpoint_list];
        
    }
    virtual void OnEndpointsExitRoom(int endpoint_count, tencent::av::AVEndpoint* endpoint_list[])
    {
        for (int i = 0; i < endpoint_count; i++) {
            tencent::av::AVEndpoint* point = endpoint_list[i];
            AVLog(@"OnEndpointsExitRoom:<%d,%s>",i,point->GetId().c_str());
        }
        [this->roomDelegate() _OnEndpointsExitRoom:endpoint_count list:endpoint_list];
        
    }
    virtual void OnEndpointsUpdateInfo(int endpoint_count, tencent::av::AVEndpoint* endpoint_list[])
    {
        for (int i = 0; i < endpoint_count; i++) {
            tencent::av::AVEndpoint* point = endpoint_list[i];
            AVLog(@"OnEndpointsUpdateInfo:<%d,%s>",i,point->GetId().c_str());
        }
        [this->roomDelegate() _OnEndpointsUpdateInfo:endpoint_count list:endpoint_list];
        
    }*/
    virtual void OnEndpointsUpdateInfo(tencent::av::AVRoom::EndpointEventId eventid, std::vector<std::string> updatelist){
        [this->roomDelegate() _OnEndpointsUpdateInfo:eventid list:updatelist];
    }
    virtual void OnRoomConnectTimeout(){
        
        [this->roomDelegate() OnRoomConnectTimeout];
    }
    virtual void OnPrivilegeDiffNotify(int32 privilege){
        //TODO
    }
    virtual void OnChangeAuthority(int32 ret_code){
        [this->roomDelegate() _OnChangeAuthority:ret_code];
    }
    
    static void SubVideoframeDataCallback(tencent::av::VideoFrame* frameData, void* customData)
    {
        AVMultiRoomDelegateImp* brg=(AVMultiRoomDelegateImp*)customData;
        if (brg) {
            [brg->roomDelegate() _OnSubVideoframeData:frameData];
        }
    }
    
    static void LocalPreviewCallback(tencent::av::AudioFrame* video_frame, void* custom_data)
    {
        AVMultiRoomDelegateImp* brg=(AVMultiRoomDelegateImp*)custom_data;
        if (brg) {
            [brg->roomDelegate() _LocalPreviewCallback:video_frame];
        }
    
    }
    static void BanViewCompleteCallback(tencent::av::AVEndpoint* endpoint, int result, void* customData)
    {
        AVMultiRoomDelegateImp* brg=(AVMultiRoomDelegateImp*)customData;
        if (brg) {
            [brg->roomDelegate() _OnBanComplete:endpoint result:result];
        }
    }
    
    static void EnableExternalCaptureCompleteCallback(bool is_enable, int ret_code, void* custom_data)
    {
        AVMultiRoomDelegateImp* brg=(AVMultiRoomDelegateImp*)custom_data;
        if (brg) {
            [brg->roomDelegate() _OnEnableExternalCaptureComplete:is_enable result:ret_code];
        }
        
    }
private:
    id roomDelegate()
    {
        return _roomDelegate;
    }
};