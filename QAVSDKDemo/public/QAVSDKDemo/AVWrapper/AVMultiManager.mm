//
//  AVMultiManager.m
//  QAVSDKDemo_P
//
//  Created by TOBINCHEN on 14-10-27.
//  Copyright (c) 2014 TOBINCHEN. All rights reserved.
//

#import "AVMultiManager.h"
#import "AVMultiRoomDelegateImp.h"
#import "AVManager_Protected.h"
#import "UserConfig.h"

#include <time.h>

@interface AVMultiManager()
@property (nonatomic,assign,readonly)AVMultiRoomDelegateImp* delegateImp;
@end

@implementation AVMultiManager
+(AVMultiManager*)shareManager{
    static AVMultiManager* manager=nil;
    if (manager==nil) {
        manager= [[AVMultiManager alloc] init];
    }
    return manager;
}


-(id)init{
    self=[super init];
    if (self) {
        _roomType=AVRoomType_Mult;
        _delegateImp=new AVMultiRoomDelegateImp;
        self.delegateImp->setContextDelegate(self);
    }
    return self;
}
-(void)dealloc
{
    self.delegateImp->setContextDelegate(nil);
    delete _delegateImp;
    
    [super dealloc];
}

-(BOOL)createRoom:(unsigned int)roomId relationType:(AVWRelationType)type completion:(AVCompletion)completion
{

    tencent::av::AVRoomMulti::EnterRoomParam MultiRoomParam;
    MultiRoomParam.app_room_id = roomId;
    
    switch ([UserConfig shareConfig].categoryNum) {
        case 0:
            MultiRoomParam.audio_category = tencent::av::AVRoom::AUDIO_CATEGORY_VOICECHAT;
            break;
        case 1:
            MultiRoomParam.audio_category = tencent::av::AVRoom::AUDIO_CATEGORY_MEDIA_PLAYBACK;
            break;
        case 2:
            MultiRoomParam.audio_category = tencent::av::AVRoom::AUDIO_CATEGORY_MEDIA_PLAY_AND_RECORD;
            break;
        default:
            break;
    }
    
    if([UserConfig shareConfig].authAudioSend &&
       [UserConfig shareConfig].authAudioRev &&
       [UserConfig shareConfig].authVideoSend &&
       [UserConfig shareConfig].authVideoRev)
    {
        MultiRoomParam.auth_bits = AUTH_BITS_DEFUALT;
    }
    else
    {
        MultiRoomParam.auth_bits = AUTH_BITS_CREATE_ROOM | AUTH_BITS_JOIN_ROOM | AUTH_BITS_RECV_SUB;

        if( [UserConfig shareConfig].authVideoSend )
            MultiRoomParam.auth_bits |= AUTH_BITS_SEND_VIDEO;
        if( [UserConfig shareConfig].authVideoRev )
            MultiRoomParam.auth_bits |= AUTH_BITS_RECV_VIDEO;
        if( [UserConfig shareConfig].authAudioSend )
            MultiRoomParam.auth_bits |= AUTH_BITS_SEND_AUDIO;
        if( [UserConfig shareConfig].authAudioRev )
            MultiRoomParam.auth_bits |= AUTH_BITS_RECV_AUDIO;
    }
    if ([UserConfig shareConfig].roomRole && [[UserConfig shareConfig].roomRole length] > 0)
        MultiRoomParam.av_control_role = [UserConfig shareConfig].roomRole.UTF8String;
    
    return [super _createRoom:&MultiRoomParam completion:completion];
}

-(BOOL)joinRoom:(unsigned long long)roomId completion:(AVCompletion)completion
{
    return FALSE;
//    tencent::av::AVRoom::Info room_config;
//    room_config.relation_id = roomId;
//    room_config.room_id=roomId;
//    room_config.room_type=tencent::av::AVRoom::ROOM_TYPE_MULTI;
//    
//    return [super _joinRoom:&room_config completion:completion];
}

-(void)_OnVideoframeData:(tencent::av::VideoFrame*)frameData
{
    self._lastVideotick = clock();
    AVFrameInfo* frameInfo=[[[AVFrameInfo alloc] initWithFrame:frameData] autorelease];
    [_frameDispatcher dispatchVideoFrame:frameInfo isSubFrame:NO];
    
    if (videoOutputFile != NULL) {
        fwrite(frameData->data, 1, frameData->data_size, videoOutputFile);
    }
}

-(AVMultiRoomDelegateImp*)delegateImp{
    return (AVMultiRoomDelegateImp*)_delegateImp;
}
-(NSArray*)endpoints
{
    return [_endpoints allValues];
}
-(BOOL)ban:(AVEndpointInfo*)aEndpoint ban:(bool) bBan completion:(AVEndpointCompletion)completion
{
    if (!self.avContect) {
        return NO;
    }
    
    NSString* viewKey=[self setCompletion:completion forEndpoint:aEndpoint viewType:EndpointStateTypeNull keyType:ViewKeyTypeBan];
    if (!viewKey) {
        return NO;
    }
    
    tencent::av::AVRoomMulti* room=dynamic_cast<tencent::av::AVRoomMulti*>(self.avContect->GetRoom());
    if (room) {
        tencent::av::AVEndpoint* endpoint=room->GetEndpointById(aEndpoint.identifier.UTF8String);
        if (endpoint) {
            //NO IMPLEMENT
            return NO;
        }
    }
    return YES;
}
-(void)setEndpointsUpdateInterval:(NSUInteger)interval timeout:(NSUInteger)timeout
{
    
}
-(void)setSpeakingCheckInterval:(NSUInteger)interval
{
    
}
-(NSArray*)activeEndpoint
{
    return nil;
}
-(NSArray*)speakingEndpoint
{
    return nil;
}
#pragma mark  
-(void)_OnBanComplete:(tencent::av::AVEndpoint*)endpoint result:(int)result
{
    AVEndpointInfo* aEndpoint=[_endpoints objectForKey:[NSString stringWithUTF8String:endpoint->GetId().c_str()]];
    
    AVEndpointCompletion completion=[self completionForEndpoint:aEndpoint viewType:EndpointStateTypeNull keyType:ViewKeyTypeBan];
    if (completion) {
        completion(aEndpoint,(AVResult)result);
        NSString* key=[self keyforEndpoint:aEndpoint viewType:EndpointStateTypeNull keyType:ViewKeyTypeBan];
        [self removeCompletion:key];
    }


}
-(void)_OnSubVideoframeData:(tencent::av::VideoFrame*)frameData
{
     AVFrameInfo* frameInfo=[[[AVFrameInfo alloc] initWithFrame:frameData] autorelease];
    
    [_frameDispatcher dispatchVideoFrame:frameInfo isSubFrame:YES];
}

#define MAX_VIEW_COUNT 4
std::vector<std::string> g_identifierList;
std::vector<tencent::av::View> g_viewList;


-(BOOL)doRequestView:(AVEndpointInfo*)aEndpoint type:(EndpointStateType)endpointStateType
{
    if (!self.avContect) {
        return NO;
    }

    tencent::av::View view;
    view.size_type = tencent::av::VIEW_SIZE_TYPE_BIG;
    if (endpointStateType==EndpointStateTypeCamera) {
        view.video_src_type = tencent::av::VIDEO_SRC_TYPE_CAMERA;
    }
    
    
    tencent::av::AVRoomMulti* multiRoom=dynamic_cast<tencent::av::AVRoomMulti*>(self.avContect->GetRoom());
    if (multiRoom) {
        tencent::av::AVEndpoint* endpoint=multiRoom->GetEndpointById(aEndpoint.identifier.UTF8String);
        if (endpoint) {
            std::vector<std::string> identifierList;
            identifierList.push_back(endpoint->GetId());
            std::vector<tencent::av::View> viewList;
            viewList.push_back(view);

            int ret_code = tencent::av::AVEndpoint::RequestViewList(identifierList, viewList, AVBasicRoomDeletateImp::RequestViewListCompleteCallback, _delegateImp);
            return ret_code == tencent::av::AV_OK;
        }else{
            AVLog(@"doRequestView endpoint not found");
        }
    }
    
    return NO;

}

-(BOOL)doCancelView:(AVEndpointInfo*)aEndpoint type:(EndpointStateType)endpointStateType{
    if (!self.avContect) {
        return NO;
    }
    
    tencent::av::AVRoomMulti* multiRoom=dynamic_cast<tencent::av::AVRoomMulti*>(self.avContect->GetRoom());
    if (multiRoom) {
        tencent::av::AVEndpoint* endpoint=multiRoom->GetEndpointById(aEndpoint.identifier.UTF8String);
        if (endpoint) {
            return tencent::av::AVEndpoint::CancelAllView(AVBasicRoomDeletateImp::CancelAllViewCompleteCallback,_delegateImp)==tencent::av::AV_OK;
        }else{
            AVLog(@"doCancelView endpoint not found");
        }
    }
    
    return NO;
}

-(BOOL)doRequestView:(NSArray*)identifier_list
{
    if (!self.avContect) {
        return NO;
    }

    
    for(NSString *strid in identifier_list)
    {
        tencent::av::View view;
        view.video_src_type = tencent::av::VIDEO_SRC_TYPE_CAMERA;
        view.size_type = tencent::av::VIEW_SIZE_TYPE_BIG;
        g_identifierList.push_back([strid UTF8String]);
        g_viewList.push_back(view);
    }
    
    return tencent::av::AV_OK == tencent::av::AVEndpoint::RequestViewList(g_identifierList, g_viewList, AVBasicRoomDeletateImp::RequestViewListCompleteCallback, _delegateImp);
}

-(BOOL)doCancelAllView
{
    if (!self.avContect) {
        return NO;
    }
    
    return tencent::av::AV_OK == tencent::av::AVEndpoint::CancelAllView(AVBasicRoomDeletateImp::CancelAllViewCompleteCallback, _delegateImp);}

-(void)initRenderDevice
{
    [super initRenderDevice];
    
    if (!self.avContect) {
        return ;
    }
    tencent::av::AVDeviceMgr*  device_mgr = self.avContect->GetVideoDeviceMgr(tencent::av::VIDEO_CHANNEL_MAIN);
    tencent::av::AVRemoteVideoDevice* video_device = NULL;
    if (device_mgr){
        video_device = (tencent::av::AVRemoteVideoDevice*)device_mgr->GetDeviceById(DEVICE_REMOTE_VIDEO);
    }
    if (video_device) {
        video_device->SetPreviewCallback(AVBasicRoomDeletateImp::VideoframeDataCallback,_delegateImp);
    }
    
//    tencent::av::AVDevice **ppcamera_list = NULL;
//    int camera_count = device_mgr->GetDeviceByType(DEVICE_CAMERA, &ppcamera_list);
//    
//    for(int n = 0; n < camera_count; n++){
//        tencent::av::AVCameraDevice* video_local = (tencent::av::AVCameraDevice*)ppcamera_list[n];
//        if (video_local) {
//            video_local->SetPreviewCallback(AVBasicRoomDeletateImp::VideoframeDataCallback,_delegateImp);
//        }
//    }
}

-(void)uninitRenderDevice
{
    [super uninitRenderDevice];
    
    if (!self.avContect) {
        return ;
    }
    tencent::av::AVDeviceMgr*  device_mgr = self.avContect->GetVideoDeviceMgr(tencent::av::VIDEO_CHANNEL_MAIN);
    
    if (!device_mgr) {
        return;
    }
    tencent::av::AVRemoteVideoDevice* video_device = (tencent::av::AVRemoteVideoDevice*)device_mgr->GetDeviceById(DEVICE_REMOTE_VIDEO);
    if (video_device) {
        video_device->SetPreviewCallback(NULL,NULL);
    }
}

-(void)_OnExitRoomComplete:(int)result
{
    [super _OnExitRoomComplete:result];
    
    [self uninitRenderDevice];
    [self enableInputAudio:false];
    [self enableOutputAudio:false];
    
    [_delegate OnExitRoomComplete:result];
}

-(void)_OnEndpointsUpdateInfo:(int)eventid list:(std::vector<std::string>)updatelist{
    
    if (eventid == tencent::av::AVRoom::EVENT_ID_ENDPOINT_ENTER) {/*1.3测试进度风险，先和老版本保持一致，不展示非语音视频成员信息
        NSMutableArray* userlist=[[[NSMutableArray alloc] init] autorelease];
        for (int i = 0; i < updatelist.size(); i++) {
            NSString* endpointId=[NSString stringWithUTF8String:updatelist[i].c_str()];
            tencent::av::AVEndpoint* endpoint = NULL;
            tencent::av::AVRoomMulti* room=dynamic_cast<tencent::av::AVRoomMulti*>(self.avContect->GetRoom());
            if (room) {
                endpoint=room->GetEndpointById(updatelist[i]);
            }
            AVEndpointInfo* newUser=[[AVEndpointInfo alloc] initWithEndpoint:endpoint];
            [_endpoints setObject:newUser forKey:endpointId];
            [userlist addObject:newUser];
        }
        [_delegate OnEndpointsEnterRoom:userlist];*/
        
    }
    else if (eventid == tencent::av::AVRoom::EVENT_ID_ENDPOINT_EXIT) {/*1.3测试进度风险，先和老版本保持一致，不展示非语音视频成员信息

        NSMutableArray* userlist=[[[NSMutableArray alloc] init] autorelease];
        for (int i = 0; i < updatelist.size(); i++) {
            NSString* endpointId=[NSString stringWithUTF8String:updatelist[i].c_str()];
            AVEndpointInfo* targetUser=[_endpoints objectForKey:endpointId];
            if (targetUser == nil)
                continue;
            
            [userlist addObject:targetUser];
            if ([targetUser.identifier isEqual:self.config.identifier]) {//自己离开房间
                self.roomState=AVRoomStateOutRoom;
            }
            
            [_endpoints removeObjectForKey:endpointId];
        }
        [_delegate OnEndpointsExitRoom:userlist];*/
        
    }
    else {
        for (int i=0; i<updatelist.size(); i++) {
            NSMutableArray* userlist=[[[NSMutableArray alloc] init] autorelease];
            NSString* endpointId=[NSString stringWithUTF8String:updatelist[i].c_str()];
            AVEndpointInfo* targetUser=[_endpoints objectForKey:endpointId];
            
            tencent::av::AVEndpoint* endpoint = NULL;
            tencent::av::AVRoomMulti* room=dynamic_cast<tencent::av::AVRoomMulti*>(self.avContect->GetRoom());
            if (room) {
                endpoint=room->GetEndpointById(updatelist[i]);
            }
            if (endpoint == NULL) {
                [_endpoints removeObjectForKey:endpointId];
                [userlist addObject:targetUser];
                [_delegate OnEndpointsExitRoom:userlist];
                continue;
            }
            
            if(targetUser == nil)
            {
                NSString* endpointId=[NSString stringWithUTF8String:updatelist[i].c_str()];
                
                AVEndpointInfo* newUser=[[AVEndpointInfo alloc] initWithEndpoint:endpoint];
                [_endpoints setObject:newUser forKey:endpointId];
                targetUser=[_endpoints objectForKey:endpointId];
                [userlist addObject:targetUser];
                
                if(endpoint->HasAudio() || endpoint->HasVideo())
                {
                    [_delegate OnEndpointsEnterRoom:userlist];
                }
                else{
                    [_delegate OnEndpointsExitRoom:userlist];
                }
            }
            else
            {
                if(endpoint->HasAudio() || endpoint->HasVideo())
                {
                    EndpointStateType oldSrcTypes=targetUser.stateTypes;
                    [targetUser updateWithEndpoint:endpoint];
                    
                    EndpointStateType newSrcTypes=targetUser.stateTypes;
                    // if ( (oldSrcTypes&EndpointStateTypeCamera) != (newSrcTypes&EndpointStateTypeCamera)  )
                    {
                        [_delegate OnEndpointsUpdateInfo:targetUser stateType:EndpointStateTypeCamera change: newSrcTypes&EndpointStateTypeCamera?YES:NO];
                    }
                    
                    //if ( (oldSrcTypes&EndpointStateTypeAudio) != (newSrcTypes&EndpointStateTypeAudio)  )
                    {
                        [_delegate OnEndpointsUpdateInfo:targetUser stateType:EndpointStateTypeAudio change: newSrcTypes&EndpointStateTypeAudio?YES:NO];
                    }
                }
                else
                {
                    [userlist addObject:targetUser];
                    [_endpoints removeObjectForKey:endpointId];
                    [_delegate OnEndpointsExitRoom:userlist];//TODO 先暂时这么改，后续再改完善。
                }
            }
            
        }

        
    }
}

-(void)_OnChangeAuthority:(int)ret_code;
{
    [_delegate OnChangeAuthority:ret_code];
}

-(NSString*)GetVideoTips{
    if (self.avContect){
        tencent::av::AVVideoCtrl*pVideoCtrl = self.avContect->GetVideoCtrl();
        tencent::av::AVAudioCtrl*pAudioCtrl = self.avContect->GetAudioCtrl();
        if (pVideoCtrl && pAudioCtrl){
            NSString*strTips = [NSString stringWithFormat:
                                @"%s%s%s",
                                pAudioCtrl->GetQualityTips().c_str(),
                                pVideoCtrl->GetQualityTips().c_str(),
                                self.avContect->GetRoom()->GetQualityTips().c_str()
                                ];
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
    tencent::av::AVRoomMulti::Info *info = (tencent::av::AVRoomMulti::Info*)pRoom->GetRoomInfo();
    
    AVRoomInfo* roomInfo=[[AVRoomInfo alloc] initWithInfo:info];
    return roomInfo;
}

#pragma mark - 读视频流文件 -


-(void)enableExternalCapture
{
    tencent::av::AVVideoCtrl* videoCtrl = self.avContect->GetVideoCtrl();
    videoCtrl->EnableExternalCapture(true, AVMultiRoomDelegateImp::EnableExternalCaptureCompleteCallback, _delegateImp);

}

-(void)_OnEnableExternalCaptureComplete:(bool)is_enable result:(int)result;
{
    
}

-(BOOL)captureVideo:(int)width height:(int)height data:(UInt8*)data size:(UInt32)size{
    if (!data || size == 0)
        return NO;
    
    if (_roomState != AVRoomStateInRoom)
        return NO;
    
    tencent::av::AVVideoCtrl *pVideoCtrl = NULL;
    
    if (self.avContect)
        pVideoCtrl = self.avContect->GetVideoCtrl();
    
    if (!pVideoCtrl)
        return NO;
    
    tencent::av::VideoFrameDesc FrameDesc ;
    FrameDesc.color_format = tencent::av::COLOR_FORMAT_I420;
    FrameDesc.width = width;
    FrameDesc.height = height;
    FrameDesc.rotate = 0;
    //FrameDesc.src_type = tencent::av::VIDEO_SRC_TYPE_CAMERA;
    
    tencent::av::VideoFrame videoFrame;
    videoFrame.identifier = [self.config.identifier UTF8String];
    videoFrame.desc = FrameDesc;
    videoFrame.data_size = size;
    videoFrame.data = data;
    
    pVideoCtrl->FillExternalCaptureFrame(videoFrame);
    
    //AVBasicRoomDeletateImp::VideoframeDataCallback(&videoFrame, _delegateImp);
    return YES;
}

-(void)runVideoFromLocalWithIdentifier:(NSString*)identifier AndVideoName:(NSString*)video AndFrame:(NSString*)frame
{
    //    [self enableExternalCapture];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    NSLog(@"地址为:%@",docDir);
    
    NSString *filePath = [docDir stringByAppendingPathComponent:video];
    
    NSData *data = [[NSData alloc]initWithContentsOfFile:filePath];

    int width = [[[frame componentsSeparatedByString:@"*"] objectAtIndex:0]intValue];
    int height = [[[frame componentsSeparatedByString:@"*"] objectAtIndex:1]intValue];
    int pieceSize = width*height*3/2;
    
    NSUInteger dataLength = [data length];
    if (dataLength == 0) {
        NSLog(@"视频文件为空，请选择其他文件!");
    }
    
    long int i = 0;

    while( i < dataLength)
    {
        tencent::av::AVVideoCtrl *pVideoCtrl = NULL;
        if (self.avContect)
            self.avContect->GetVideoCtrl();
        
        if (!pVideoCtrl)
            return;
        
        NSRange range;
        if (dataLength - i < pieceSize) {
        
            range = NSMakeRange(i, dataLength - i);
        }
        else{
            range = NSMakeRange(i, pieceSize);
        }

        uint8 tempByte[pieceSize];
        [data getBytes:tempByte range:range];
        
        tencent::av::VideoFrameDesc FrameDesc ;
        FrameDesc.color_format = tencent::av::COLOR_FORMAT_I420;
        FrameDesc.width = width;
        FrameDesc.height = height;
        FrameDesc.rotate = 1;
        FrameDesc.src_type = tencent::av::VIDEO_SRC_TYPE_NONE;
        
        tencent::av::VideoFrame videoFrame;
        videoFrame.identifier = [identifier UTF8String];
        videoFrame.desc = FrameDesc;
        videoFrame.data_size = pieceSize;
        videoFrame.data = tempByte;

        int result = pVideoCtrl->FillExternalCaptureFrame(videoFrame);
        NSLog(@"VideoCtrl = %d",result);
        i = i + pieceSize;
        
        usleep(66666);
    }
    [data release];
    data = nil;
}

FILE* pInputFIle = NULL;

-(bool)enableInputAudio:(bool)enable
{
    tencent::av::AVAudioCtrl* audioCtrl= self.avContect->GetAudioCtrl();
    if (NULL == audioCtrl) return false;
    
    if(enable)
    {
        if(pInputFIle) return true;

        NSString* pString = [UserConfig shareConfig].audioInputName;
        if(pString == nil) return false;
        
        std::string inputName = pString.UTF8String;
        
        if(inputName.size() > 0)
        {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            inputName = std::string([documentsDirectory UTF8String]) + "/" + inputName;

            if(audioCtrl->EnableExternalCapture(true))
            {
                pInputFIle = fopen(inputName.c_str(), "rb");
                if(pInputFIle)
                {
                    _timer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(OnTimerInputAudioData) userInfo:self repeats:YES];
                    [_timer fire];
                    return true;
                }
                else
                {
                    audioCtrl->EnableExternalCapture(false);
                }
            }
        }
        return false;
    }
    else
    {
        if(!pInputFIle) return true;
        
        [_timer invalidate];
        _timer = nil;
        
        audioCtrl->EnableExternalCapture(false);
        fclose(pInputFIle);
        pInputFIle = NULL;
        return true;
    }
}


-(void)OnTimerInputAudioData
{
    //to do: 读文件 塞数据
    tencent::av::AVAudioCtrl* audioCtrl= self.avContect->GetAudioCtrl();
    if (NULL == audioCtrl) return;
    
    std::string audioSr = [UserConfig shareConfig].audioSr.UTF8String;
    std::string audioChn = [UserConfig shareConfig].audioChn.UTF8String;
    uint32 sr = atoi(audioSr.c_str());
    uint32 chn = atoi(audioChn.c_str());
    uint32 size = sr * chn * 2 / 50;
    
    std::vector<uint8> data; data.resize(size);
    size_t ret = fread((void*)&data[0], 1, size, pInputFIle);
    if(ret == size)
    {
        tencent::av::AudioFrame frame;
        frame.data = &data[0];
        frame.data_size = size;
        frame.desc.sample_rate = sr;
        frame.desc.channel_num = chn;
        bool bRet = audioCtrl->FillExternalCaptureFrame(frame);
        if(!bRet)
        {
            fseek(pInputFIle, -1 * (int)size, SEEK_CUR);
        }
    }
    else
    {
        fseek(pInputFIle, 0, SEEK_SET);
        [self OnTimerInputAudioData];
    }
}

bool bOutputFile = false;

FILE* pOutputFIle = NULL;
int lastSr = 0;
int lastCh = 0;

- (void)_LocalPreviewCallback:(tencent::av::AudioFrame*)frame
{
    if(!frame) return;

    if( lastSr != frame->desc.sample_rate || 
        lastCh != frame->desc.channel_num )
    {
        lastSr = frame->desc.sample_rate;
        lastCh = frame->desc.channel_num;
        if(pOutputFIle)
        {
            fclose(pOutputFIle);
            pOutputFIle = NULL;
        }
    }

    if(!pOutputFIle)
    {
        NSString* pString = [UserConfig shareConfig].audioOutputName;
        if(pString == nil) return;
        
        std::string outputName = pString.UTF8String;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        outputName = std::string([documentsDirectory UTF8String]) + "/" + outputName;

        char path[256] = {0};
        sprintf(path, "%s.%d_%d_%d", outputName.c_str(), lastSr, lastCh, time(NULL));
        pOutputFIle = fopen(path, "wb+");
    }
    fwrite(frame->data, 1, frame->data_size, pOutputFIle);
}

-(BOOL)enableLoopBack:(BOOL)isEnable{
    tencent::av::AVAudioCtrl* audioCtrl= self.avContect->GetAudioCtrl();
    if (NULL == audioCtrl) return NO;
    
    audioCtrl->EnableLoopback(isEnable ? true : false);
    return YES;
}

-(bool)enableOutputAudio:(bool)enable
{
    tencent::av::AVAudioCtrl* audioCtrl= self.avContect->GetAudioCtrl();
    if (NULL == audioCtrl) return false;
    
    if(enable)
    {
        if(bOutputFile) return true;
        
        NSString* pString = [UserConfig shareConfig].audioOutputName;
        if(pString == nil) return false;
        
        std::string outputName = pString.UTF8String;

        if(outputName.size() > 0)
        {
            if(audioCtrl->SetLocalPreviewCallback(AVMultiRoomDelegateImp::LocalPreviewCallback, _delegateImp)) 
            {
                bOutputFile = true;
                return true;
            }
        }
        return false;
    }
    else
    {
        if(!bOutputFile) return true;
        
        bOutputFile = false;
        lastSr = 0;
        lastCh = 0;

        audioCtrl->SetLocalPreviewCallback(NULL, NULL);
        
        if(pOutputFIle)
        {
            fclose(pOutputFIle);
            pOutputFIle = NULL;
        }
        return true;
    }
}

FILE* videoOutputFile = NULL;

#pragma 写入文件
- (BOOL)enableVideoInput:(BOOL)enable
{
    if (!self.avContect) {
        return FALSE;
    }
    tencent::av::AVVideoCtrl* videoCtrl = self.avContect->GetVideoCtrl();
    if (videoCtrl == NULL) {
        return false;
    }
    if (enable) {
        if (videoOutputFile) {
            return true;
        }
        NSString *fileName = @"new.yuv";
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docDir = [paths objectAtIndex:0];
        NSLog(@"写入地址为:%@",docDir);
        
        NSString *filePath = [docDir stringByAppendingPathComponent:fileName];
        
        videoOutputFile = fopen(filePath.UTF8String,  "wb+");
        
    }
    else
    {
        if(!videoOutputFile) return true;
        
        fclose(videoOutputFile);
        
        videoOutputFile = NULL;
    }
    
    return true;
}

- (BOOL)changeAuthority:(NSData*)authPirvateMap
{
    if(authPirvateMap == nil) return false;
    std::string auth_buffer;
    auth_buffer.assign((char*)authPirvateMap.bytes, authPirvateMap.length);
    
    tencent::av::AVRoomMulti* room=dynamic_cast<tencent::av::AVRoomMulti*>(self.avContect->GetRoom());
    if(!room) return false;
    
    return room->ChangeAuthority(auth_buffer);
}

@end


