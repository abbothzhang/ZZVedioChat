//
//  AVRoomInfo.m
//  QAVSDKDemo_P
//
//  Created by TOBINCHEN on 14-11-5.
//  Copyright (c) 2014年 TOBINCHEN. All rights reserved.
//

#import "AVRoomInfo.h"

@implementation AVRoomInfo

-(void)dealloc
{
    [_buf release];
    [super dealloc];
}
@end
