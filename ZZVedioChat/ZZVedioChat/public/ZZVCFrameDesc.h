//
//  ZZVCFrameDesc.h
//  QAVSDKDemo_public
//
//  Created by albert on 16/2/28.
//  Copyright © 2016年 TOBINCHEN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZZVCCommon.h"

@interface ZZVCFrameDesc : NSObject

//详情见avColorFormats的定义。

@property(assign,nonatomic) UInt32 width; ///< 宽度，单位：像素。
@property(assign,nonatomic) UInt32  height; ///< 高度，单位：像素。

/**
 @brief 画面旋转的角度：
 - source_type为AVVIDEO_SRC_TYPE_CAMERA时，表示视频源为摄像头。
 在终端上，摄像头画面是支持旋转的，App需要根据旋转角度调整渲染层的处理，以保证画面的正常显示。
 - source_type为其他值时，rotate恒为0。
 */
@property(assign,nonatomic)int rotate;

@property(assign, nonatomic) zzvcColorFormats color_format; ///< 色彩格式，
@property(assign,nonatomic)zzvcVideoSrcType srcType; ///< 视频源类型，详情见


@end
