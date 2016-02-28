//
//  ZZVCMultiParam.h
//  QAVSDKDemo_public
//
//  Created by albert on 16/2/28.
//  Copyright © 2016年 TOBINCHEN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZZVCCommon.h"






@interface ZZVCMultiParam : NSObject

@property(assign, nonatomic)zzvcRoomType roomtype;    ///< 音视频房间类型

@property(assign, nonatomic)zzvcAudioCategory audioCategory; ///< 音视频场景策略，多人房间专用。
@property(assign, nonatomic)UInt32 roomID;    ///< App指定的房间ID。

//advance property
@property(assign, nonatomic)UInt64 authBitMap;///< 音视频权限位。
@property(copy, nonatomic)NSData*authBuffer;  ///< 音视频权限加密串。
@property(copy, nonatomic)NSString*controlRole; ///< 角色名，web端音视频参数配置工具所设置的角色名。

@end
