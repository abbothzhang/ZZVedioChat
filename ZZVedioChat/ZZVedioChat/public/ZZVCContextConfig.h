//
//  ZZVCContextConfig.h
//  QAVSDKDemo_public
//
//  Created by albert on 16/2/28.
//  Copyright © 2016年 TOBINCHEN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZZVCContextConfig : NSObject

@property (copy,nonatomic) NSString* sdkAppId;  ///< 腾讯为每个使用SDK的App分配多AppId。
@property (copy,nonatomic) NSString* appIdAtThird;  ///< App使用的OAuth授权体系分配的AppId。
@property (copy,nonatomic) NSString* identifier;    ///< 帐号名
@property (copy,nonatomic) NSString* accountType;   ///< 腾讯为每个接入方分配的帐号类型。

@end
