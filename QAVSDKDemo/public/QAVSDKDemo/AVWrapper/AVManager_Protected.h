//
//  AVManager_Protected.h
//  QAVSDKDemo_P
//
//  Created by TOBINCHEN on 14-10-28.
//  Copyright (c) 2014年 TOBINCHEN. All rights reserved.
//

#import "AVManager.h"
#import "AVRoomDeletateImp.h"
#import "AVRoomInfo.h"

typedef NS_ENUM(NSUInteger, ViewKeyType) {
    ViewKeyTypeRequest,
    ViewKeyTypeCancel,
    ViewKeyTypeBan,
};
/**
 *  AVBasicManager的私有方法
 */
@interface AVBasicManager (){
    @private
    AVCompletion _contextStartCompletion;
    AVCompletion _contextCloseCompletion;
    
    AVCompletion _enterRoomCompletion;
    AVCompletion _closeRoomCompletion;
    
    AVEnableCameraCompleteCompletion _enableCameraCompletion;
    AVSwitchCameraCompleteCompletion _switchCameraCompletion;
    
    AVRoomInfoCompletion _queryRoomCompletion;
    NSMutableDictionary* _completions;
    @protected
    AVBasicRoomDeletateImp* _delegateImp;
    //tencent::av::AVContext* _avContext;
}
-(tencent::av::AVContext*)avContect;
-(void)initRenderDevice;
-(void)uninitRenderDevice;

-(void)setRoomState:(AVRoomState)roomState;

-(BOOL)_createRoom:(tencent::av::AVRoom::EnterRoomParam*) param completion:(AVCompletion)completion;
-(BOOL)_joinRoom:(tencent::av::AVRoom::EnterRoomParam*)param completion:(AVCompletion)completion;


#pragma mark 画面相关
-(BOOL)doRequestView:(NSArray*)identifier_list;
-(BOOL)doRequestView:(AVEndpointInfo*)aEndpoint type:(EndpointStateType)endpointStateType;
-(BOOL)doCancelView:(AVEndpointInfo*)aEndpoint type:(EndpointStateType)endpointStateType;
-(BOOL)doCancelAllView;


#pragma mark 回调block相关
-(NSString*)keyforEndpoint:(AVEndpointInfo*)endpoint viewType:(NSInteger)viewType keyType:(ViewKeyType)keyType;
-(NSString*)setCompletion:(AVEndpointCompletion)completion forEndpoint:(AVEndpointInfo*)aEndpoint viewType:(NSInteger)viewType keyType:(NSInteger)keyType;
-(AVEndpointCompletion)completionForEndpoint:(AVEndpointInfo*)aEndpoint viewType:(NSInteger)viewType keyType:(NSInteger)keyType;
-(void)removeCompletion:(NSString*)key;
@end

@interface AVEndpointInfo (Private)
-(id)initWithEndpoint:(tencent::av::AVEndpoint*)endpoint;
-(void)updateWithEndpoint:(tencent::av::AVEndpoint*)endpoint;
@end

@interface AVFrameInfo (Private)
-(id)initWithFrame:(tencent::av::VideoFrame*)videoFrame;
@end

@interface AVRoomInfo (Private)

@end