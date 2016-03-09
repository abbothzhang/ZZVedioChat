//
//  AVManager.m
//  AVTest
//
//  Created by TOBINCHEN on 14-10-9.
//  Copyright (c) 2014 TOBINCHEN. All rights reserved.
//

#import "AVManager.h"
#import "AVManager_Protected.h"
#import "AVRoomDeletateImp.h"
#import "AVLog.h"
#import <objc/runtime.h>
#import "UserConfig.h"
#import <ImSDK/IMSdkInt.h>
#import <ImSDK/TIMManager.h>
#import "AVUtil.h"
#import "AKNetworkReachability.h"
#include "av_sdk.h"

@implementation AVEndpointInfo(Private)

+(EndpointStateType)convertEndpointStateType:(tencent::av::AVEndpoint*)endpoint
{
    EndpointStateType retEndpointStateTypes=EndpointStateTypeNull;
    if (endpoint->HasAudio()) {
        retEndpointStateTypes=retEndpointStateTypes|EndpointStateTypeAudio;
    }
    if(endpoint->HasVideo()){
        retEndpointStateTypes=retEndpointStateTypes|EndpointStateTypeCamera;
    }
        return retEndpointStateTypes;
}
-(id)initWithEndpoint:(tencent::av::AVEndpoint*)endpoint{
    self=[super init];
    if (self) {
        tencent::av::AVEndpoint::Info info=endpoint->GetInfo();
        
        _identifier=[[NSString alloc] initWithUTF8String:endpoint->GetId().c_str()];
        
        _sdkVersion=info.sdk_version;
        _terminalType=info.terminal_type;
        _has_audio=info.has_audio;
        _has_camera_video=info.has_camera_video;
        _is_mute=info.is_mute;
        
        _stateTypes=[AVEndpointInfo convertEndpointStateType:endpoint];
        AVLog(@"init user src:%@=>%lu",_identifier,(unsigned long)_stateTypes);
    }
    return self;
}
-(void)updateWithEndpoint:(tencent::av::AVEndpoint*)endpoint{
    if (endpoint) {
        tencent::av::AVEndpoint::Info info=endpoint->GetInfo();
        
        [_identifier release];
        _identifier=[[NSString alloc] initWithUTF8String:endpoint->GetId().c_str()];

        
        _sdkVersion=info.sdk_version;
        _terminalType=info.terminal_type;
        _has_audio=info.has_audio;
        _has_camera_video=info.has_camera_video;
        _is_mute=info.is_mute;
        _stateTypes=[AVEndpointInfo convertEndpointStateType:endpoint];
        AVLog(@"update user src:%@=>%d",_identifier,_stateTypes);
    }
}

@end


@implementation AVRoomInfo(Private)

-(id)initWithInfo:(tencent::av::AVRoom::Info*)info{
    self=[super init];
    if (self) {
        _roomType=info->room_type;
        _roomId=info->room_id;
        _relationType=info->relation_type;
        _relationId=info->relation_id;
    }
    return self;
}

@end

@implementation AVFrameInfo(Private)

-(id)initWithFrame:(tencent::av::VideoFrame *)videoFrame
{
    self=[super init];
    if (self) {
        
        self.identifier=[[[NSString alloc] initWithUTF8String:videoFrame->identifier.c_str()] autorelease];
        self.data=[[[NSData alloc] initWithBytesNoCopy:videoFrame->data length:videoFrame->data_size freeWhenDone:NO] autorelease];
        
        
        self.width=videoFrame->desc.width;
        self.height=videoFrame->desc.height;
        self.rotate=videoFrame->desc.rotate;
        self.source_type=videoFrame->desc.src_type;
        //self.color_format = videoFrame->desc.color_format; TODO
    }
    
    return self;
}
@end



@implementation ContextConfig
@end

tencent::av::AVContext* _avContext = NULL;

@implementation AVBasicManager

-(id)init{
    if( [self class] != [AVBasicManager class]){
        self=[super init];
        if (self) {
            _roomType=AVRoomType_Null;
            _endpoints =[[NSMutableDictionary alloc] init];
            _completions=[[NSMutableDictionary alloc] init];
            self.roomState=AVRoomStateNull;
            _contextStartCompletion = NULL;
            _enableCameraCompletion = NULL;
            _switchCameraCompletion = NULL;
            _enterRoomCompletion = NULL;
        }
    }else{
        NSAssert(false, @"You cannot init AVBasicManager directly. Instead, use a subclass e.g. AVMultiManager");
        [self release];
        self = nil;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnNetStatChanged:) name:kAKSDKPublicReachabilityChangedNotification object:nil];
    
    return self;
}
-(void)dealloc
{
    [_endpoints release];
    [_config release];
    [super dealloc];
}

-(void)setRoomState:(AVRoomState)roomState
{
    _roomState=roomState;
}
-(tencent::av::AVContext*)avContect
{
    return _avContext;
}

-(void)OnNetStatChanged:(NSNotification*)notificatio{
    tencent::av::AVRoom *pRoom = NULL;
    if (_avContext){
       pRoom = _avContext->GetRoom();
    }
    if (pRoom){
        pRoom->SetNetType([self getCurNetType]);
    }
    
    AVLog(@"AVManager:OnNetStatChanged new state:%d", [self getCurNetType]);
}

-(BOOL)startContext:(ContextConfig*) aConfig completion:(AVCompletion)completion
{
    if(!_contextStartCompletion){
        _contextStartCompletion=Block_copy(completion);
    }else{
        AVLog(@"startContext failed, has _contextStartCompletion");
        return NO;
    }
    
    if (_config!=aConfig) {
        [_config release];
        _config=[aConfig retain];
    }
    
    int envValue = [UserConfig shareConfig].isTestServer ? 1:0;

    [[TIMManager sharedInstance]setEnv:envValue];
    [[TIMManager sharedInstance]initSdk];
    TIMLoginParam * login_param = [[TIMLoginParam alloc ]init];
    login_param.accountType = aConfig.account_type;
    login_param.identifier = aConfig.identifier;
    login_param.appidAt3rd = aConfig.app_id_at3rd;
    login_param.sdkAppId = aConfig.sdk_app_id;;
    //user_sig随便加一下，不然登不了
    login_param.userSig = @"123";
    [[TIMManager sharedInstance] login:login_param succ:^(){
        NSString*strServerNotice = @"成功登上正式环境";
        AVLog(@"Login Succ");
        if (envValue != 0)
            strServerNotice = @"成功登上测试环境";
        
        UIAlertView*alert = [[UIAlertView alloc]initWithTitle:@"注意"
                                                      message:strServerNotice
                                                     delegate:nil
                                            cancelButtonTitle:@"确定"
                                            otherButtonTitles:nil];
        [alert show];
        tencent::av::AVContext::Config contextConfig;
        contextConfig.sdk_app_id = _config.sdk_app_id;
        contextConfig.app_id_at3rd=_config.app_id_at3rd.UTF8String;
        contextConfig.identifier=_config.identifier.UTF8String;
        contextConfig.account_type=_config.account_type.UTF8String;

        
        if (!_avContext) {
            _avContext = tencent::av::AVContext::CreateContext(contextConfig);
        }
        
        _avContext->StartContext(AVBasicRoomDeletateImp::OnContextStartComplete, _delegateImp);

    } fail:^(int code, NSString * err) {
        
        if (_contextStartCompletion){
            _contextStartCompletion((AVResult)tencent::av::AV_ERR_FAILED);
            _contextStartCompletion = nil;
        }
        
        NSString*strError = [NSString stringWithFormat:@"登录失败，错误码:%d 错误信息:%@", code, err];
        UIAlertView*alert = [[UIAlertView alloc]initWithTitle:@"注意"
                                                      message:strError
                                                     delegate:nil
                                            cancelButtonTitle:@"确定"
                                            otherButtonTitles:nil];
        AVLog(@"login failed!!code:%d err:%s", code, [err cStringUsingEncoding:NSUTF8StringEncoding]);
        [alert show];
    }];

    return YES;
    
}

-(BOOL)closeContext:(AVCompletion) completion
{
    if (!_contextCloseCompletion) {
        _contextCloseCompletion=Block_copy(completion);
    }else{
        return NO;
    }
    self.renderCheckTimer = nil;
    
    if (!_avContext) {
        return NO;
    }
 
    _avContext->StopContext(AVBasicRoomDeletateImp::OnContextCloseComplete,_delegateImp);
    return YES;
}

-(BOOL)hasContext
{
    return _avContext!=NULL;
}
-(BOOL)_createRoom:(tencent::av::AVRoom::EnterRoomParam*) param completion:(AVCompletion)completion
{
    if (!param) {
        return NO;
    }
    
    if (!_avContext) {
        return NO;
    }
    
    _enterRoomCompletion=Block_copy(completion);
    
    tencent::av::AVVideoCtrl* videoCtrl=_avContext->GetVideoCtrl();

    if (videoCtrl) {
        
		/*
        tencent::av::VideoCodecParam param;
        param.codec_type = tencent::av::VIDEO_CODEC_TYPE_H264;
        NSString *temp = @"1";
        if ([[UserConfig shareConfig].sdkAppIdToken isEqualToString:(temp)]) {
            param.width = 480;
            param.height = 360;
        }
        else
        {
            param.width = 320;
            param.height = 240;

        }
        param.fps = 12;
        param.bitrate = 0;
        param.maxqp = 35;
        param.minqp = 0;
        param.gop = 50;
        param.qclear = 1;
        param.qclear_grade = 0;
        param.fec_switch = 0;
        param.max_width = 0;
        param.max_height = 0;
        param.max_bitrate = 300;
        param.min_bitrate = 200;
        //param.small_vid_swh = 2;
        //param.anchor_type = 0;
        videoCtrl->SetCustomVideoCodecParam(param);
		*/
    }

    NSString *HostAppid = @"1104062745";
    if ([[UserConfig shareConfig].sdkAppId isEqualToString:(HostAppid)]) {
        //_avContext->EnableHostMode();
    }
    
    if (_avContext->EnterRoom(_delegateImp, param)==tencent::av::AV_OK){
        self.roomState=AVRoomStateCreatingRoom;
        return YES;
    }else{
        Block_release(_enterRoomCompletion);
        _enterRoomCompletion=nil;
        return NO;
    }
}
-(BOOL)_joinRoom:(tencent::av::AVRoom::EnterRoomParam*)param completion:(AVCompletion)completion
{
    if (!param) {
        return NO;
    }
    
    if (!_avContext) {
        return NO;
    }
    
    if (_enterRoomCompletion) {
        return NO;
    }else{
        _enterRoomCompletion=Block_copy(completion);
    }
    
    if (_avContext->EnterRoom(_delegateImp, param)==tencent::av::AV_OK){
        self.roomState=AVRoomStateCreatingRoom;
        return YES;
    }else{
        Block_release(_enterRoomCompletion);
        _enterRoomCompletion=nil;
        return NO;
    }

}

-(BOOL)closeRoom:(AVCompletion)completion
{
    if (!_avContext) {
        return NO;
    }
    
//    if (_closeRoomCompletion) {
//        AVLog(@"closeRoom not finished");
//        return NO;
//    }else
    {
        _closeRoomCompletion=Block_copy(completion);
    }
    
    self.roomState=AVRoomStateClosingRoom;
    if(_avContext->ExitRoom()==tencent::av::AV_OK){
        return YES;
    }else{
        Block_release(_closeRoomCompletion);
        _closeRoomCompletion=nil;
        self.roomState = AVRoomStateNull;
        return NO;
    }
}
-(void)setTimeoutIntervel:(NSUInteger)interval
{
    //NO IMPLEMENT
    return;
}

//-(AVRoomInfo*)roomInfo
//{
//    if (!_avContext) {
//        return nil;
//    }
//    
//    tencent::av::AVRoom*pRoom = _avContext->GetRoom();
//    if (!pRoom)
//        return NULL;
//    
//    tencent::av::AVRoom::Info info= pRoom->GetRoomInfo();
//    AVRoomInfo* roomInfo=[[AVRoomInfo alloc] initWithInfo:&info];
//    return [roomInfo autorelease];
//}

-(BOOL)queryRoomInfo:(unsigned long long)roomId relationType:(unsigned short)relationType completion:(AVRoomInfoCompletion)completion
{
    //NO IMPLEMENT
    return NO;
}

-(AVCaptureVideoPreviewLayer*)previewLayer
{
    if (!_avContext) {
        return nil;
    }
    tencent::av::AVDeviceMgr* device_mgr = _avContext->GetVideoDeviceMgr();
    tencent::av::AVDevice** device_array = NULL;
    int camera_count = device_mgr->GetDeviceByType(DEVICE_CAMERA, &device_array);
    for (int i = 0; i < camera_count; i++) {
        tencent::av::AVCameraDevice* dev = (tencent::av::AVCameraDevice*)device_array[i];
        return (__bridge id)dev->GetPreviewLayer();
    }
    if(device_array)delete [] device_array;//业务侧要主动释放这个数组。
    return nil;
    
}

-(AVCaptureSession*)getCaptureSession{
    
    if (!_avContext) {
        return nil;
    }
    
    AVCaptureSession*session = nil;
    
    tencent::av::AVDeviceMgr* device_mgr = _avContext->GetVideoDeviceMgr();
    tencent::av::AVDevice** device_array = NULL;
    int camera_count = device_mgr->GetDeviceByType(DEVICE_CAMERA, &device_array);
    for (int i = 0; i < camera_count; i++) {
        tencent::av::AVCameraDevice* dev = (tencent::av::AVCameraDevice*)device_array[i];
        session = (__bridge id)dev->GetCameraSession();
        break;
    }
    
    if(device_array)delete [] device_array;//业务侧要主动释放这个数组。
    return session;
    
}
-(NSUInteger)CameraCount
{
    if (!_avContext) {
        return NO;
    }
    tencent::av::AVVideoCtrl* videoCtrl=_avContext->GetVideoCtrl();
    if (videoCtrl) {
        return videoCtrl->GetCameraNum();
    }
    return 0;
}
-(BOOL)enableCamera:(BOOL)bEnable  completion:(AVEnableCameraCompleteCompletion)completion
{
    if (!_avContext) {
        return NO;
    }
    int nRet = _avContext->GetVideoCtrl()->EnableCamera(0,bEnable,AVBasicRoomDeletateImp::OnEnableCameraComplete,_delegateImp);
    if (nRet == tencent::av::AV_OK){
        if (_enableCameraCompletion) {
            AVLog(@"enableCamera failed waiting for previous oepration");
            return NO;
        }else{
            _enableCameraCompletion=Block_copy(completion);
        }
    }
    else{
        if (!_enableCameraCompletion) {
            AVLog(@"enableCamera failed ret:%d", nRet);
            return NO;
        }
        else{
            _enableCameraCompletion=Block_copy(completion);
        }
    }


    return nRet == tencent::av::AV_OK;
}
-(BOOL)enableSpeaker:(BOOL)bEnable
{
    if (!_avContext) {
        return NO;
    }
    tencent::av::AVAudioCtrl* audioCtrl=_avContext->GetAudioCtrl();
    if (audioCtrl) {
        return audioCtrl->EnableSpeaker(bEnable)==tencent::av::AV_OK;
    }
    return NO;
    
}
-(BOOL)selectCamera:(BOOL)bFront  completion:(AVSwitchCameraCompleteCompletion)completion
{
    if (!_avContext) {
        return NO;
    }

    
    int deviceId=bFront?1:0;
    
    int ret = _avContext->GetVideoCtrl()->SwitchCamera(deviceId,AVBasicRoomDeletateImp::OnSwitchCameraComplete,_delegateImp);
    
    if (ret != tencent::av::AV_OK){
        if (!_switchCameraCompletion){
            completion(deviceId, ret);
            return NO;
        }
        else{
            if (_switchCameraCompletion) {
                return NO;
            }
            else{
                _switchCameraCompletion=Block_copy(completion);
            }
        }
    }
    
    return YES;
}
-(BOOL)enableMic:(BOOL)bEnable
{
    if (!_avContext) {
        return NO;
    }
    tencent::av::AVAudioCtrl* audioCtrl=_avContext->GetAudioCtrl();
    if (audioCtrl) {
        return audioCtrl->EnableMic(bEnable)==tencent::av::AV_OK;
    }
    return NO;
    
}
-(BOOL)changeSpeakerMode:(NSInteger)mode
{
    if (!_avContext) {
        return NO;
    }
    tencent::av::AVAudioCtrl* audioCtrl=_avContext->GetAudioCtrl();
    if (audioCtrl) {
        return audioCtrl->SetAudioOutputMode(mode)==tencent::av::AV_OK;
    }
    return NO;
    
}
-(NSInteger)getVolumn
{
    if (!_avContext) {
        return NO;
    }
    tencent::av::AVAudioCtrl* audioCtrl=_avContext->GetAudioCtrl();
    if (audioCtrl) {
        return audioCtrl->GetVolume();
    }
    return -1;
    
}
-(BOOL)doRequestView:(NSArray*)identifier_list
{
    NSAssert(FALSE,@"doRequestView not implemented");
    return NO;
}
-(BOOL)doCancelView:(AVEndpointInfo*)aEndpoint type:(EndpointStateType)endpointStateType
{
    NSAssert(FALSE,@"doCancelView not implemented");
    return NO;
}
-(BOOL)requestView:(AVEndpointInfo*)aEndpoint type:(EndpointStateType)endpointStateType completion:(AVEndpointCompletion)completion
{
    if (!self.avContect) {
        return NO;
    }
    
    NSString* viewKey=[self setCompletion:completion forEndpoint:aEndpoint viewType:endpointStateType keyType:ViewKeyTypeRequest];
    if (!viewKey) {
        AVLog(@"requestView was not finished");
        return NO;
    }
    
    if (![self doRequestView:aEndpoint type:endpointStateType]) {
        AVLog(@"doRequestView failed");
        [self removeCompletion:viewKey];
        return NO;
    }
    
    return YES;
}
-(BOOL)cancelView:(AVEndpointInfo*)aEndpoint completion:(AVEndpointCompletion)completion
{
    if (!self.avContect) {
        return NO;
    }
    
    EndpointStateType endpointStateType=EndpointStateTypeCamera;
    NSString* viewKey=[self setCompletion:completion forEndpoint:aEndpoint viewType:endpointStateType keyType:ViewKeyTypeCancel];
    if (!viewKey) {
        return NO;
    }
    
    if (![self doCancelView:aEndpoint type:endpointStateType]) {
        [self removeCompletion:viewKey];
        AVLog(@"removeCompletion is nil");
        return NO;
    }
    
    return YES;
}
-(BOOL)requestViewList:(NSArray*)identifier_list
{
    
    if (![self doRequestView:identifier_list]) {
        AVLog(@"doRequestView failed");
        return NO;
    }

    return YES;
}
-(BOOL)CancelAllView
{
    if (![self doCancelAllView]) {
        AVLog(@"CancelAllView failed");
        return NO;
    }
    return YES;
}
-(BOOL)pauseAudio{
    //NO IMPLEMENT
    //TODO
    return NO;
}
-(BOOL)resumeAudio{
    //NO IMPLEMENT
    //TODO
    return NO;
}

-(void)_OnContextStartComplete:(int)result
{
    if (result!=tencent::av::AV_OK) {
        _avContext=NULL;
        AVLog(@"_OnContextStartComplete:%d",result);
        //AVShowMessage(@"初始化Context失败！");
    }
    
    if (_contextStartCompletion) {
        _contextStartCompletion((AVResult)result);
        Block_release(_contextStartCompletion);
        _contextStartCompletion=nil;
    }else{
        AVLog(@"_contextStartCompletion is nil");
    }
}
-(void)_OnContextCloseComplete
{
    [[TIMManager sharedInstance] logout];
    
    if (_contextCloseCompletion) {
        _contextCloseCompletion((AVResult)tencent::av::AV_OK);
        Block_release(_contextCloseCompletion);
        _contextCloseCompletion=nil;
    }else{
        AVLog(@"_contextCloseCompletion is nil");
    }
    delete _avContext;
    _avContext=NULL;
}

-(tencent::av::NetStateType)getCurNetType{
    int status = [[[AKNetworkReachability detailedNetworkStatus] objectForKey:@"type"] intValue];

        tencent::av::NetStateType type = tencent::av::NETTYPE_E_NONE;
        if (status != NotReachable) {
            
            switch (status) {
                case 1: type = tencent::av::NETTYPE_E_WIFI; break;
                case 2: type = tencent::av::NETTYPE_E_2G; break;
                case 3: type = tencent::av::NETTYPE_E_3G; break;
                case 4: type = tencent::av::NETTYPE_E_4G; break;
            }
        }
    
    return type;
}

-(void)_OnEnterRoomComplete:(int)result
{
    tencent::av::AVRoom *pRoom = NULL;
    if (_avContext){
      pRoom = _avContext->GetRoom();
    }
    
    if (pRoom){
        pRoom->SetNetType([self getCurNetType]);
    }
    
    self.roomState = AVRoomStateInRoom;
    [self initRenderDevice];
    
    if (_enterRoomCompletion) {
        _enterRoomCompletion((AVResult)result);
        Block_release(_enterRoomCompletion);
        _enterRoomCompletion=nil;
    }else{
        AVLog(@"_enterRoomCompletion is nil");
    }
    
}



-(void)_OnExitRoomComplete:(int)result
{
    self.roomState=AVRoomStateNull;
    
    if (_closeRoomCompletion) {
        _closeRoomCompletion((AVResult)tencent::av::AV_OK);
        Block_release(_closeRoomCompletion);
        _closeRoomCompletion=nil;
    }else{
        AVLog(@"_closeRoomCompletion is nil");
    }
    
    [_endpoints removeAllObjects];
}
-(void)_OnQueryRoomInfoComplete:(tencent::av::AVRoom::Info*)info result:(int)result
{
    AVRoomInfo* roomInfo=nil;
    if (result==tencent::av::AV_OK) {
        roomInfo=[[[AVRoomInfo alloc] initWithInfo:info] autorelease];
    }
    
    if (_queryRoomCompletion) {
        _queryRoomCompletion(roomInfo,(AVResult)result);
        Block_release(_queryRoomCompletion);
        _queryRoomCompletion=nil;
    }else{
        AVLog(@"_queryRoomCompletion is nil");
    }
}

-(void)_OnRequestViewComplete:(std::string)identifier result:(int)result
{
    AVEndpointInfo* aEndpoint=[_endpoints objectForKey:[NSString stringWithUTF8String:identifier.c_str()]];
    
    EndpointStateType endpointStateType=EndpointStateTypeCamera;
    AVEndpointCompletion completion=[self completionForEndpoint:aEndpoint viewType:endpointStateType keyType:ViewKeyTypeRequest];
    if (completion) {
        completion(aEndpoint,(AVResult)result);
        NSString* key=[self keyforEndpoint:aEndpoint viewType:endpointStateType keyType:ViewKeyTypeRequest];
        [self removeCompletion:key];
    }else{
        AVLog(@"_OnRequestViewComplete completion is nil");
    }
    }

-(void)_OnCancelViewComplete:(std::string)identifier result:(int)result
{
    AVEndpointInfo* aEndpoint=[_endpoints objectForKey:[NSString stringWithUTF8String:identifier.c_str()]];
    
    EndpointStateType endpointStateType=EndpointStateTypeCamera;
    AVEndpointCompletion completion=[self completionForEndpoint:aEndpoint viewType:endpointStateType keyType:ViewKeyTypeCancel];
    if (completion) {
        completion(aEndpoint,(AVResult)result);
        NSString* key=[self keyforEndpoint:aEndpoint viewType:endpointStateType keyType:ViewKeyTypeCancel];
        [self removeCompletion:key];
    }else{
        AVLog(@"_OnCancelViewComplete completion is nil");
    }
    
}

-(void)_OnVideoframeData:(tencent::av::VideoFrame*)frameData
{
    if (self.renderCheckTimer == nil)
        self.renderCheckTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(OnDisplayCheck:) userInfo:nil repeats:(true)];
    
    if (_beginData == nil){
        
        [self.delegate OnPeerAvShift:true];
        _beginData = [NSDate date];
    }
    
    self._lastVideotick = clock();
    AVFrameInfo* frameInfo=[[[AVFrameInfo alloc] initWithFrame:frameData] autorelease];
    [_frameDispatcher dispatchVideoFrame:frameInfo isSubFrame:NO];

}

-(void)_OnEnableCameraComplete:(bool)bEnable result:(int)result
{
    if (_enableCameraCompletion) {
        _enableCameraCompletion(bEnable,(AVResult)result);
        Block_release(_enableCameraCompletion);
        _enableCameraCompletion=nil;
    }else{
        AVLog(@"_enableCameraCompletion is nil");
    }

}
-(void)_OnSwitchCameraComplete:(int)cameraId result:(int)result
{
    if (_switchCameraCompletion) {
        _switchCameraCompletion(cameraId,(AVResult)result);
        Block_release(_switchCameraCompletion);
        _switchCameraCompletion=nil;
    }else{
        AVLog(@"_switchCameraCompletion is nil");
    }
    if (_delegate){
        [_delegate OnPreviewStart];
    }
}

-(void)initRenderDevice
{
    if (!_avContext) {
        return ;
    }
    tencent::av::AVDeviceMgr* device_mgr = _avContext->GetVideoDeviceMgr();
    
    tencent::av::AVRemoteVideoDevice* video_device = (tencent::av::AVRemoteVideoDevice*)device_mgr->GetDeviceById(DEVICE_REMOTE_VIDEO);
    if (video_device) {
        video_device->SetPreviewCallback(AVBasicRoomDeletateImp::VideoframeDataCallback,_delegateImp);
    }
    
}
-(void)uninitRenderDevice
{
    if (!_avContext) {
        return ;
    }
    tencent::av::AVDeviceMgr* device_mgr = _avContext->GetVideoDeviceMgr();
    
    if (!device_mgr) {
        return;
    }
    
    tencent::av::AVRemoteVideoDevice* video_device = (tencent::av::AVRemoteVideoDevice*)device_mgr->GetDeviceById(DEVICE_REMOTE_VIDEO);
    if (video_device) {
        video_device->SetPreviewCallback(NULL,NULL);
    }
}

-(NSString*)keyforEndpoint:(AVEndpointInfo*)endpoint viewType:(NSInteger)viewType keyType:(ViewKeyType)keyType;
{
    return [NSString stringWithFormat:@"%@-%d-%d",endpoint.identifier,viewType,keyType];
}
-(NSString*)setCompletion:(AVEndpointCompletion)completion forEndpoint:(AVEndpointInfo*)aEndpoint viewType:(NSInteger)viewType keyType:(NSInteger)keyType
{
    NSString* viewKey=[self keyforEndpoint:aEndpoint viewType:viewType keyType:(ViewKeyType)keyType];
    if([_completions objectForKey:viewKey]){
        return nil;
    }
    [_completions setObject:Block_copy(completion) forKey:viewKey];
    return viewKey;
}
-(AVEndpointCompletion)completionForEndpoint:(AVEndpointInfo*)aEndpoint viewType:(NSInteger)viewType keyType:(NSInteger)keyType
{
    NSString* viewKey=[self keyforEndpoint:aEndpoint viewType:viewType keyType:(ViewKeyType)keyType];

    return [_completions objectForKey:viewKey];
}
-(void)removeCompletion:(NSString*)key
{
    id completion=[_completions objectForKey:key];
    if (completion) {
        Block_release(completion);
        [_completions removeObjectForKey:key];
    }
}

- (void)cancelRemoteVideo{
    if (!_avContext)
        return;
    
}

- (void)OnDisplayCheck:(NSTimer *)theTimer {
    
}


-(NSString*)GetVideoTips{
    return @"";
}
@end

