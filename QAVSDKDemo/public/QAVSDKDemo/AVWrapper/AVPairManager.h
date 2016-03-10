//
//  AVPairManager.h
//  QAVSDKDemo_P
//
//  Created by TOBINCHEN on 14-10-27.
//  Copyright (c) 2014年 TOBINCHEN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "AVManager.h"

typedef NS_ENUM(NSUInteger, Mode)
//enum Mode
{
    MODE_AUDIO = 0, ///< 纯语音通话，双方都不能进行视频上下行。
    MODE_VIDEO = 1, ///< 音视频通话，对视频上下行没有约束。
};

@protocol AVPairManagerDelegate <NSObject>
@required
-(void)OnRoomPeerEnter;
-(void)OnRoomPeerLeave;
-(void)OnRoomUpdate;
-(void)OnPeerAvShift:(BOOL)bStart;
-(void)OnPreviewStart:(BOOL)showPreview;
@end


@interface AVPairManager :AVBasicManager{
    
}
@property(assign, nonatomic) Mode currentMode;
@property (assign,nonatomic) id<AVPairManagerDelegate> delegate;
/**
 *  双人通话的管理类
 *
 *  @return AVPairManager
 */
+(AVPairManager*)shareManager;

-(AVRoomInfo*)roomInfo;
-(BOOL)createRoom:(NSString*)rid withMode:(Mode)mode completion:(AVCompletion)completion;
-(BOOL)joinRoom:(unsigned long long)roomId rid:(NSString*)rid completion:(AVCompletion)completion;
@end
