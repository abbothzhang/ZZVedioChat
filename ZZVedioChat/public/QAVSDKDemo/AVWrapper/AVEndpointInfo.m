//
//  AVEndpointInfo.m
//  QAVSDKDemo_P
//
//  Created by TOBINCHEN on 14-11-5.
//  Copyright (c) 2014年 TOBINCHEN. All rights reserved.
//

#import "AVEndpointInfo.h"

@implementation AVEndpointInfo

-(void)dealloc
{
    [_sdkAppId release];
    [_appIdThird release];
    [_identifier release];
    [super dealloc];
}
@end
