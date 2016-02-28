//
//  ZZVCError.h
//  ZZVCSDKDemo_public
//
//  Created by albert on 16/2/28.
//  Copyright © 2016年 TOBINCHEN. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ZZVC_RESULT(label, value) ZZVC_Result_ ## label = value

/// 错误码
typedef NS_ENUM(NSInteger, ZZVCResult){
    
    ZZVC_OK = 0,     /// ZZVC_OK 成功操作。
    
    /*********客户端错误**********/
    ZZVC_ERR_FAILED = 1,/// ZZVC_ERR_FAILED 一般错误。
    
    ///基础共用相关(1001 to 1100)
    ZZVC_ERR_REPEATED_OPERATION = 1001,/// 重复操作。已经在进行某种操作，再次去做同样的操作，则返回这个错误。
    ZZVC_ERR_EXCLUSIVE_OPERATION = 1002,/// 互斥操作。已经在进行某种操作，再次去做同类型的其他操作，则返回这个错误。
    ZZVC_ERR_HAS_IN_THE_STATE = 1003,/// 已经处于所要状态，无需再操作。如设备已经打开，再次去打开，就返回这个错误码。
    ZZVC_ERR_INVALID_ARGUMENT = 1004,/// 错误参数。
    ZZVC_ERR_TIMEOUT = 1005,/// 操作超时。
    ZZVC_ERR_NOT_IMPLEMENTED = 1006,/// 功能未实现。
    ZZVC_ERR_NOT_IN_MAIN_THREAD = 1007,/// 不在主线程中执行操作。
    
    
    ///CONTEXT相关(1101 to 1200)
    ZZVC_ERR_CONTEXT_NOT_EXIST = 1101,/// AVContext不存在。
    ZZVC_ERR_CONTEXT_NOT_STOPPED = 1102,/// AVContext未结束。
    
    ///房间相关(1201 to 1300)
    ZZVC_ERR_ROOM_NOT_EXIST = 1201,/// 房间不存在。
    ZZVC_ERR_ROOM_NOT_EXITED = 1202,/// 房间未退出。
    
    ///设备相关(1301 to 1400)
    ZZVC_ERR_DEVICE_NOT_EXIST = 1301,/// 设备不存在。
    
    ///成员相关(1401 to 1500)
    ZZVC_ERR_ENDPOINT_NOT_EXIST = 1401,/// 房间成员不存在。
    ZZVC_ERR_ENDPOINT_HAS_NOT_VIDEO = 1402,/// 该成员没有上视频。
    
    ///APPLogic相关(1501 to 1600)
    ZZVC_ERR_TINYID_TO_OPENID_FAILED = 1501,/// tiny id转换至identifier失败。
    ZZVC_ERR_OPENID_TO_TINYID_FAILED = 1502,/// identifier转换至tiny id失败。
    
    ///邀请模块(1801 to 1900)。注意：邀请模块只是用于DEMO演示方便用，对外暂不支持邀请功能，所以业务侧不需要处理这些错误码。
    ZZVC_ERR_INVITE_FAILED = 1801,/// 发送邀请失败。
    ZZVC_ERR_ACCEPT_FAILED = 1802,/// 接受邀请失败。
    ZZVC_ERR_REFUSE_FAILED = 1803, /// 拒绝邀请失败。
    
    
    ///其他错误
    
    /******************************************后台错误******************************************
     名称：ZZVC_ERR_SERVER_FAILED
     取值：10001
     含义：一般错误
     原因：具体原因需要通过分析日志确认后台返回给客户端的真正错误码才能知道。
     方案：分析日志，获取后台返回给客户端的真正错误码，并联系后台同事协助解决。
     
     名称：ZZVC_ERR_SERVER_INVALID_ARGUMENT
     取值：10002
     含义：错误参数
     原因：调用SDK接口时，或SDK内部发送信令给后台时，传了错误的参数，具体原因需要通过分析日志确认后台返回给客户端的真正错误码才能知道。
     方案：确保调用SDK接口时所传的参数的正确性。分析日志，获取后台返回给客户端的真正错误码，并联系后台同事协助解决。
     
     名称：ZZVC_ERR_SERVER_NO_PERMISSION
     取值：10003
     含义：没有权限
     原因：没有权限使用某个功能，具体原因需要通过分析日志确认后台返回给客户端的真正错误码才能知道。如进入房间时所带的签名错误或过期，就会产生这个错误。
     方案：确保在设置正确的权限参数后才去使用相应的功能。分析日志，获取后台返回给客户端的真正错误码，并联系后台同事协助解决。
     
     名称：ZZVC_ERR_SERVER_TIMEOUT
     取值：10004
     含义：超时
     原因：具体原因需要通过分析日志确认后台返回给客户端的真正错误码才能知道。
     方案：分析日志，获取后台返回给客户端的真正错误码，并联系后台同事协助解决。
     
     名称：ZZVC_ERR_SERVER_ALLOC_RESOURCE_FAILED
     取值：10005
     含义：资源不够
     原因：执行某些操作时，需要分配更多的资源(如内存)失败了，或者超过最大的资源限制(如超过最大的房间成员人数)，则会产生这个错误。
     方案：具体原因需要通过分析日志确认后台返回给客户端的真正错误码才能知道。  分析日志，获取后台返回给客户端的真正错误码，并联系后台同事协助解决。
     
     名称：ZZVC_ERR_SERVER_ID_NOT_IN_ROOM
     取值：10006
     含义：不在房间内
     原因：在不在房间内时，去执行某些操作，则会产生这个错误。具体原因需要通过分析日志确认后台返回给客户端的真正错误码才能知道。
     方案：分析日志，获取后台返回给客户端的真正错误码，并联系后台同事协助解决。
     
     名称：ZZVC_ERR_SERVER_NOT_IMPLEMENT
     取值：10007
     含义：未实现
     原因：调用SDK接口时，如果相应的功能还未支持，则会产生这个错误。
     方案：暂不支持该功能，找其他替代方案。
     
     名称：ZZVC_ERR_SERVER_REPEATED_OPERATION
     取值：10008
     含义：重复操作
     原因：具体原因需要通过分析日志确认后台返回给客户端的真正错误码才能知道。
     方案：分析日志，获取后台返回给客户端的真正错误码，并联系后台同事协助解决。
     
     名称：ZZVC_ERR_SERVER_ROOM_NOT_EXIST
     取值：10009
     含义：房间不存在
     原因：房间不存在时，去执行某些操作，则会产生这个错误。
     方案：分析日志，获取后台返回给客户端的真正错误码，并联系后台同事协助解决。
     
     名称：ZZVC_ERR_SERVER_ENDPOINT_NOT_EXIST
     取值：10010
     含义：成员不存在
     原因：某个成员不存在时，去执行该成员相关的操作，则会产生这个错误。
     方案：分析日志，获取后台返回给客户端的真正错误码，并联系后台同事协助解决。
     
     名称：ZZVC_ERR_SERVER_INVALID_ABILITY
     取值：10011
     含义：错误能力
     原因：具体原因需要通过分析日志确认后台返回给客户端的真正错误码才能知道。
     方案：分析日志，获取后台返回给客户端的真正错误码，并联系后台同事协助解决。
     
     */
    
    /*********服务器错误**********/
    ZZVC_ERR_SERVER_FAILED = 10001,
    ZZVC_ERR_SERVER_INVALID_ARGUMENT = 10002,
    ZZVC_ERR_SERVER_NO_PERMISSION = 10003,
    ZZVC_ERR_SERVER_TIMEOUT = 10004,
    ZZVC_ERR_SERVER_ALLOC_RESOURCE_FAILED = 10005,
    ZZVC_ERR_SERVER_ID_NOT_IN_ROOM = 10006,
    ZZVC_ERR_SERVER_NOT_IMPLEMENT = 10007,
    ZZVC_ERR_SERVER_REPEATED_OPERATION = 10008,
    ZZVC_ERR_SERVER_ROOM_NOT_EXIST = 10009,
    ZZVC_ERR_SERVER_ENDPOINT_NOT_EXIST = 10010,
    ZZVC_ERR_SERVER_INVALID_ABILITY = 10011,
    
    
};
