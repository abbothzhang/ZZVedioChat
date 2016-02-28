//
//  ZZVCRoom.h
//  ZZVCSDKDemo_public
//
//  Created by albert on 16/2/28.
//  Copyright © 2016年 TOBINCHEN. All rights reserved.
//

#import "ZZVCCommon.h"

/**
 @brief 房间委托协议
 */
@protocol ZZVCRoomDelegate <NSObject>
@required
/**
 @brief ZZVCContext的enterRoom的回调函数。
 
 @details 此函数用来异步返回ZZVCContext的enterRoom的执行结果。
 
 @param result 错误码：
 \n ZZVC_OK 执行成功；
 \n ZZVC_ERR_INTERFACE_SERVER_NOT_EXISTS 没有分配到接口机。
 \n ZZVC_ERR_FAILED 解包失败或者超时。
 \n 其他值 其他原因导致的执行失败。
 */
-(void)OnEnterRoomComplete:(int)result;

/**
 @brief ZZVCContext的exitRoom的回调函数。
 
 @details 此函数用来异步返回ZZVCContext的exitRoom的执行结果。
 
 @param result 错误码：
 \n ZZVC_OK 执行成功；
 \n 其他值 其他原因导致执行失败。
 */
-(void)OnExitRoomComplete:(int)result;

/**
 @brief 房间成员状态更新通知。
 
 @details 当房间成员状态发生变化(如是否发语音、是否发视频等)的时候，服务器会向所有成员推送这部分状态变化成员的列表。
 
 @param eventID 成员事件id，表示这次状态更新所发生的事件。
 @param endpoints 状态变化的成员列表，列表元素的生命周期由SDK控制，不需要App负责销毁。
 
 @remark 状态更新通知前后，房间成员的总人数没有变化。
 */
-(void)OnEndpointsUpdateInfo:(ZZVCUpdateEvent)eventID endpointlist:(NSArray*)endpoints;

/**
 @brief AVRoomMulti::ChangeAuthority()的回调函数。
 
 @details 此函数用来异步返回AVRoomMulti::ChangeAuthority()的执行结果。
 
 @param ret_code 错误码：
 \n ZZVC_OK 执行成功；
 \n ZZVC_ERR_FAILED 执行失败。
 */
-(void)OnChangeAuthority:(int)ret;
@end

/**
 @brief 房间封装类
 
 */
@interface ZZVCRoom : NSObject{
    
}

@property(assign,nonatomic)UInt64 roomId;     ///< 音视频房间ID
@property(assign,nonatomic)avRoomType roomType;  ///< 音视频房间类型（双人或多人）

/**
 @brief 获取通话中实时房间质量相关信息，业务侧可以不用关心，主要用来查看通话情况、排查问题等。
 
 @return 以字符串形式返回音视频房间的质量参数。
 */
-(NSString*)getQualityTips;

@end
