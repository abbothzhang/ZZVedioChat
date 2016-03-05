//
//  util.h
//  QAVSDKDemo
//
//  Created by xianhuanlin on 15/6/25.
//  Copyright (c) 2015年 TOBINCHEN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QAVSDK/QAVSDK.h"

@interface AVUtil : NSObject{
    QAVContext *_context;
}

+(void)ShowMsg:(NSString*)msg;

+(void)SetEnableRecord:(BOOL)isEnable;
+(BOOL)isEnableRecord;

+(QAVContext*)sharedContext;

+(void)destroyShardContext;

+(BOOL)isIphone4S:(UIViewController*)controller;
@end