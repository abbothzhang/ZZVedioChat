//
//  ZZVCVideoFrame.h
//  QAVSDKDemo_public
//
//  Created by albert on 16/2/28.
//  Copyright © 2016年 TOBINCHEN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZZVCCommon.h"
#import "ZZVCFrameDesc.h"

@interface ZZVCVideoFrame : NSObject

@property(retain,nonatomic) ZZVCFrameDesc*frameDesc; ///< 视频帧描述
@property(copy, nonatomic) NSString*identifier; ///< 视频帧所属的房间成员ID。
@property(assign, nonatomic)UInt32 dataSize;    ///< 视频帧的数据缓冲区大小，单位：字节。
@property(assign,nonatomic) UInt8* data;    ///< 视频帧的数据缓冲区，SDK内部会管理缓冲区的分配和释放。
@property(assign, nonatomic)UInt64 roomID;  ///< 视频帧所属的房间成员ID。


@end


