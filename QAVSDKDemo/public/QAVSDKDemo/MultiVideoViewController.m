//
//  FirstViewController.m
//  AVTest
//
//  Created by TOBINCHEN on 14-8-13.
//  Copyright (c) 2014年 TOBINCHEN. All rights reserved.
//

#import "MultiVideoViewController.h"
#import "UserHeadCell.h"
#include "UserConfig.h"


#define _TEST_GL_RENDER



@implementation PlayerView

-(id)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
    }
    return self;
}
-(void)setVideoView:(UIView *)videoView{
    if (_videoView==videoView) {
        return;
    }
    [_videoView release];
    _videoView=[videoView retain];
    
    [self addSubview:videoView];
    [self setNeedsLayout];
}
-(void)layoutSubviews{
    [super layoutSubviews];
    _videoView.frame=self.bounds;
}

@end
#pragma mark VideoViewController
@interface MultiVideoViewController ()

@end

@implementation MultiVideoViewController
-(void)dealloc
{
    [_currentVideoEndpoint release];
    
    [_users release];
    
    [_render release];
    [_subRender release];
    
    [super dealloc];
}
-(void)loadView
{
    [super loadView];
    [_collectionView registerClass:[UserHeadCell class] forCellWithReuseIdentifier:UserHeadCellID];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    ContextConfig* config=[[ContextConfig alloc] init];
    config.accountType=[UserConfig shareConfig].accountType;
    
    config.sdkAppID=[UserConfig shareConfig].sdkAppId;
    config.sdkAppToken=[UserConfig shareConfig].sdkAppIdToken;
    
    config.appId_at3rd=[UserConfig shareConfig].AppIdThird;
    
    config.identifier=[UserConfig shareConfig].currentUser[UserOpenIdKey];
    config.user_sig=[UserConfig shareConfig].currentUser[UserTokenKey];
    
    [AVMultiManager shareManager].roomType = AVRoomType_Mult;
    [[AVMultiManager shareManager] startContext:config completion:^(AVResult result){
        
    }];
    
    _users=[[NSMutableArray alloc] init];
    
    [AVMultiManager shareManager].delegate=self;
#ifdef _TEST_GL_RENDER
    OpenGLRender* aRender=[[OpenGLRender alloc] init];
#else
    ImageRender* aRender=[[ImageRender alloc] init];
    aRender.autoScrollAndScale=YES;
#endif
    _render=aRender;
    
    AVSingleFrameDispatcher* frameDispatcher=[[[AVSingleFrameDispatcher alloc] init] autorelease];
    frameDispatcher.render=_render;
    
    [AVMultiManager shareManager].frameDispatcher=frameDispatcher;

    _videoView.videoView=_render.videoView;
    _videoView.translatesAutoresizingMaskIntoConstraints=YES;

#ifdef _TEST_GL_RENDER
#else
    UITapGestureRecognizer* _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandle:)];
    _tapGesture.numberOfTapsRequired = 2;
    [_videoView addGestureRecognizer:_tapGesture];

    UIPinchGestureRecognizer* _zoomTapGesture=[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(zoomHandle:)];
    [_videoView addGestureRecognizer:_zoomTapGesture];

    UIPanGestureRecognizer* _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panHandle:)];
    _panGesture.maximumNumberOfTouches = 1;
    _panGesture.minimumNumberOfTouches = 1;
    [_videoView addGestureRecognizer:_panGesture];
#endif
    
    _btnDissolveRoom.enabled=NO;
    
    _videoView.clipsToBounds=YES;
}
- (IBAction)inputFinished:(id)sender;
{
    [_tfdRoomNumber resignFirstResponder];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark 预览拖拽
- (void)dragMoving:(UIControl *) control withEvent:event
{
    control.center = [[[event allTouches] anyObject] locationInView:self.view];
}
#pragma mark 手势操作
#ifdef _TEST_GL_RENDER
#else
- (void)panHandle:(UISwipeGestureRecognizer *)sender
{
    static CGPoint _gestureStartPoint;
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        _gestureStartPoint = [sender locationInView:_videoView];
    }else if(sender.state == UIGestureRecognizerStateChanged)
    {
        CGPoint curr_point = [sender locationInView:_videoView];
        //分别计算x，和y方向上的移动
        CGFloat _offsetX = curr_point.x-_gestureStartPoint.x ;
        CGFloat _offsetY = curr_point.y-_gestureStartPoint.y ;
        
        CGFloat min_offset = 0.5f;
        if(fabsf(_offsetX) >= min_offset || fabsf(_offsetY) >= min_offset)
        {
            [(ImageRender*)_render move:CGVectorMake(_offsetX, _offsetY)];
            _gestureStartPoint = curr_point;
        }

    }else if(sender.state == UIGestureRecognizerStateEnded)
    {
        [(ImageRender*)_render checkOutBound];
    }
}
- (void)zoomHandle:(UIPinchGestureRecognizer *)sender{
    static CGFloat zomm=0;
    if (sender.state == UIGestureRecognizerStateBegan) {
        zomm=1;
    }
    else if (sender.state == UIGestureRecognizerStateChanged) {
        ((ImageRender*)_render).scale=((ImageRender*)_render).scale+(sender.scale-zomm)/3;
    }
    else if(sender.state == UIGestureRecognizerStateEnded)
    {
        if (((ImageRender*)_render).scale<1) {
            [((ImageRender*)_render) setScale:1 animated:YES];
        }
    }
}

- (void)tapHandle:(UITapGestureRecognizer *)sender
{
//#define _TAP_ZOOM
#ifdef _TAP_ZOOM
    if (_render.scale!=_render.maxScale) {
        [_render setScale:_render.maxScale animated:YES];
    }else{
        [_render setScale:1 animated:YES];
    }
    
    return;
#else
    CGFloat angle=0;
    static CGRect   orect;
    if (_bFullScreen) {
        angle=0;
        _bFullScreen=NO;
        
        [UIView animateWithDuration:0.3 animations:^ {
             CGAffineTransform aTransform=CGAffineTransformMakeRotation(angle);
             _videoView.transform =aTransform;
             

            _videoView.frame=orect;
            self.tabBarController.tabBar.hidden=NO;

         } completion:^(BOOL finished) {
             
         }];
        
    }else{
        angle=M_PI*(90)/180.0;
        _bFullScreen=YES;
        orect=_videoView.frame;

        CGRect aRect=CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        [UIView animateWithDuration:0.3 animations:^{
            self.tabBarController.tabBar.hidden=YES;

            CGAffineTransform aTransform=CGAffineTransformMakeTranslation(aRect.size.width/2-(orect.origin.x+orect.size.width/2),aRect.size.height/2-(orect.origin.y+orect.size.height/2));

            //aTransform=CGAffineTransformScale(aTransform, aRect.size.width/orect.size.height,aRect.size.height/orect.size.width);
            aTransform=CGAffineTransformRotate(aTransform, angle);

            _videoView.transform=aTransform;
        _videoView.frame=aRect;
         } completion:^(BOOL finished) {
            
         }];
    }

    
#endif//_TAP_ZOOM
    
}

#endif

#pragma mark 界面响应
/**
 *  这里一般只需要创建房间，但是本Demo没有切换帐号的过程，因此加入了Context检查和启动的代码
 *
 *  @param sender
 */
-(IBAction)createRoom:(id)sender
{
    ContextConfig* config=[[[ContextConfig alloc] init] autorelease];
    config.accountType=[UserConfig shareConfig].accountType;
    
    config.sdkAppID=[UserConfig shareConfig].sdkAppId;
    config.sdkAppToken=[UserConfig shareConfig].sdkAppIdToken;
    
    config.appId_at3rd=[UserConfig shareConfig].AppIdThird;
    
    config.identifier=[UserConfig shareConfig].currentUser[UserOpenIdKey];
    config.user_sig=[UserConfig shareConfig].currentUser[UserTokenKey];
    
    
    if (![[UserConfig shareConfig].currentUser[UserOpenIdKey] isEqual:[AVMultiManager shareManager].config.identifier ]) {
        
        if ([[AVMultiManager shareManager] hasContext]) {//切换帐号,关掉重开
            [[AVMultiManager shareManager] closeContext:^(AVResult result){
                [[AVMultiManager shareManager] startContext:config completion:^(AVResult result){
                    [[AVMultiManager shareManager] createRoom:[_tfdRoomNumber.text intValue] relationType:AVW_RELATION_TYPE_OPENSDK completion:^(AVResult result) {
                        [self OnEnterRoomComplete:result];
                    }];
                }];
            }];
        }else{
            [[AVMultiManager shareManager] startContext:config completion:^(AVResult result){
                [[AVMultiManager shareManager] createRoom:[_tfdRoomNumber.text intValue] relationType:AVW_RELATION_TYPE_OPENSDK completion:^(AVResult result) {
                    [self OnEnterRoomComplete:result];
                }];
            }];
        }
    }else{
        if ([[AVMultiManager shareManager] hasContext]) {
            [[AVMultiManager shareManager] createRoom:[_tfdRoomNumber.text intValue] relationType:AVW_RELATION_TYPE_OPENSDK completion:^(AVResult result) {
                [self OnEnterRoomComplete:result];
            }];
        }else{
            [[AVMultiManager shareManager] startContext:config completion:^(AVResult result){
                [[AVMultiManager shareManager] createRoom:[_tfdRoomNumber.text intValue] relationType:AVW_RELATION_TYPE_OPENSDK completion:^(AVResult result) {
                    [self OnEnterRoomComplete:result];
                }];
            }];
            
        }
    }
}
-(IBAction)enterRoom:(id)sender
{
    [self createRoom:nil];
    return;
    ContextConfig* config=[[[ContextConfig alloc] init] autorelease];
    config.accountType=[UserConfig shareConfig].accountType;
    
    config.sdkAppID=[UserConfig shareConfig].sdkAppId;
    config.sdkAppToken=[UserConfig shareConfig].sdkAppIdToken;
    
    config.appId_at3rd=[UserConfig shareConfig].AppIdThird;
    
    config.identifier=[UserConfig shareConfig].currentUser[UserOpenIdKey];
    config.user_sig=[UserConfig shareConfig].currentUser[UserTokenKey];
    
    
    if (![[UserConfig shareConfig].currentUser[UserOpenIdKey] isEqual:[AVMultiManager shareManager].config.identifier ]) {
        
        if ([[AVMultiManager shareManager] hasContext]) {//切换帐号,关掉重开
            [[AVMultiManager shareManager] closeContext:^(AVResult result){
                [[AVMultiManager shareManager] startContext:config completion:^(AVResult result){
                    [[AVMultiManager shareManager] joinRoom:[_tfdRoomNumber.text intValue] completion:^(AVResult result) {
                        [self OnRoomJoinComplete:result];
                    }];
                }];
            }];
        }else{
            [[AVMultiManager shareManager] startContext:config completion:^(AVResult result){
                [[AVMultiManager shareManager] joinRoom:[_tfdRoomNumber.text intValue] completion:^(AVResult result) {
                    [self OnRoomJoinComplete:result];
                }];
            }];
        }
    }else{
        if ([[AVMultiManager shareManager] hasContext]) {
            [[AVMultiManager shareManager] joinRoom:[_tfdRoomNumber.text intValue] completion:^(AVResult result) {
                [self OnRoomJoinComplete:result];
            }];
        }else{
            [[AVMultiManager shareManager] startContext:config completion:^(AVResult result){
                [[AVMultiManager shareManager] joinRoom:[_tfdRoomNumber.text intValue] completion:^(AVResult result) {
                    [self OnRoomJoinComplete:result];
                }];
            }];
            
        }
    }

}
-(IBAction)leaveRoom:(id)sender
{
    if (![[AVMultiManager shareManager] hasContext]) {
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }else{
        if ([AVMultiManager shareManager].roomState==AVRoomStateNull) {
            [[AVMultiManager shareManager] closeContext:^(AVResult result) {
                [self dismissViewControllerAnimated:YES completion:^{
                    
                }];
            }];
        }else{

        [[AVMultiManager shareManager] closeRoom:^(AVResult result) {

        }];
        
        }
    }
    
}
-(IBAction)dissolveRoom:(id)sender
{
}
-(IBAction)toggleMic:(id)sender
{
    UIControl* control=sender;
    control.selected=!control.selected;
    
    [[AVMultiManager shareManager]  enableMic:control.selected];
}
-(IBAction)toggleSpeaker:(id)sender
{
    UIControl* control=sender;
    control.selected=!control.selected;
    
    [[AVMultiManager shareManager] enableSpeaker:control.selected];
}
-(IBAction)toggleCamera:(id)sender
{
    UIControl* control=sender;
    control.selected=!control.selected;
    
    [[AVMultiManager shareManager] enableCamera:control.selected completion:^(BOOL bEnable, AVResult result) {
        
    }];
}
-(IBAction)switchCamera:(id)sender
{
    UIControl* control=sender;
    control.selected=!control.selected;
    
    [[AVMultiManager shareManager] selectCamera:control.selected completion:^(NSInteger cameraId, AVResult result) {
        
    }];
}
-(IBAction)switchOutputMode:(id)sender
{
    UIControl* control=sender;
    control.selected=!control.selected;
    
    [[AVMultiManager shareManager] changeSpeakerMode:control.selected];
}
#pragma mark UICollectionView Delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _users.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UserHeadCell* cell=[collectionView dequeueReusableCellWithReuseIdentifier:UserHeadCellID forIndexPath:indexPath];
    
    AVEndpointInfo* userInfo=[_users objectAtIndex:indexPath.item];
    if (userInfo) {
        cell.headView.image=[UIImage imageNamed: [NSString stringWithFormat:@"head"]];
        cell.nameLabel.text=userInfo.identifier;
        if ([userInfo.identifier isEqualToString:[AVMultiManager shareManager].config.identifier]) {
            cell.nameLabel.text=@"self";
        }
        cell.endpointStateTypes=userInfo.stateTypes;

    }

    return cell;
}
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    AVEndpointInfo* userInfo=[_users objectAtIndex:indexPath.item];
    if ([userInfo.identifier isEqualToString:[AVMultiManager shareManager].config.identifier]) {//是自己，不允许点击
        return NO;
    }
    
    UserHeadCell* cell=(UserHeadCell*)[collectionView cellForItemAtIndexPath:indexPath];
    if ([cell isMemberOfClass:[UserHeadCell class]]) {
        return  cell.endpointStateTypes!=EndpointStateTypeNull && cell.endpointStateTypes!=EndpointStateTypeAudio;
    }
    
    return NO;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UserHeadCell* cell=(UserHeadCell*)[collectionView cellForItemAtIndexPath:indexPath];
    AVEndpointInfo* userInfo=[_users objectAtIndex:indexPath.item];
    if ([cell isMemberOfClass:[UserHeadCell class]]) {
        if (NO) {
            [[AVMultiManager shareManager] cancelView:userInfo completion:^(AVEndpointInfo *info, AVResult result) {
                [self CancelViewCallback:info result:result];
            }];
            [collectionView deselectItemAtIndexPath:indexPath animated:YES];
        }else{
            EndpointStateType endpointStateType=EndpointStateTypeCamera;//TODO:画面的类型
            [[AVMultiManager shareManager] requestView:userInfo type:endpointStateType completion:^(AVEndpointInfo *info, AVResult result) {
                [self RequestViewCallback:info result:result];
            }];
        }
    }
}


-(void)setupPreviewLayer{

    if (_previewLayer) {
        [_previewLayer removeFromSuperlayer];
    }
    _previewLayer = [[AVMultiManager shareManager] previewLayer];

    [_previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [_previewView.layer addSublayer:_previewLayer];
    _previewView.layer.borderWidth=1;
    _previewView.layer.borderColor=[UIColor grayColor].CGColor;
    _previewLayer.frame=_previewView.bounds;
    
    //[self.view.layer insertSublayer:_previewLayer atIndex:0];
    //_previewLayer.frame=self.view.bounds;
}
#pragma mark AVMultiManagerDelegate
-(void)OnEndpointsEnterRoom:(NSArray*)endpoints
{
    if (endpoints == nil)
        return;
    
    [_users addObjectsFromArray:endpoints];
    
    [_collectionView reloadData];
}
-(void)OnEndpointsExitRoom:(NSArray*)endpoints
{
    if (endpoints == nil)
        return;
    
    [_users removeObjectsInArray:endpoints];
    
    [_collectionView reloadData];
}

-(void)OnEndpointsUpdateInfo:(AVEndpointInfo *)endpoint stateType:(EndpointStateType)status change:(BOOL)change
{
    if (status==EndpointStateTypeCamera && change==NO) {
        if (_currentVideoEndpoint.identifier==endpoint.identifier) {
            [_render stopRender];
        }
    }
    [_collectionView reloadData];
}
#pragma mark 回调处理
-(void)OnEnterRoomComplete:(int)result{
    DDLogInfo(@"OnEnterRoomComplete:%@",[AVMultiManager shareManager].roomInfo);
    _btnCreateRoom.enabled=NO;
    _btnEnterRoom.enabled=NO;
    _btnLeaveRoom.enabled=YES;
    _btnDissolveRoom.enabled=YES;
    
    [self setupPreviewLayer];
}
-(void)OnRoomJoinComplete:(int)result{
    DDLogInfo(@"OnRoomJoinComplete");
    _btnCreateRoom.enabled=NO;
    _btnEnterRoom.enabled=NO;
    _btnLeaveRoom.enabled=YES;
    _btnDissolveRoom.enabled=YES;
}
-(void)OnExitRoomComplete:(int)result
{
    [_render stopRender];
    [[AVMultiManager shareManager] enableCamera:false completion:^(BOOL bEnable, AVResult result) {
        //
    }
     ];
    DDLogInfo(@"OnExitRoomComplete");
    [[AVMultiManager shareManager] closeContext:^(AVResult result){
        [self dismissViewControllerAnimated:true completion:^{
            
        }];;
    }];
}

-(void)RequestViewCallback:(AVEndpointInfo*)aEndpoint result:(AVResult)result
{
    DDLogInfo(@"RequestViewCallback:%@=>%d",aEndpoint,result);
    if (result==0) {
        if (_currentVideoEndpoint!=aEndpoint) {
            [_currentVideoEndpoint release];
            _currentVideoEndpoint=[aEndpoint retain];
        }
        [_render startRender];//TODO
        //[_subRender startRender];
    }

}
-(void)CancelViewCallback:(AVEndpointInfo*)aEndpoint result:(AVResult)result
{
    DDLogInfo(@"CancelViewCallback:%@=>%d",aEndpoint,result);
    if (result==0) {
        if(aEndpoint.identifier==aEndpoint.identifier){
            [_currentVideoEndpoint release];
            _currentVideoEndpoint=nil;
            [_render stopRender];//TODO
        }
    }
}


-(void)OnQueryRoomInfoComplete:(AVRoomInfo*)info result:(int)result
{
    DDLogInfo(@"OnQueryRoomInfoComplete:%@=>%d",info,result);
}
@end
