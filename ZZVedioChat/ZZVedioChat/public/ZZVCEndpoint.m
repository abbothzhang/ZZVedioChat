//
//  ZZVCEndpoint.m
//  QAVSDKDemo_public
//
//  Created by albert on 16/2/28.
//  Copyright © 2016年 TOBINCHEN. All rights reserved.
//

#import "ZZVCEndpoint.h"
#import <QAVSDK/QAVSDK.h>

@interface ZZVCEndpoint()

@property (nonatomic,strong) QAVEndpoint        *qavEndpoint;

@end



@implementation ZZVCEndpoint




/**
 @brief 请求多个成员的画面
 
 @details 异步返回结果。
 
 @param context 当前的ZZVCContext实例
 
 @param identifierList 请求的成员列表，传递成员的identifier(NSString*)
 
 @param srcTypeList 请求的成员列表，传递成员的avVideoSrcType(NSNumber*)
 
 @param block 申请的回调
 
 @return 具体查看ZZVCError.h
 */
+(int)requsetViewList:(ZZVCContext*)context identifierList:(NSArray*)identifierList srcTypeList:(NSArray*)srcTypeList ret:(RequestViewListBlock)block{
    return [QAVEndpoint requsetViewList:(QAVContext*)context identifierList:identifierList srcTypeList:srcTypeList ret:block];
}

/**
 @brief 取消多个成员的画面
 
 @details 异步返回结果。
 
 @param context 当前的ZZVCContext实例
 
 @param list 取消的成员列表，传递成员的identifier(NSString*)
 
 @param block 申请的回调
 
 @return 具体查看ZZVCError.h
 */
+(int)cancelAllview:(ZZVCContext*)context ret:(CancelViewListBlock)block{
    return [QAVEndpoint cancelAllview:(QAVContext*)context ret:block];
}

/**
 @brief 请求成员的视频画面。
 
 @details 异步返回结果。不同AVEndpoint对象的请求画面操作不是互斥的，既可以请求成员A的画面，也可以请求成员B的画面，但同一个时间点只能请求一个成员的画面。
 即必须等待异步结果返回后，才能进行新的请求画面操作。在请求画面前最好检查该成员是否有对应的视频源。
 
 @param block 返回请求视频画面是成功还是失败。
 
 @return ZZVC_OK表示调用成功，其他值表示失败：
 
 @remark
 － RequestView和CancelView不能并发执行，即同一时间点只能进行一种操作。
 － RequestView和CancelView配对使用。
 */
-(QAVResult)requestView:(RequestViewBlock)block{
    return [self.qavEndpoint requestView:block];
}

/**
 @brief 取消请求成员的视频画面。
 
 @details 和RequestView对应的逆操作，约束条件和RequestView一样。
 @param block 申请的回调
 @return ZZVC_OK表示调用成功，其他值表示失败：
 
 @remark
 － RequestView和CancelView不能并发执行，即同一时间点只能进行一种操作。
 － RequestView和CancelView配对使用。
 */
-(QAVResult)cancelView:(RequestViewBlock)block{
    return [self.qavEndpoint cancelView:block];
}

- (QAVEndpoint *)qavEndpoint{
    if (_qavEndpoint == nil) {
        _qavEndpoint = [[QAVEndpoint alloc] init];
    }
    return _qavEndpoint;
}

@end
