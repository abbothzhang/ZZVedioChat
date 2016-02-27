//
//  AVMultiManager.h
//  QAVSDKDemo_P
//
//  Created by TOBINCHEN on 14-10-27.
//  Copyright (c) 2014年 TOBINCHEN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AVManager.h"

/**
 *  AVMultiManagerDelegate
 */
@protocol AVMultiManagerDelegate <NSObject>
@required
/**
 *  成员进入房间
 *
 *  @param endpoints 进入房间的人，AVEndpointInfo
 */
-(void)OnEndpointsEnterRoom:(NSArray*)endpoints;

/**
 *  成员离开
 *
 *  @param endpoints 离开房间的成员数组，AVEndpointInfo
 */
-(void)OnEndpointsExitRoom:(NSArray*)endpoints;
/**
 *  成员状态更新
 *
 *  @param endpoint 状态有更新的成员
 *  @param stateType   变化的状态
 *  @param change   是否还有这个状态
 */
-(void)OnEndpointsUpdateInfo:(AVEndpointInfo*)endpoint stateType:(EndpointStateType)stateType change:(BOOL)change;
/**
 *  自己离开房间通知
 *
 *  @param result   tencent::av::AVError 非0表示出错
 */
-(void)OnExitRoomComplete:(int)result;

-(void)OnRoomConnectTimeout;

-(void)OnChangeAuthority:(int)ret_code;

-(void)OnPreviewStart:(BOOL)showPreview;

@end


@interface AVMultiManager : AVBasicManager{
    NSTimer* _timer;
}
/**
 *  多人通话的管理类
 *
 *  @return AVMultiManager
 */
+(AVMultiManager*)shareManager;


@property (nonatomic,copy,readonly) NSArray* endpoints;
@property (assign,nonatomic) id<AVMultiManagerDelegate> delegate;
/**
 *  创建房间
 *
 *  @param roomId 房间标识
 *  @param type rid的类型,参考AVWRelationType
 *  @param completion 回调
 *
 *  @return
 */
-(BOOL)createRoom:(unsigned int)roomId relationType:(AVWRelationType)type completion:(AVCompletion)completion;
-(BOOL)joinRoom:(unsigned long long)roomId completion:(AVCompletion)completion;
/**
 *  禁言
 *
 *  @param aEndpoint 禁言的对象
 *  @param bBan      是否禁言
 *  @param completion 回调
 *
 *  @return
 */
-(BOOL)ban:(AVEndpointInfo*)aEndpoint ban:(bool)bBan completion:(AVEndpointCompletion)completion;

-(void)setEndpointsUpdateInterval:(NSUInteger)interval timeout:(NSUInteger)timeout;
-(void)setSpeakingCheckInterval:(NSUInteger)interval;
-(NSArray*)activeEndpoint;
-(NSArray*)speakingEndpoint;

-(AVRoomInfo*)roomInfo;
-(void)runVideoFromLocalWithIdentifier:(NSString*)identifier AndVideoName:(NSString*)video AndFrame:(NSString*)frame;
-(void)enableExternalCapture;
- (BOOL)enableVideoInput:(BOOL)enable;

-(bool)enableInputAudio:(bool)enable;
-(bool)enableOutputAudio:(bool)enable;
-(BOOL)captureVideo:(int)width height:(int)height data:(UInt8*)data size:(UInt32)size;

@end

