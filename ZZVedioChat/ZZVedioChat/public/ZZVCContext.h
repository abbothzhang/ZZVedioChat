//
//  ZZVCContext.h
//  ZZVCSDKDemo_public
//
//  Created by albert on 16/2/28.
//  Copyright © 2016年 TOBINCHEN. All rights reserved.
//

#import "ZZVideoChat.h"
#import "ZZVCRoom.h"
#import "ZZVCAudioCtrl.h"
#import "ZZVCVideoCtrl.h"

/**
 @brief AVContext对象配置信息
 */
@interface ZZVCContextConfig : NSObject{
}

@property (copy,nonatomic) NSString* sdkAppId;  ///< 腾讯为每个使用SDK的App分配多AppId。
@property (copy,nonatomic) NSString* appIdAtThird;  ///< App使用的OAuth授权体系分配的AppId。
@property (copy,nonatomic) NSString* identifier;    ///< 帐号名
@property (copy,nonatomic) NSString* accountType;   ///< 腾讯为每个接入方分配的帐号类型。
@end

/**
 *  通用的回调
 *
 *  @param result 错误码。非0表示出错
 */
typedef void (^zzvcContextOperationBlock)(ZZVCResult result);

/**
 @brief AVContext对象封装类，代表着一个SDK运行实例
 */
@interface ZZVCContext : NSObject{
    
}
@property(retain, nonatomic) ZZVCContextConfig*Config;///< 创建AVContext对象所需的配置信息


// 只有进入房间后以下属性才有用
@property (readonly,nonatomic)ZZVCRoom*room;  ///< 音视频房间
@property (readonly,nonatomic)ZZVCAudioCtrl *audioCtrl;  ///< 音频控制器
@property (readonly,nonatomic)ZZVCVideoCtrl *videoCtrl;  ///< 视频控制器

/**
 @brief 创建ZZVCContext对象。
 
 @details App使用SDK总是从CreateContext开始的，该静态成员函数返回一个新的ZZVCContext实例。
 
 @param config 创建ZZVCContext所需的配置信息。
 
 @return 成功则返回ZZVCContext的实例指针；否则返回nil。
 
 @remark
 - 创建成功之后，App需要进一步调用StartContext来启动ZZVCContext对象。
 - App必须保证ZZVCContext实例的唯一性，同时创建多个ZZVCContext实例可能会因为设备占用等方面的原因，出现无法预料的结果。
 */
+(ZZVCContext*)CreateContext:(ZZVCContextConfig*)config;
/**
 @brief 销毁目前的ZZVCContext的单例对象。
 
 @details 需要在CreateContext之后才能调用
 
 @param context 需要销毁的ZZVCContext对象。
 
 */
+(void)DestroyContext:(ZZVCContext*)context;

/**
 @brief 启动ZZVCContext对象。
 
 @details StartContext是一个异步操作，内部会启动工作线程，创建各种内部对象。
 
 @param  block	返回启动Context的结果是成功还是失败
 
 @return 返回值表示异步操作启动是否成功；异步操作执行结果通过回调函数返回。
 
 @retval ZZVC_OK 启动成功。
 @retval 其他值 启动失败。
 
 @remark
 - 只有当异步操作启动成功的时候，才会通过回调函数异步返回执行结果；
 - 当异步操作启动失败的时候，直接通过StartContext的返回值返回错误，不会再触发回调函数；
 - App收到block回调的时候，表示StartContext执行完毕；
 - startContext执行成功之后，App才能进一步调用ZZVCContext的其他成员函数；
 - startContext执行成功之后，App必须调用stopContext来终止ZZVCContext对象。
 
 @attention 以下两点约定也适用于SDK的其他异步操作接口：
 -# 只有当异步操作启动成功的时候，才会通过回调函数异步返回执行结果；
 -# 当异步操作启动失败的时候，直接通过StartContext的返回值返回错误，不会再触发回调函数。
 */
-(ZZVCResult)startContext:(ContextOperationBlock)block;

/**
 @brief 终止ZZVCContext对象。
 
 @details stopContext是一个异步操作，内部会终止工作线程，销毁各种内部对象。
 
 @param block 返回终止Context的结果是成功还是失败
 
 @return 返回值表示异步操作启动是否成功；异步操作执行结果通过回调函数返回。
 
 @retval ZZVC_OK 启动成功。
 @retval 其他值 启动失败。
 
 @remark
 - App应该设法保证startContext和stopContext的配对调用；
 - stopContext内部如果判断到当前还没退出音视频房间，会自动调用ExitRoom；
 */
-(ZZVCResult)stopContext:(ContextOperationBlock)block;

/**
 @brief 进入音视频房间。
 
 @details EnterRoom()是一个异步操作，内部会连接服务器，申请进入音视频房间。
 
 @param  param 进入房间所需的参数：
 \n 进入双人房间，必须传递ZZVCPairParam类型的参数；
 \n 进入多人房间，必须传递ZZVCMultiParam类型的参数。
 @param  dlg 房间委托对象：
 \n 进入双人房间和多人房间，都统一传递继承avRoomDelegate的委托对象。
 
 @return 返回值表示异步操作启动是否成功；
 
 异步操作执行结果通过继承ZZVCRoomDelegate的委托对象的OnEnterRoomComplete()返回。
 
 @retval ZZVC_OK 启动成功。
 @retval ZZVC_ERR_CONTEXT_NOT_STARTED StartContext()没有执行成功。
 @retval ZZVC_ERR_ALREADY_EXISTS 没有退出上一个音视频房间。
 @retval ZZVC_ERR_INVALID_ARGUMENT 委托或房间配置信息为空，或者委托和房间类型不匹配。
 
 @remark EnterRoom必须在StartContext执行成功之后调用才有效。
 目前同一时刻只支持进入一个音视频房间，所以：
 - 调用EnterRoom之前，必须先退出上一个音视频房间；
 - 如果当前AVContext中已经存在一个音视频房间，调用EnterRoom会同步返回失败。
 */
-(ZZVCResult)enterRoom:(ZZVCRoomParam*)param delegate:(id<ZZVCRoomDelegate>)dlg;

/**
 @brief 退出音视频房间。
 
 @details ExitRoom是一个异步操作，内部会连接服务器，申请退出音视频房间。
 
 @return 返回值表示异步操作启动是否成功；
 异步操作执行结果通过继承ZZVCRoomDelegate的委托对象的OnExitRoomComplete()返回。
 
 @retval ZZVC_OK 启动成功。
 @retval 其他值 启动失败。
 */
-(ZZVCResult)exitRoom;

@end
