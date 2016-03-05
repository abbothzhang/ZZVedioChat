//
//  AVInvitationManager.m
//  QAVSDKDemo_P
//
//  Created by TOBINCHEN on 14-10-28.
//  Copyright (c) 2014年 TOBINCHEN. All rights reserved.
//

#import "AVInvitationManager.h"
#import "av_invitation_base.h"

class AVInvitationDelegate;


@implementation AVPeerInvitation


@end


@interface AVInvitationManager (InvitationDelegate)
-(void)OnInvitationReceived:(std::string&)open_id roomId:(uint64)room_id mode:(int)av_mode;
-(void)OnInvitationAccepted;
-(void)OnInvitationRefused;
-(void)OnInvitationCanceled:(std::string&)open_id;
@end


@interface AVInvitationManager (){
    AVInvitationBase* _invitation;
    AVInvitationDelegate* _invitationDelegate;
    
    InvitaionCompletion _inviteCompletion;
    InvitaionCompletion _acceptCompletion;
    InvitaionCompletion _refuseCompletion;
    
    AVPeerInvitation* _sendedInvitation;
    AVPeerInvitation* _recvedInvitation;
}
-(void)inviteCallbak:(int)result data:(void*)data;
-(void)acceptCallbak:(int)result data:(void*)data;
-(void)refuseCallbak:(int)result data:(void*)data;
@end


class AVInvitationDelegate:public AVInvitationBase::Delegate{
public:
    AVInvitationDelegate(AVInvitationManager* invitationManager):m_invitationManager(invitationManager){}
    ~AVInvitationDelegate(){}
    
    virtual void OnInvitationReceived(std::string& open_id,  uint64 room_id, int av_mode) {
        [m_invitationManager OnInvitationReceived:open_id roomId:room_id mode:av_mode];
    }
    virtual void OnInvitationAccepted() {
        [m_invitationManager OnInvitationAccepted];
    }
    virtual void OnInvitationRefused() {
        [m_invitationManager OnInvitationRefused];
    }
    virtual void OnInvitationCanceled(std::string& open_id) {
        [m_invitationManager OnInvitationCanceled:open_id];
    }
    
    
    static void InviteCallback(int result, void* cookie){
        AVInvitationDelegate* invitationDelegate=(AVInvitationDelegate*)cookie;
        if (invitationDelegate) {
            [invitationDelegate->m_invitationManager inviteCallbak:result data:cookie];
        }
    };
    static void AcceptCallback(int result, void* cookie){
        AVInvitationDelegate* invitationDelegate=(AVInvitationDelegate*)cookie;
        if (invitationDelegate) {
            [invitationDelegate->m_invitationManager acceptCallbak:result data:cookie];
        }
    };
    static void RefuseCallback(int result, void* cookie){
        AVInvitationDelegate* invitationDelegate=(AVInvitationDelegate*)cookie;
        if (invitationDelegate) {
            [invitationDelegate->m_invitationManager refuseCallbak:result data:cookie];
        }
    };
private:
    AVInvitationManager* m_invitationManager;
};



@implementation AVInvitationManager

-(id)init
{
    self=[super init];
    if (self) {
        _invitationDelegate=new AVInvitationDelegate(self);
        
        _invitation=AVInvitationBase::CreateInvitation();
        _invitation->SetDelegate(_invitationDelegate);

    }
    return  self;
}
-(void)dealloc{
    [_recvedInvitation release];
    [_sendedInvitation release];
    delete _invitation;
    delete _invitationDelegate;
    [super dealloc];
}
-(void)inviteCallbak:(int)result data:(void*)data
{
    //DDLogInfo(@"inviteCallbak:%d",result);
    if (_inviteCompletion) {
        _inviteCompletion(_sendedInvitation,result);
        Block_release(_inviteCompletion);
        _inviteCompletion=nil;
    }
}

-(BOOL)invite:(AVPeerInvitation*)invitation  completion:(InvitaionCompletion) completion
{
   // DDLogInfo(@"invite:%@=>%lld",invitation.identifier,invitation.roomId);
    if (_inviteCompletion) {
        return NO;
    }
    if (_sendedInvitation!=invitation) {
        [_sendedInvitation release];
        _sendedInvitation=[invitation retain];
    }
    
    _inviteCompletion=Block_copy(completion);
    _invitation->Invite(_sendedInvitation.identifier.UTF8String, _sendedInvitation.roomId, AVInvitationDelegate::InviteCallback, _invitationDelegate);
    
    return YES;
}

-(void)acceptCallbak:(int)result data:(void*)data
{
   // DDLogInfo(@"acceptCallbak:%d",result);
    if (_acceptCompletion) {
        _acceptCompletion(_recvedInvitation,result);
        Block_release(_acceptCompletion);
        _acceptCompletion=nil;
    }
    
    [_recvedInvitation release];
    _recvedInvitation=nil;
}
-(BOOL)accept:(AVPeerInvitation*)invitation completion:(InvitaionCompletion) completion
{
    //DDLogInfo(@"accept:%@=>%lld",invitation.identifier,invitation.roomId);
    if (_acceptCompletion) {
        return NO;
    }
    
    _acceptCompletion=Block_copy(completion);
    _invitation->Accept(invitation.identifier.UTF8String, AVInvitationDelegate::AcceptCallback, _invitationDelegate);
    return YES;
}

-(void)refuseCallbak:(int)result data:(void*)data{
  //  DDLogInfo(@"refuseCallbak:%d",result);
    if (_refuseCompletion) {
        _refuseCompletion(_recvedInvitation,result);
        Block_release(_refuseCompletion);
        _refuseCompletion=nil;
    }
    
    [_recvedInvitation release];
    _recvedInvitation=nil;
}
-(BOOL)refuse:(AVPeerInvitation*)invitation completion:(InvitaionCompletion) completion
{
   // DDLogInfo(@"Refuse:%@",invitation.identifier);
    if (_refuseCompletion) {
        return NO;
    }
    
    _refuseCompletion=Block_copy(completion);
    _invitation->Refuse(invitation.identifier.UTF8String,  AVInvitationDelegate::RefuseCallback, _invitationDelegate);
    return NO;
}

#pragma mark delegate
-(void)OnInvitationReceived:(std::string&)open_id roomId:(uint64)room_id mode:(int)av_mode{
    
   // DDLogInfo(@"accept:%s=>%lld",open_id.c_str(),room_id);
    if (_recvedInvitation) {
        [_recvedInvitation release];
        _recvedInvitation=nil;
    }
    
    _recvedInvitation=[[AVPeerInvitation alloc] init];
    _recvedInvitation.identifier=[NSString stringWithUTF8String:open_id.c_str()];
    _recvedInvitation.roomId=room_id;
    

    [_delegate recvInvitation:_recvedInvitation];
}
-(void)OnInvitationAccepted{
   // DDLogInfo(@"OnInvitationAccepted");
    [_delegate acceptInvitation:_sendedInvitation];
    [_sendedInvitation release];
    _sendedInvitation=nil;
}
-(void)OnInvitationRefused{
   // DDLogInfo(@"OnInvitationRefused");
    [_delegate refuseInvitation:_sendedInvitation];
    [_sendedInvitation release];
    _sendedInvitation=nil;
}
-(void)OnInvitationCanceled:(std::string&)open_id{
   // DDLogInfo(@"OnInvitationCanceled:%s",open_id.c_str());
    [_delegate cancelInvitation:_sendedInvitation];
    [_sendedInvitation release];
    _sendedInvitation=nil;
}
@end
