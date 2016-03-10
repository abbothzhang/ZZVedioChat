//
//  AVManager.h
//  AVTest
//
//  Created by TOBINCHEN on 14-10-9.
//  Copyright (c) 2014年 TOBINCHEN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "AVFrameDispatcher.h"
#import "AVEndpointInfo.h"
#import "AVRoomInfo.h"
#import "AVGLBaseView.h"

typedef NS_ENUM(NSUInteger, AVRoomType) {
    AVRoomType_Null,
    AVRoomType_Mult,
    AVRoomType_Pair
};

typedef NS_ENUM(NSUInteger,AVWRelationType) {
    AVW_RELATION_TYPE_UNKNOWN = 0,
    AVW_RELATION_TYPE_GROUP = 1, //群
    AVW_RELATION_TYPE_DISCUSS = 2, //讨论组
    AVW_RELATION_TYPE_FRIEND   = 3,//好友
    AVW_RELATION_TYPE_TEMP    = 4, //临时会话
    AVW_RELATION_TYPE_OPENSDK = 6
};

/**
 *  房间状态枚举
 */
typedef NS_ENUM(NSUInteger, AVRoomState){
    /**
     *  为定义状态
     */
    AVRoomStateNull = 0,
    /**
     *  正在创建房间
     */
    AVRoomStateCreatingRoom,
    /**
     *  正在加入房间
     */
    AVRoomStateJoiningRoom,
    /**
     *  房间创建，但没有进入房间
     */
    AVRoomStateOutRoom,
    /**
     *  已经进入房间
     */
    AVRoomStateInRoom,
    /**
     *  正在关闭房间
     */
    AVRoomStateClosingRoom,
};

#define AV_RESULT(label, value) AV_Result_ ## label = value

/**
 *  底层函数的返回值枚举，完全对应AV_Error
 */
typedef NS_ENUM(NSInteger, AVResult){
    AV_Result_OK                  = 0,
    
    /**
     *  A generic failure occurred.
     */
    AV_RESULT(FAILED, -1),
    
    /**
     * 签名超时
     */

    AV_RESULT(KEY_EXPIRED, -8),
    
    /**
     * 找不到房间
     */

    AV_RESULT(ROOM_NOT_FOUND, -10),
    
    /**
     * 找不到用户
     */

    AV_RESULT(ENDPOINT_NOT_FOUND, -11),
    
    /**
     * 签名无效
     */

    AV_RESULT(KEY_INVALID, -12),
    
    /**
     * 成员列表不需要更新
     */

    AV_RESULT(ENDPOINT_LIST_UPTODATE, -15),
    /**
     *     An asynchronous operation is not yet complete.  This usually does not
     * indicate a fatal error.  Typically this error will be generated as a
     * notification to wait for some external notification that the operation
     * finally completed.
     */


    AV_RESULT(PENDING, -100),
    
    /**
     * An operation is already in progress.
     */

    AV_RESULT(BUSY, -101),
    
    /**
     * An object is already exists.
     */

    AV_RESULT(ALREADY_EXISTS, -103),
    
    /**
     * An argument to the function is incorrect.
     */

    AV_RESULT(INVALID_ARGUMENT, -104),
    
    /**
     * The handle or file descriptor is invalid.
     */

    AV_RESULT(INVALID_HANDLE, -105),
    
    /**
     * An object cannot be found.
     */

    AV_RESULT(NOT_FOUND, -106),
    
    /**
     * An operation timed out.
     */

    AV_RESULT(TIMED_OUT, -107),
    
    /**
     * The operation failed because of context not started.
     */

    AV_RESULT(CONTEXT_NOT_STARTED, -110),
    
    /**
     * The operation failed because of unimplemented functionality.
     */

    AV_RESULT(NOT_IMPLEMENTED, -111),
    
    /**
     * There were not enough resources to complete the operation.
     */

    AV_RESULT(INSUFFICIENT_RESOURCES, -112),
    
    /**
     * Memory allocation failed.
     */

    AV_RESULT(OUT_OF_MEMORY, -113),
    
    /**
     * Operation not supported.
     */

    AV_RESULT(NOT_SUPPORTED, -114),
    
    /**
     * 群语音、群视频被禁用，或者用户被禁言.
     */

    AV_RESULT(ENTER_BAN, -115),
    
    /**
     * 群视频抢座失败，因为群视频座位已满.
     */

    AV_RESULT(ENTER_VIDEO_FULL, -116),
    
    /**
     * Get interface server address failed
     */

    AV_RESULT(INTERFACE_SERVER_NOT_EXIST, -117),
    
    /**
     * A previous operation is already in progress
     */
    AV_RESULT(OPERATION_IN_PROGRESS, -118),
    
    /**
     * Not a valid room
     */
    AV_RESULT(INVALID_ROOM, -119),
    
    /**
     * Init opensdk fail
     */
    AV_RESULT(INITSDKFAIL, -120),
    
    /**
     * Server kicked out as another client connected.
     */
    AV_RESULT(SERVER_KICK_OUT, -150),
    
    /**
     * An error occured in device start.
     */
    AV_RESULT(DEVICE_START_FAILED, -200),
    
    
};


/**
 *  上下文配置信息,字段的具体含义请参考文档
 */
@interface ContextConfig : NSObject{
    
}

@property (assign,nonatomic) int sdk_app_id;            //腾讯为每个使用SDK的App分配多AppId。
@property (copy,nonatomic)   NSString *account_type;    //腾讯为每个接入方分配的账号类型。
@property (copy,nonatomic)   NSString *app_id_at3rd;    //App使用的OAuth授权体系分配的AppId。
@property (copy,nonatomic)   NSString *identifier;      //账号名（用户名）


@end

/**
 *  通用的回调
 *
 *  @param result 错误码。非0表示出错
 */
typedef void (^AVCompletion)(AVResult result);
/**
 *  对房间进行操作的回调
 *
 *  @param info   房间信息
 *  @param result 错误码，非0表示出错
 */
typedef void (^AVRoomInfoCompletion)(AVRoomInfo* info,AVResult result);
/**
 *  对房间成员操作的回调
 *
 *  @param endpoint   操作对象
 *  @param result 错误码，非0表示出错
 */
typedef void (^AVEndpointCompletion)(AVEndpointInfo* endpoint,AVResult result);

typedef void (^AVEnableCameraCompleteCompletion)(BOOL bEnable,AVResult result);
typedef void (^AVSwitchCameraCompleteCompletion)(NSInteger cameraId,AVResult result);
/**
 *  通话管理的基类，不能直接初始化
 */
@interface AVBasicManager : NSObject{
    NSMutableDictionary* _endpoints;
    id _delegate;
    AVRoomState _roomState;
    AVFrameDispatcher* _frameDispatcher;
    AVRoomType _roomType;
    AVGLBaseView *_imageView; /*新的openglview  支持多路画面绘制*/

}
/**
 *  委托
 */
@property (assign,nonatomic) id delegate;
/**
 *  视频数据分发
 */
@property (retain,nonatomic) AVFrameDispatcher* frameDispatcher;
/**
 *  当前会话的配置信息
 */
@property (retain,readonly,nonatomic) ContextConfig* config;
/**
 *  房间状态
 */
@property (assign,nonatomic,readonly) AVRoomState roomState;
/**
 *  房间类型
 */
@property (assign,nonatomic) AVRoomType roomType;

@property(retain, nonatomic) NSTimer  * renderCheckTimer;

@property(assign, nonatomic) clock_t  _lastVideotick;
@property(assign, nonatomic) NSDate  *beginData;

/**
 *  启动上下文
 *
 *  @param config    配置信息
 *  @param completion 启动完成的回调
 *
 *  @return 请求发送是否成功
 */
-(BOOL)startContext:(ContextConfig*) config completion:(AVCompletion)completion;

/**
 *  关闭上下文
 *
 *  @param completion 关闭完成的对调
 *
 *  @return 请求发送是否成功
 */
-(BOOL)closeContext:(AVCompletion)completion;
/**
 *  判断是否已经创建上下文
 *
 *  @return 是否已经创建
 */
-(BOOL)hasContext;

/**
 *  关闭房间
 *
 *  @return
 */
-(BOOL)closeRoom:(AVCompletion)completion;
/**
 *  设置房间超时时间
 *
 *  @param interval 时间
 */
-(void)setTimeoutIntervel:(NSUInteger)interval;
/**
 *  当前房间信息
 *
 *  @return 房间信息对象
 */
-(AVRoomInfo*)roomInfo;

/**
 *  查询房间信息，可以是没有进入的房间
 *
 *  @param relationId   房间ID
 *  @param relationType 房间类型
 *  @param completion 回调
 *
 *  @return 
 */
-(BOOL)queryRoomInfo:(unsigned long long)roomId relationType:(unsigned short)relationType completion:(AVRoomInfoCompletion)completion;

/**
 *  预览layer
 *
 *  @return AVCaptureVideoPreviewLayer
 */
-(AVCaptureVideoPreviewLayer*)previewLayer;
/**
 *  获取摄像头采集session
 *
 *  @return 返回AVCaptureSession*
 */
-(AVCaptureSession*)getCaptureSession;
/**
 *  获取摄像头数量
 *
 *  @return 返回数量
 */
-(NSUInteger)CameraCount;
/**
 *  开关摄像头
 *
 *  @param bEnable 开关
 *  @param completion 完成回调
 *
 *  @return
 */
-(BOOL)enableCamera:(BOOL)bEnable completion:(AVEnableCameraCompleteCompletion)completion;
/**
 *  开关耳机/扬声器
 *
 *  @param bEnable 开关
 *
 *  @return
 */
-(BOOL)enableSpeaker:(BOOL)bEnable;
/**
 *  选择摄像头
 *
 *  @param bFront 是否前置摄像头
 *  @param completion 完成回调
 *
 *  @return
 */
-(BOOL)selectCamera:(BOOL)bFront completion:(AVSwitchCameraCompleteCompletion)completion;
/**
 *  开关麦克风
 *
 *  @param bEnable 开关
 *
 *  @return
 */
-(BOOL)enableMic:(BOOL)bEnable;
/**
 *  开关外放
 *
 *  @param mode 是否外放
 *
 *  @return
 */
-(BOOL)changeSpeakerMode:(NSInteger)mode;
/**
 *  获取音量
 *
 *  @return
 */
-(NSInteger)getVolumn;

/**
 *  请求画面
 *
 *  @param aEndpoint    请求的对象
 *  @param endpointStateType 请求的画面类型
 *  @param completion 回调
 *
 *  @return
 */
-(BOOL)requestView:(AVEndpointInfo*)aEndpoint  type:(EndpointStateType)endpointStateType completion:(AVEndpointCompletion)completion;
/**
 *  取消画面
 *
 *  @param aEndpoint 取消的对象
 *  @param completion 回调
 *
 *  @return
 */
-(BOOL)cancelView:(AVEndpointInfo*)aEndpoint completion:(AVEndpointCompletion)completion;

-(BOOL)pauseAudio;
-(BOOL)resumeAudio;

-(void)cancelRemoteVideo;

-(void)OnDisplayCheck:(NSTimer *)theTimer;

/**
 *  请求多路画面
 *
 *  @param NSArray    请求画面的id_list
 *  @param endpointStateType 请求的画面类型
 *  @param completion 回调
 *
 *  @return
 */
-(BOOL)requestViewList:(NSArray*)identifier_list;

/**
 *  取消观看所有画面
 *
 *
 *  @return
 */
-(BOOL)CancelAllView;

-(NSString*)GetVideoTips;

-(BOOL)enableLoopBack:(BOOL)isEnable;

@end