//
//  MultiRoomMemberModel.m
//  QAVSDKDemo_P
//
//  Created by TOBINCHEN on 14-11-19.
//  Copyright (c) 2014年 TOBINCHEN. All rights reserved.
//

#import "MultiRoomMemberModel.h"
#import "QAVSDk/QAVSDK.h"

NSString* EndpointStateUpdate=@"EndpointStateUpdate";

@implementation MemberData

-(id)init{
    return [super init];
}

-(void)dealloc{
    return [super dealloc];
}

@end

@implementation MultiRoomMemberModel
-(id)init
{
    self=[super init];
    if (self) {
        _roomId=0;
        _audioAndCameraEndpoints=[[NSMutableArray alloc] init];
        _screenEndpoints=[[NSMutableArray alloc] init];
        _endpoints=[[NSMutableArray alloc] init];
    }
    return self;
}
-(void)dealloc
{
    [_audioAndCameraEndpoints release];
    [_screenEndpoints release];
    [_endpoints release];
    [super dealloc];
}
-(NSMutableArray*)endpoints
{
    return [self mutableArrayValueForKey:@"endpoints"];
}

-(void)updateAudioAndCameraMember:(NSArray*)identifiers{
    //demo的要求是显示有音频和视频的成员列表
    
    //对于一个已经在成员列表里的成员只更新状态
    for (QAVEndpoint*endpoint in identifiers){
        //没有音频和视频的就删除
        BOOL isDelete = YES;
        if (endpoint.isAudio || endpoint.isCameraVideo){
            isDelete = NO;
        }
        
        BOOL isExisted = NO;
        
        for(int n = 0 ; n < _audioAndCameraEndpoints.count;n++){
            MemberData*data = _audioAndCameraEndpoints[n];
            if ([endpoint.identifier compare:data.identifier] == NSOrderedSame){
                isExisted = YES;
                if (isDelete){
                    [_audioAndCameraEndpoints removeObjectAtIndex:n];
                }else{
                    data.isCameraVideo = endpoint.isCameraVideo;
			data.isScreenVideo = NO;
                    data.isAudio = endpoint.isAudio;
                }
                break;
            }
        }
        
        if (isDelete || isExisted)
            continue;
        
        //不在成员列表里的成语重新添加
        MemberData* data = [[[MemberData alloc]init] autorelease];
        
        data.identifier = endpoint.identifier;
        data.isCameraVideo = endpoint.isCameraVideo;
	data.isScreenVideo = NO;
        data.isAudio = endpoint.isAudio;
        [_audioAndCameraEndpoints addObject:data];
        
    }
    
    [_endpoints removeAllObjects];
    [_endpoints addObjectsFromArray:_audioAndCameraEndpoints];
    [_endpoints addObjectsFromArray:_screenEndpoints];
}

-(void)updateScreenMember:(NSArray*)identifiers{
    
    //同一个时刻只会有一个人上屏幕视频，所以简单处理。
    [_screenEndpoints removeAllObjects];
    for (QAVEndpoint*endpoint in identifiers)
    {
        if (endpoint.isScreenVideo)
        {
            MemberData* data = [[[MemberData alloc]init] autorelease];
            
            data.identifier = endpoint.identifier;
            data.isCameraVideo = NO;
            data.isScreenVideo = endpoint.isScreenVideo;
            data.isAudio = NO;
            [_screenEndpoints addObject:data];
        }
    }
    [_endpoints removeAllObjects];
    [_endpoints addObjectsFromArray:_audioAndCameraEndpoints];
    [_endpoints addObjectsFromArray:_screenEndpoints];
}

-(void)deleteMember:(NSArray*)identifiers{
    for (QAVEndpoint*endpointToDelete in identifiers){
        for (NSInteger index = 0; index < _audioAndCameraEndpoints.count; index++){
            MemberData*data = _audioAndCameraEndpoints[index];
            if ([data.identifier compare:endpointToDelete.identifier] == NSOrderedSame){
                [_audioAndCameraEndpoints removeObjectAtIndex:index];
                break;
            }
        }
    }
    
    for (QAVEndpoint*endpointToDelete in identifiers){
        for (NSInteger index = 0; index < _screenEndpoints.count; index++){
            MemberData*data = _screenEndpoints[index];
            if ([data.identifier compare:endpointToDelete.identifier] == NSOrderedSame){
                [_screenEndpoints removeObjectAtIndex:index];
                break;
            }
        }
    }

    [_endpoints removeAllObjects];
    [_endpoints addObjectsFromArray:_audioAndCameraEndpoints];
    [_endpoints addObjectsFromArray:_screenEndpoints];
}
@end
