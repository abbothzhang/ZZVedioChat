//
//  ZZVCMultiRoom.h
//  ZZVCSDKDemo_public
//
//  Created by albert on 16/2/28.
//  Copyright © 2016年 TOBINCHEN. All rights reserved.
//

#import "ZZVCRoom.h"
#import "ZZVCEndpoint.h"
#import "ZZVCError.h"

/**
 @brief 多人房间封装类
 
 */
@interface ZZVCMultiRoom :ZZVCRoom{
    NSMutableDictionary* _endpointCache;
}

/**
 @brief 获得该房间内所有房间成员的ZZVCEndpoint对象列表。
 
 @details 房间成员列表是一个有序的列表，一般情况下，是按照进入房间的先后进行排序。
 App可以通过此成员函数获得指定的ZZVCEndpoint对象。
 
 @return 以数组形式返回全部的ZZVCEndpoint对象；出错时返回nil。
 
 */
-(NSArray*)GetEndpointList;

/**
 @brief 根据成员帐号获得房间成员的ZZVCEndpoint对象。
 
 @details 帐号名(用户名)可以作为房间成员之间的唯一标识。
 App可以通过此成员函数获得指定的ZZVCEndpoint对象。
 
 @param identifier 要获得的ZZVCEndpoint对象的帐号名(用户名)。
 
 @return 返回指定的ZZVCEndpoint对象；出错时返回nil。
 
 */
-(ZZVCEndpoint*)GetEndpointById:(NSString*)identifier;


/**
 @brief 更改自己在房间内的权限。
 
 @details 通话中动态修改自己的音视频上下行权限，用于第三方实现权限控制和管理。
 
 @param buff 权鉴加密串。
 
 @return 返回操作结果。
 */
-(ZZVCResult)ChangeAuthority:(NSData*)buff;

@end
