//
//  AVFrameDispatcher.m
//  ZZVCSDKDemo_P
//
//  Created by TOBINCHEN on 14-11-4.
//  Copyright (c) 2014年 TOBINCHEN. All rights reserved.
//

#import "AVFrameDispatcher.h"
#import "ZZVideoChat.h"

@implementation AVFrameInfo

-(void)dealloc
{
    [_identifier release];
    [_data release];
    [super dealloc];
}
@end

@implementation AVFrameDispatcher

-(void)dispatchVideoFrame:(AVFrameInfo *)args isSubFrame:(BOOL) isSubFrame
{
    return;
}
@end

@implementation AVSingleFrameDispatcher

-(void)dispatchVideoFrame:(ZZVCVideoFrame*)args isSubFrame:(BOOL) isSubFrame
{
    if (self.imageView != nil) {
        NSString *renderKey = [NSString stringWithFormat:@"%@%d", args.identifier, (int)args.frameDesc.srcType];
        
        AVGLRenderView * glView = [self.imageView getSubviewForKey:renderKey];
        
        if (glView) {
            
            unsigned int selfFrameAngle = 1;//[self didRotate:YES];
            unsigned int peerFrameAngle = args.frameDesc.rotate%4;
            
            float degree = [self calcRotateAngle:peerFrameAngle SelfAngle:selfFrameAngle];
            BOOL full = [self calcFullScr:peerFrameAngle SelfAngle:selfFrameAngle];
            
            
            AVGLImage * image = [[AVGLImage new]autorelease];
            image.angle = degree;
            image.data = (Byte *)args.data;
            image.width = (int)args.frameDesc.width;
            image.height = (int)args.frameDesc.height;
            image.isFullScreenShow = full;
            image.viewStatus = VIDEO_VIEW_DRAWING;
            image.dataFormat = Data_Format_I420;
            
            [glView setImage:image];
        }

    }
}

- (float)calcRotateAngle:(int)peerFrameAngle SelfAngle:(int)frameAngle
{
    float degree = 0.0f;
    
    frameAngle = (frameAngle+peerFrameAngle+3)%4;
    
    // 调整显示角度
    switch (frameAngle)
    {
        case 0:
        {
            degree = -180.0f;
        }
            break;
        case 1:
        {
            degree = -90.0f;
        }
            break;
        case 2:
        {
            degree = 0.0f;
        }
            break;
        case 3:
        {
            degree = 90.0f;
        }
            break;
        default:
        {
            degree = 0.0f;
        }
            break;
    }

    return degree;
}

- (BOOL)calcFullScr:(int)peerFrameAngle SelfAngle:(int)frameAngle
{
    if ((peerFrameAngle & 1) == 0 && (frameAngle & 1) == 0)
    {
        // 对方和自己都是横屏
        return YES;
    }
    else if ((peerFrameAngle & 1) && (frameAngle & 1))
    {
        // 对方和自己都是竖屏
        return YES;
    }
    else if ((peerFrameAngle & 1) == 0 && (frameAngle & 1))
    {
        // 对方横屏，自己竖屏
        return NO;
    }
    else if ((peerFrameAngle & 1) && (frameAngle & 1) == 0)
    {
        // 对方竖屏，自己横屏
        return NO;
    }
    return YES;
}

@end