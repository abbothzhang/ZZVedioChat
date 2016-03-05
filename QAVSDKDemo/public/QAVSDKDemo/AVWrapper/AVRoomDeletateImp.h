//
//  AVManagerImp.h
//  AVTest
//
//  Created by TOBINCHEN on 14-10-10.
//  Copyright (c) 2014年 TOBINCHEN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AVManager.h"
#include "av_sdk.h"

@class AVBasicManager;
/**
 *  由于底层是c++实现的，为了将底层的调用转换成OC的调用，同时隐藏C++的对象，用这个匿名协议来转发
 */
@interface NSObject (RoomDelegate)
-(void)_OnContextStartComplete:(int)result;
-(void)_OnContextCloseComplete;

-(void)_OnEnterRoomComplete:(int)result;
-(void)_OnRoomJoinComplete:(int)result;
-(void)_OnExitRoomComplete:(int)result;

-(void)_OnVideoframeData:(tencent::av::VideoFrame*)frameData;

-(void)_OnRequestViewComplete:(std::string)identifier result:(int)result;
-(void)_OnCancelViewComplete:(std::string)identifier result:(int)result;

//-(void)_OnRequestViewListComplete:(std::string[])identifierList count:(int)count result:(int)result;
//-(void)_OnCancelAllViewComplete:(int)result;

-(void)_OnQueryRoomInfoComplete:(tencent::av::AVRoom::Info*)info result:(int)result;

-(void)_OnEnableCameraComplete:(bool)bEnable result:(int)result;
-(void)_OnSwitchCameraComplete:(int)cameraId result:(int)result;
@end


/**
 *  C++回调转发
 */

class AVBasicRoomDeletateImp:public tencent::av::AVRoom::Delegate{
public:
    AVBasicRoomDeletateImp(){};
    virtual ~AVBasicRoomDeletateImp(){};
    
    void setContextDelegate(id delegate){
        _roomDelegate=delegate;
    };
public:
    
    virtual void OnEnterRoomComplete(int result) {
        [_roomDelegate _OnEnterRoomComplete:result];
    }
    
    virtual void OnExitRoomComplete(int result) {
        [_roomDelegate _OnExitRoomComplete:result];
    }
    
    static void OnContextStartComplete(int result, void* custom_data)
    {
        AVBasicRoomDeletateImp* brg=(AVBasicRoomDeletateImp*)custom_data;
        if (brg) {
            [brg->_roomDelegate _OnContextStartComplete:result];
        }
    }
    static void OnContextCloseComplete(void* custom_data)
    {
        AVBasicRoomDeletateImp* brg=(AVBasicRoomDeletateImp*)custom_data;
        if (brg) {
            [brg->_roomDelegate _OnContextCloseComplete];
        }
    }
    
    
//用于测试请求多人画面
//#define SUPPORT_MULTI_VIEW

    static void RequestViewListCompleteCallback(std::vector<std::string> identifierList, std::vector<tencent::av::View> viewList, int result, void* customData)
    {
        AVBasicRoomDeletateImp* brg=(AVBasicRoomDeletateImp*)customData;
        if (brg) {
            std::string request_identifier;
            if(identifierList.size() > 0)request_identifier = identifierList[0];//TODO
            [brg->_roomDelegate _OnRequestViewComplete:request_identifier result:result];
        }
    }
    static void CancelAllViewCompleteCallback(int result, void* customData)
    {
        AVBasicRoomDeletateImp* brg=(AVBasicRoomDeletateImp*)customData;
        if (brg) {
            std::string request_identifier;
            [brg->_roomDelegate _OnCancelViewComplete:request_identifier result:result];
        }
    }

    static void VideoframeDataCallback(tencent::av::VideoFrame* frameData, void* customData)
    {
        AVBasicRoomDeletateImp* brg=(AVBasicRoomDeletateImp*)customData;
        if (brg) {
            [brg->_roomDelegate _OnVideoframeData:frameData];
        }
        
    }
    
    
    static void OnEnableCameraComplete(bool bEnable,int result,void* custom_data)
    {
        AVBasicRoomDeletateImp* brg=(AVBasicRoomDeletateImp*)custom_data;
        if (brg) {
            [brg->_roomDelegate _OnEnableCameraComplete:bEnable result:result];
        }
    }
    
    static void OnSwitchCameraComplete(int cameraId,int result,void* custom_data)
    {
        AVBasicRoomDeletateImp* brg=(AVBasicRoomDeletateImp*)custom_data;
        if (brg) {
            [brg->_roomDelegate _OnSwitchCameraComplete:cameraId result:result];
        }
    }
protected:
    id _roomDelegate;
};

