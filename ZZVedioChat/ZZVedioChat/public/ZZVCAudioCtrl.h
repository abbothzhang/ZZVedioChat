//
//  ZZVCAudioCtrl.h
//  ZZVCSDKDemo_public
//
//  Created by albert on 16/2/28.
//  Copyright © 2016年 TOBINCHEN. All rights reserved.
//

//#import "ZZVCCommon.h"

/**
 @brief 音频帧回调委托协议
 */
@protocol ZZVCAudioPreviewDelegate <NSObject>

/**
 @brief 音频帧预览回调
 @param 音频帧数据
 */
-(void)OnAudioPreview:(ZZVCAudioFrame*)frameData;
@end

/**
 @brief 音频数据委托协议
 */
@protocol ZZVCAudioDataDelegate <NSObject>
@required
/**
 @brief 音频数据透传回调。
 @details 通过回调函数，来通知外部读取或者写入具体类型的音频数据。
 @param audioFrame 音频数据，输出类型从此参数读取数据，输入数据类型将数据写入此参数。
 @param type 音频数据类型。
 @remark 回调函数设定为专门处理数据用。函数回调在非主线程，请确保线程安全。特别是不要在回调函数中直接调用SDK接口。
 成功返回ZZVC_OK, 否则返回ZZVC_ERR_FAILED。
 */
-(ZZVCResult)audioDataComes:(ZZVCAudioFrame*)audioFrame type:(ZZVCAudioDataSourceType)type;
/**
 @brief 传给sdk的音频数据回调。
 @details 通过回调函数，来通知外部读取或者写入具体类型的音频数据。
 @param audioFrame 音频数据，输出类型从此参数读取数据，输入数据类型将数据写入此参数。
 @param type 音频数据类型。
 @remark 回调函数设定为专门处理数据用。函数回调在非主线程，请确保线程安全。特别是不要在回调函数中直接调用SDK接口。
 成功返回QAudioDataCallbackResult_Success, 否则返回QAudioDataCallbackResult_Error。
 */
-(ZZVCResult)audioDataShouInput:(ZZVCAudioFrame*)audioFrame type:(ZZVCAudioDataSourceType)type;
@end

/**
 @brief 音频控制器的封装类
 */
/// 音频控制器的封装类
@interface ZZVCAudioCtrl : NSObject{
    
}

@property(readonly, nonatomic) UInt32 volume;///< 麦克风数字音量,数字音量取值范围[0,100]

@property(readonly, nonatomic) UInt32 dynamicVolume;///< 麦克风动态音量,动态音量取值范围[0,100]

@property(assign, nonatomic) ZZVCOutputMode outputMode;///< 外放模式

//-(void)pauseAudio;
//
//-(void)resumeAudio;

/**
 @brief 获取通话中实时音频质量相关信息，业务侧可以不用关心，主要用来查看通话情况、排查问题等。
 
 @return 以字符串形式返回音频相关的质量参数。
 */
-(NSString*)getQualityTips;

/**
 @brief 打开/关闭扬声器。
 
 @param bEnable 是否打开。
 
 @return YES表示操作成功，NO表示操作失败。
 */
-(BOOL)enableSpeaker:(BOOL)bEnable;

/**
 @brief 打开/关闭麦克风。
 
 @param isEnable 是否打开。
 
 @return YES表示操作成功，NO表示操作失败。
 */
-(BOOL)enableMic:(BOOL)isEnable;

/**
 @brief 打开/关闭自监听。打开之后可以用mic听自己的声音
 
 @param isEnable 是否打开。
 
 @return YES表示操作成功，NO表示操作失败。
 */
-(BOOL)enableLoopBack:(BOOL)isEnable;


/**
 @brief 设置音频回调的delegate
 
 @param dlg 继承了QAudioDataDelegate的对象实例
 
 @return 具体参考ZZVCResult
 */
-(ZZVCResult)setAudioDataEventDelegate:(id<ZZVCAudioDataDelegate>)dlg;


/**
 @brief 注册音频数据类型的回调
 
 @param type 要注册监听的音频数据源类型，具体参考ZZVCAudioDataSourceType
 
 @return 具体参考ZZVCResult
 */
-(ZZVCResult)registerAudioDataCallback:(ZZVCAudioDataSourceType)type;


/**
 @brief 反注册音频数据类型的回调
 
 @param type 要反注册监听的音频数据源类型，具体参考ZZVCAudioDataSourceType
 
 @return 具体参考ZZVCResult
 */
-(ZZVCResult)unregisterAudioDataCallback:(ZZVCAudioDataSourceType)type;

/**
 @brief 反注册所有数据的回调
 
 @return 具体参考ZZVCResult
 */
-(ZZVCResult)unregisterAudioDataCallbackAll;

/**
 @brief 设置某类型的音频格式参数。
 @param srcType 音频数据类型。
 @param audioDesc 音频数据的格式。
 @return 成功返回ZZVC_OK, 否则返回ZZVC_ERR_FAILED。
 @remark 会直接影响callback传入的AudioFrame的格式。
 */
-(ZZVCResult)setAudioDataFormat:(ZZVCAudioDataSourceType)srcType  desc:(struct ZZVCAudioFrameDesc)audioDesc;

/**
 @brief 获取某类型的音频格式参数。
 @param srcType 音频数据类型。
 @return 返回struct ZZVCAudioFrameDesc。
 @remark 无。
 */
-(struct ZZVCAudioFrameDesc)getAudioDataFormat:(ZZVCAudioDataSourceType) srcType;

/**
 @brief 设置某类型的音频音量。
 @param srcType 音频数据类型。
 @param volume 音量 (范围 0-1)。
 @return 成功返回ZZVC_OK, 否则返回ZZVC_ERR_FAILED。
 @remark 没有注册对应类型的callback会直接返回AV_ERR_FAILED。
 */
-(ZZVCResult)setAudioDataVolume:(ZZVCAudioDataSourceType)srcType volume:(float)volume;

/**
 @brief 获取某类型的音频音量。
 @param srcType 音频数据类型。
 @return 返回音量 (范围 0-1)
 @remark 没有注册对应类型的callback会直接返回ZZVC_ERR_FAILED。
 */
-(float)getAudioDataVolume:(ZZVCAudioDataSourceType)srcType;

@end
