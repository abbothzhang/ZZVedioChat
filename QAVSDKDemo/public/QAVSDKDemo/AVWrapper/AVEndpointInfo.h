//
//  AVEndpointInfo.h
//  QAVSDKDemo_P
//
//  Created by TOBINCHEN on 14-11-5.
//  Copyright (c) 2014年 TOBINCHEN. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  成员状态
 */
typedef NS_OPTIONS(NSUInteger, EndpointStateType){
    /**
     *  为定义状态
     */
    EndpointStateTypeNull = 0,
    /**
     *  开启语音
     */
    EndpointStateTypeAudio = 1 << 0,
    /**
     *  开启摄像头
     */
    EndpointStateTypeCamera= 1 << 1,
	
	/**
     *  开启屏幕分享
     */
    EndpointStateTypeScreen= 1 << 2,
};


/**
 *  成员信息
 */
@interface AVEndpointInfo : NSObject{
    NSString* _identifier;
    NSString* _appIdThird;
    NSString* _sdkAppId;
    NSUInteger _sdkVersion;
    NSUInteger _terminalType;
    BOOL _has_audio;
    BOOL _has_camera_video;
	BOOL _has_screen_video;
    BOOL _is_mute;
    EndpointStateType _stateTypes;
    BOOL _isActive;
    BOOL _isVisitor;
    BOOL _isInBlackList;
}
@property (copy,readonly,nonatomic) NSString* identifier;
@property (copy,readonly,nonatomic) NSString* appIdThird;
@property (copy,readonly,nonatomic) NSString* sdkAppId;
@property (assign,readonly,nonatomic) NSUInteger sdkVersion;
@property (assign,readonly,nonatomic) NSUInteger terminalType;
@property (assign,readonly,nonatomic) unsigned char state;
@property (assign,readonly,nonatomic) EndpointStateType stateTypes;
@property (assign,readonly,nonatomic) BOOL isActive;
@property (assign,readonly,nonatomic) BOOL isVisitor;
@property (assign,readonly,nonatomic) BOOL isInBlackList;
@end
