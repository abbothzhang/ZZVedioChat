//
//  ZZVCVideoCtrl.h
//  ZZVCSDKDemo_public
//
//  Created by albert on 16/2/28.
//  Copyright © 2016年 TOBINCHEN. All rights reserved.
//
#import "ZZVCCommon.h"
#import "ZZVCError.h"
#import <AVFoundation/AVFoundation.h>
#import "ZZVCVideoFrame.h"


/**
 @brief 摄像头操作回调
 @param result 错误码。当返回ZZVC_OK时，操作回调才会被执行；否则就不会执行，需要处理具体的错误码。
 */
typedef void(^cameraOptionComplete)(int result);


/// 摄像头方向
typedef NS_ENUM(NSInteger, zzvcCameraPos){
    zzvcCameraPosFront = 0, /// CameraPosFront 前置摄像头
    zzvcCameraPosBack = 1,  /// CameraPosBack 后置摄像头
};


/**
 @brief 远端视频委托协议
 */
@protocol ZZVCRemoteVideoDelegate <NSObject>
@required

/**
 @brief 远程画面回调
 @param 远端视频帧数据
 */

-(void)OnVideoPreview:(ZZVCVideoFrame*)frameData;
@end

/**
 @brief 屏幕分享委托协议
 */
@protocol ZZVCScreenVideoDelegate <NSObject>
@required

/**
 @brief 屏幕分享画面回调
 @param 屏幕分享视频帧数据
 */
-(void)OnVideoPreview:(ZZVCVideoFrame*)frameData;
@end

/**
 @brief 本地视频委托协议
 */
@protocol ZZVCLocalVideoDelegate <NSObject>
@required
/**
 @brief 本地画面预览回调
 @param 本地视频帧数据
 */
-(void)OnLocalVideoPreview:(ZZVCVideoFrame*)frameData;
@end


/**
 @brief 视频控制器的封装类
 */
@interface ZZVCVideoCtrl : NSObject{
    
}
@property(assign, nonatomic)BOOL isCameraOn;        ///< 打开/关闭摄像头
@property(assign, nonatomic)BOOL isEnableExternalCapture;  ///< 打开/关闭外部视频捕获设备



/**
 @brief 切换摄像头。
 
 @param pos 摄像头的前后方向。
 @param block 返回切换摄像头的结果是成功还是失败。
 
 @return 返回错误码。当返回ZZVC_OK时，操作回调才会被执行；否则就不会执行，需要处理具体的错误码。
 
 */
-(QAVResult)switchCamera:(zzvcCameraPos)pos complete:(cameraOptionComplete)block;

/**
 @brief 打开/关闭摄像头。
 
 @param bEnable 是否打开。
 @param block 返回打开/关闭摄像头的结果是成功还是失败。
 
 @return 返回错误码。当返回ZZVC_OK时，操作回调才会被执行；否则就不会执行，需要处理具体的错误码。
 
 */
-(QAVResult)enableCamera:(BOOL)bEnable complete:(cameraOptionComplete)block;

/**
 @brief 获取通话中实时视频质量相关信息，业务侧可以不用关心，主要用来查看通话情况、排查问题等。
 
 @return 以字符串形式返回视频相关的质量参数。
 */
-(NSString*)getQualityTips;

/**
 @brief 设置用远端视频设备输出远端视频的代理。
 
 @param  delegate 远端视频流委托对象，都统一传递继承ZZVCRemoteVideoDelegate的委托对象。
 */
-(void)setRemoteVideoDelegate:(id<ZZVCRemoteVideoDelegate>)delegate;

/**
 @brief 设置打开本地输入视频流的代理。
 
 @param delegate 本地输入视频流委托对象，都统一传递继承ZZVCLocalVideoDelegate的委托对象。
 */
-(void)setLocalVideoDelegate:(id<ZZVCLocalVideoDelegate>)delegate;

/**
 @brief 设置打开远端屏幕分享视频流的代理。
 @param delegate 输入屏幕分享视频流委托对象，都统一传递继承ZZVCScreenVideoDelegate的委托对象。
 */

-(void)setScreenVideoDelegate:(id<ZZVCScreenVideoDelegate>)delegate;

/**
 @brief 开启外部采集之前必须设置外部采集的能力，包括图像大小，帧率。
 
 @param info 设置摄像头采集信息。
 */
-(void)setExternalCamAbility:(ZZVCCameraInfo*)info;

/**
 @brief 向音视频SDK传入捕获的视频帧。
 
 @param frame 视频帧数据及相关参数。
 
 @remark 要控制好传入视频帧的频率，最好控制在每秒10帧左右，具体频率视实际使用场景而定。
 @remark 分辨率宽高比例限定只能为4：3，且最大宽度为640
 @remark 图像颜色格式。当前仅支持ZZVCCOLOR_FORMAT_I420。
 @remark 视频源类型。当前仅支持ZZVCVIDEO_SRC_TYPE_CAMERA。
 
 @return 返回值为ZZVC_OK时表示成功，否则表示失败。
 */
-(int)fillExternalCaptureFrame:(ZZVCVideoFrame*)frame;

/**
 @brief 获取摄像头视频的预览layer
 @return 返回值AVCaptureVideoPreviewLayer实例。失败时返回nil
 */
-(AVCaptureVideoPreviewLayer*)getPreviewLayer;

/**
 @brief 获取本地摄像头的CaptureSession
 
 @return 返回值AVCaptureSession实例。失败时返回nil
 */
-(AVCaptureSession*)getCaptureSession;
@end
