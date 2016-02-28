//
//  util.h
//  ZZVCSDKDemo
//
//  Created by xianhuanlin on 15/6/25.
//  Copyright (c) 2015年 TOBINCHEN. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "ZZVCSDK/ZZVCSDK.h"
#import "ZZVideoChat.h"

@interface AVUtil : NSObject{
    ZZVCContext *_context;
}

+(void)ShowMsg:(NSString*)msg;

+(void)SetEnableRecord:(BOOL)isEnable;
+(BOOL)isEnableRecord;

+(ZZVCContext*)sharedContext;

+(void)destroyShardContext;

+(BOOL)isIphone4S:(UIViewController*)controller;
@end