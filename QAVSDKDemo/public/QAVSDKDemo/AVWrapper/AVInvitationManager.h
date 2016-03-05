//
//  AVInvitationManager.h
//  QAVSDKDemo_P
//
//  Created by TOBINCHEN on 14-10-28.
//  Copyright (c) 2014年 TOBINCHEN. All rights reserved.
//

#import <Foundation/Foundation.h>

//#define _TEST_INVITE


@interface AVPeerInvitation : NSObject
@property (nonatomic,assign) unsigned long long roomId;
@property (nonatomic,copy) NSString* identifier;
@property (nonatomic,copy) NSString* userName;
@end

@protocol InvitationDelegate <NSObject>
/**
 *  收到邀请
 *
 *  @param invitation 邀请
 */
-(void)recvInvitation:(AVPeerInvitation*)invitation;
/**
 *  对方接收邀请
 *
 *  @param invitation 邀请
 */
-(void)acceptInvitation:(AVPeerInvitation*)invitation;
/**
 *  对方解决邀请
 *
 *  @param invitation 邀请
 */
-(void)refuseInvitation:(AVPeerInvitation*)invitation;

-(void)cancelInvitation:(AVPeerInvitation*)invitation;
@end

typedef void (^InvitaionCompletion)(AVPeerInvitation* invitation,int result);

@interface AVInvitationManager : NSObject{
    id<InvitationDelegate> _delegate;
}
@property (nonatomic,assign) id<InvitationDelegate> delegate;
@property (nonatomic,retain,readonly) AVPeerInvitation* sendedInvitation;
@property (nonatomic,retain,readonly) AVPeerInvitation* recvedInvitation;

-(BOOL)invite:(AVPeerInvitation*)invitation completion:(InvitaionCompletion) completion;
-(BOOL)accept:(AVPeerInvitation*)invitation completion:(InvitaionCompletion) completion;
-(BOOL)refuse:(AVPeerInvitation*)invitation completion:(InvitaionCompletion) completion;
@end
