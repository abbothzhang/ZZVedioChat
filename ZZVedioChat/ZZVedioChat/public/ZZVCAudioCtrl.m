//
//  ZZVCAudioCtrl.m
//  QAVSDKDemo_public
//
//  Created by albert on 16/2/28.
//  Copyright © 2016年 TOBINCHEN. All rights reserved.
//

#import "ZZVCAudioCtrl.h"
#import <QAVSDK/QAVSDK.h>

@interface ZZVCAudioCtrl()

@property (nonatomic,strong) QAVAudioCtrl       *audioCtrl;

@end


@implementation ZZVCAudioCtrl

- (instancetype)init{
    self = [super init];
    if (self) {
        _audioCtrl = [[QAVAudioCtrl alloc] init];
    }
    
    return self;
}

- (QAVAudioCtrl *)audioCtrl{
    if (_audioCtrl == nil) {
        _audioCtrl = [[QAVAudioCtrl alloc] init];
    }
    
    return _audioCtrl;
}

//-(void)pauseAudio;
//
//-(void)resumeAudio;

/**
 @brief 获取通话中实时音频质量相关信息，业务侧可以不用关心，主要用来查看通话情况、排查问题等。
 
 @return 以字符串形式返回音频相关的质量参数。
 */
-(NSString*)getQualityTips{
    return self.audioCtrl.getQualityTips;
}

/**
 @brief 打开/关闭扬声器。
 
 @param bEnable 是否打开。
 
 @return YES表示操作成功，NO表示操作失败。
 */
-(BOOL)enableSpeaker:(BOOL)bEnable{
    return [self.audioCtrl enableSpeaker:bEnable];
}

/**
 @brief 打开/关闭麦克风。
 
 @param isEnable 是否打开。
 
 @return YES表示操作成功，NO表示操作失败。
 */
-(BOOL)enableMic:(BOOL)isEnable{
    return [self.audioCtrl enableMic:isEnable];
}

/**
 @brief 打开/关闭自监听。打开之后可以用mic听自己的声音
 
 @param isEnable 是否打开。
 
 @return YES表示操作成功，NO表示操作失败。
 */
-(BOOL)enableLoopBack:(BOOL)isEnable{
    return [self.audioCtrl enableLoopBack:isEnable];
}


/**
 @brief 设置音频回调的delegate
 
 @param dlg 继承了QAudioDataDelegate的对象实例
 
 @return 具体参考QAVResult
 */
-(QAVResult)setAudioDataEventDelegate:(id<ZZVCAudioDataDelegate>)dlg{
    return (QAVResult)[self.audioCtrl setAudioDataEventDelegate:dlg];
}


/**
 @brief 注册音频数据类型的回调
 
 @param type 要注册监听的音频数据源类型，具体参考ZZVCAudioDataSourceType
 
 @return 具体参考QAVResult
 */
-(QAVResult)registerAudioDataCallback:(ZZVCAudioDataSourceType)type{
    QAVAudioDataSourceType type2 = (QAVAudioDataSourceType)type;
    return (QAVResult)[self.audioCtrl registerAudioDataCallback:type2];
}


/**
 @brief 反注册音频数据类型的回调
 
 @param type 要反注册监听的音频数据源类型，具体参考ZZVCAudioDataSourceType
 
 @return 具体参考QAVResult
 */
-(QAVResult)unregisterAudioDataCallback:(ZZVCAudioDataSourceType)type{
    return (QAVResult)[self.audioCtrl unregisterAudioDataCallback:(QAVAudioDataSourceType)type];
}

/**
 @brief 反注册所有数据的回调
 
 @return 具体参考QAVResult
 */
-(QAVResult)unregisterAudioDataCallbackAll{
    return (QAVResult)[self.audioCtrl unregisterAudioDataCallbackAll];
}

/**
 @brief 设置某类型的音频格式参数。
 @param srcType 音频数据类型。
 @param audioDesc 音频数据的格式。
 @return 成功返回ZZVC_OK, 否则返回ZZVC_ERR_FAILED。
 @remark 会直接影响callback传入的AudioFrame的格式。
 */


-(QAVResult)setAudioDataFormat:(ZZVCAudioDataSourceType)srcType  desc:(struct ZZVCAudioFrameDesc)audioDesc{
//    QAVAudioFrameDesc qavAudioDesc ;
    struct QAVAudioFrameDesc ad;
    ad.Bits = audioDesc.Bits;
    ad.ChannelNum = audioDesc.ChannelNum;
    ad.SampleRate = audioDesc.SampleRate;
    return (QAVResult)[self.audioCtrl setAudioDataFormat:(QAVAudioDataSourceType)srcType desc:ad];
}

/**
 @brief 获取某类型的音频格式参数。
 @param srcType 音频数据类型。
 @return 返回struct ZZVCAudioFrameDesc。
 @remark 无。
 */

-(struct ZZVCAudioFrameDesc)getAudioDataFormat:(ZZVCAudioDataSourceType) srcType{
    struct QAVAudioFrameDesc qavAF = [self.audioCtrl getAudioDataFormat:(QAVAudioDataSourceType)srcType];
    struct ZZVCAudioFrameDesc zzvcAF;
    zzvcAF.Bits = qavAF.Bits;
    zzvcAF.ChannelNum = qavAF.ChannelNum;
    zzvcAF.SampleRate = qavAF.SampleRate;
    return zzvcAF;
}

/**
 @brief 设置某类型的音频音量。
 @param srcType 音频数据类型。
 @param volume 音量 (范围 0-1)。
 @return 成功返回ZZVC_OK, 否则返回ZZVC_ERR_FAILED。
 @remark 没有注册对应类型的callback会直接返回AV_ERR_FAILED。
 */
-(QAVResult)setAudioDataVolume:(ZZVCAudioDataSourceType)srcType volume:(float)volume{
    return (QAVResult)[self.audioCtrl setAudioDataVolume:(QAVAudioDataSourceType)srcType volume:volume];
}

/**
 @brief 获取某类型的音频音量。
 @param srcType 音频数据类型。
 @return 返回音量 (范围 0-1)
 @remark 没有注册对应类型的callback会直接返回ZZVC_ERR_FAILED。
 */
-(float)getAudioDataVolume:(ZZVCAudioDataSourceType)srcType{
    return [self.audioCtrl getAudioDataVolume:(QAVAudioDataSourceType)srcType];
}

@end
