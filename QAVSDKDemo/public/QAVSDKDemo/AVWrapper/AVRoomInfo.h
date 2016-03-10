//
//  AVRoomInfo.h
//  QAVSDKDemo_P
//
//  Created by TOBINCHEN on 14-11-5.
//  Copyright (c) 2014年 TOBINCHEN. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  房间信息
 */
@interface AVRoomInfo : NSObject{
    NSInteger _roomType;
    unsigned long long _roomId;
    NSInteger _relationType;
    unsigned long long _relationId;
    NSData* _buf;
}

@property (assign,nonatomic) NSInteger room_type;
@property (assign,nonatomic) unsigned long long room_id;
@property (assign,nonatomic) NSInteger relation_type;
@property (assign,nonatomic) unsigned long long relation_id;
@property (retain,nonatomic) NSData* buf;
@end
