//
//  util.h
//  QAVSDKDemo
//
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