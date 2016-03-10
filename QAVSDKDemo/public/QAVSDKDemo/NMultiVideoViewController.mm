//
//  NMultiVideoViewController.m
//  QAVSDKDemo_P
//
//
#import "NMultiVideoViewController.h"
#import "MSDynamicsDrawerViewController.h"
#import "RoomMemberViewController.h"
#import "UserHeadCell.h"
#import "runningTipsView.h"
#import "AVUtil.h"
#import "AKNetworkReachability.h"
#import <AVFoundation/AVFoundation.h>
#import "UserConfig.h"
#import "functions.h"

FILE* videoOutputFile = NULL;

static UIImage* createImageWithColor(UIColor* color)
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}




@interface PreviewView : UIView
@property (retain,nonatomic) AVCaptureVideoPreviewLayer* previewLayer;
@end

@implementation PreviewView
-(id)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        self.backgroundColor=[UIColor blackColor];
    }
    return self;
}
-(void)layoutSubviews{
    [super layoutSubviews];
    _previewLayer.frame=self.bounds;
}
-(void)setPreviewLayer:(AVCaptureVideoPreviewLayer *)previewLayer{
    if (_previewLayer!=previewLayer) {
        [_previewLayer removeFromSuperlayer];
        [_previewLayer release];
        _previewLayer=[previewLayer retain];
        [self.layer addSublayer:_previewLayer];
        self.clipsToBounds=YES;
    }
}
-(void)dealloc
{
    [_previewLayer release];
    [super dealloc];
    
}
@end



@interface NMultiVideoViewController ()

@end

@implementation NMultiVideoViewController
-(void)dealloc
{
    [_identifierList release];
    [_srcTypeList release];
    [super dealloc];
}

-(void)InitUI{
    self.view.backgroundColor=[UIColor lightGrayColor];
    UIImageView* bkView=[[[UIImageView alloc] initWithFrame:self.view.bounds] autorelease];
    bkView.image=[UIImage imageNamed:@"background.jpg"];
    [self.view addSubview:bkView];
    
    CGRect rcGLView = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    _imageView = [[AVGLBaseView alloc] initWithFrame:rcGLView];
    [self.view addSubview:_imageView];
    
    _imageView.hidden = YES;
    @try {
        [_imageView initOpenGL];
        
    }
    @catch (NSException *exception)
    {
    }
    @finally {
        
    }

    UICollectionViewFlowLayout* flowLayout=[[[UICollectionViewFlowLayout alloc] init] autorelease];
    flowLayout.itemSize=CGSizeMake(60, 80);
    flowLayout.scrollDirection=UICollectionViewScrollDirectionHorizontal;
    flowLayout.sectionInset=UIEdgeInsetsMake(0, 10, 0, 10);
    
    _memberCollectionView=[[UICollectionView alloc] initWithFrame:CGRectMake(0, 80, CGRectGetWidth(self.view.bounds), 80) collectionViewLayout:flowLayout];
    _memberCollectionView.backgroundColor=[UIColor clearColor];
    [_memberCollectionView registerClass:UserHeadCell.class  forCellWithReuseIdentifier:UserHeadCellID];
    _memberCollectionView.dataSource=self;
    _memberCollectionView.delegate=self;
    [self.view addSubview:_memberCollectionView];
    
    _frameDispatcher=[[AVSingleFrameDispatcher alloc] init];
    _frameDispatcher.imageView = _imageView;
    UINavigationBar* navBar=[[[UINavigationBar alloc] initWithFrame:CGRectMake(0, 20, CGRectGetWidth(self.view.bounds), 40)] autorelease];
    [navBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [navBar setShadowImage:[UIImage new]];
    navBar.translucent=YES;
    [self.view addSubview:navBar];
    
    UINavigationItem *navItem=[[[UINavigationItem alloc] initWithTitle:@"多人通话"] autorelease];
    navItem.leftBarButtonItem=[[[UIBarButtonItem alloc] initWithTitle:@"成员" style:UIBarButtonItemStylePlain target:self action:@selector(showMembers:)] autorelease];
    navItem.leftBarButtonItem.image=[UIImage imageNamed:@"group"];
    
    navItem.rightBarButtonItem=[[[UIBarButtonItem alloc] initWithTitle:@"设置" style:UIBarButtonItemStylePlain target:self action:@selector(showSetting:)] autorelease];
    navItem.rightBarButtonItem.image=[UIImage imageNamed:@"setting"];
    
    [navBar pushNavigationItem:navItem animated:NO];
    
    UIButton* _closeButton=[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 50)];
    _closeButton.layer.cornerRadius=25;
    _closeButton.clipsToBounds=YES;
    [_closeButton setBackgroundImage:createImageWithColor([[UIColor redColor] colorWithAlphaComponent:0.4]) forState:UIControlStateNormal];
    [_closeButton setBackgroundImage:createImageWithColor([[UIColor redColor] colorWithAlphaComponent:1]) forState:UIControlStateSelected];
    [_closeButton setTitle:@"挂断" forState:UIControlStateNormal];
    _closeButton.center=CGPointMake(CGRectGetWidth(self.view.bounds)/2, CGRectGetHeight(self.view.bounds)-25-20);
    _closeButton.autoresizesSubviews=UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
    [_closeButton addTarget:self action:@selector(leaveRoom:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_closeButton];
    
    UIButton* _leftButton=[[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds)-50-20, 70, 50)];
    _leftButton.layer.cornerRadius=25;
    _leftButton.clipsToBounds=YES;
    [_leftButton setBackgroundImage:createImageWithColor([[UIColor greenColor] colorWithAlphaComponent:0.4]) forState:UIControlStateNormal];
    [_leftButton setBackgroundImage:createImageWithColor([[UIColor greenColor] colorWithAlphaComponent:1]) forState:UIControlStateSelected];
    [_leftButton setTitle:@"静音" forState:UIControlStateNormal];
    _leftButton.center=CGPointMake(CGRectGetWidth(self.view.bounds)/2-100, CGRectGetHeight(self.view.bounds)-25-20);
    [_leftButton addTarget:self action:@selector(toggleSpeaker:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_leftButton];
    
    UIButton* _tipsButton=[[UIButton alloc] initWithFrame:CGRectMake(0,CGRectGetHeight(self.view.bounds)-50-20-50,70, 50)];
    _tipsButton.layer.cornerRadius=25;
    _tipsButton.clipsToBounds=YES;
    [_tipsButton setTitle:@"" forState:UIControlStateNormal];
    _tipsButton.center=CGPointMake(CGRectGetWidth(self.view.bounds)/2-100, CGRectGetHeight(self.view.bounds)-25-20-50);
    [_tipsButton addTarget:self action:@selector(toggleTips:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_tipsButton];
    _tipsButton.alpha = 0.1f;
    _tipsButton.autoresizesSubviews = NO;
    
    UIButton* _rightButton=[[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds)-50-20, 70, 50)];
    _rightButton.layer.cornerRadius=25;
    _rightButton.clipsToBounds=YES;
    [_rightButton setBackgroundImage:createImageWithColor([[UIColor greenColor] colorWithAlphaComponent:0.4]) forState:UIControlStateNormal];
    [_rightButton setBackgroundImage:createImageWithColor([[UIColor greenColor] colorWithAlphaComponent:1]) forState:UIControlStateSelected];
    [_rightButton setTitle:@"摄像头" forState:UIControlStateNormal];
    _rightButton.center=CGPointMake(CGRectGetWidth(self.view.bounds)/2+100, CGRectGetHeight(self.view.bounds)-25-20);
    _closeButton.autoresizesSubviews=UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin;
    
    [_rightButton addTarget:self action:@selector(toggleCamera:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_rightButton];
    
    _cameraBtn = _rightButton;
}

-(void)InitAVSdK{

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self InitUI];
    _inBackGround = NO;
    NSError* error=nil;
    AVAudioSession *aSession = [AVAudioSession sharedInstance];
    [aSession setCategory:AVAudioSessionCategoryPlayback
              withOptions:AVAudioSessionCategoryOptionAllowBluetooth
                    error:&error];
    [aSession setMode:AVAudioSessionModeDefault error:&error];
    [aSession setActive: YES error: &error];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioInterruption:)  name:AVAudioSessionInterruptionNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(WillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    _identifierList = [[NSMutableArray alloc] initWithArray:nil];
    _srcTypeList = [[NSMutableArray alloc] initWithArray:nil];
    
    [self showTips:@"创建房间..."];
    
     QAVMultiParam*param = [[[QAVMultiParam alloc]init]autorelease];
     param.roomID = (UInt32)[UserConfig shareConfig].roomId;
     param.audioCategory = [UserConfig shareConfig].categoryNum;
    
    
    if([UserConfig shareConfig].authAudioSend &&
       [UserConfig shareConfig].authAudioRev &&
       [UserConfig shareConfig].authVideoSend &&
       [UserConfig shareConfig].authVideoRev)
    {
        param.authBitMap = QAV_AUTH_BITS_DEFUALT;
    }
    else
    {
        param.authBitMap = QAV_AUTH_BITS_CREATE_ROOM | QAV_AUTH_BITS_JOIN_ROOM | QAV_AUTH_BITS_RECV_SUB;
        
        if( [UserConfig shareConfig].authVideoSend )
            param.authBitMap |= QAV_AUTH_BITS_SEND_VIDEO;
        if( [UserConfig shareConfig].authVideoRev )
            param.authBitMap |= QAV_AUTH_BITS_RECV_VIDEO;
        if( [UserConfig shareConfig].authAudioSend )
            param.authBitMap|= QAV_AUTH_BITS_SEND_AUDIO;
        if( [UserConfig shareConfig].authAudioRev )
            param.authBitMap|= QAV_AUTH_BITS_RECV_AUDIO;
    }
    if ([UserConfig shareConfig].roomRole && [[UserConfig shareConfig].roomRole length] > 0)
        param.controlRole = [UserConfig shareConfig].roomRole;
    
     [[AVUtil sharedContext] enterRoom:param delegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)audioInterruption:(NSNotification*)notification
{
    //DDLogInfo(@"audioInterruption%@",notification.userInfo);
    NSDictionary *interuptionDict = notification.userInfo;
    NSNumber* interuptionType = [interuptionDict valueForKey:AVAudioSessionInterruptionTypeKey];
    if(interuptionType.intValue == AVAudioSessionInterruptionTypeBegan){

    }
    else if (interuptionType.intValue == AVAudioSessionInterruptionTypeEnded){
        NSError* error=nil;

    }
}
- (void)becomeActive:(NSNotification*)notification{

    if (![self isOtherAudioPlaying]) {
        [[AVAudioSession sharedInstance] setActive: YES error: nil];

    }
}

#pragma 视频输出
- (BOOL)enableVideoOuput:(BOOL)enable
{
    if (![AVUtil sharedContext].videoCtrl) {
        return NO;
    }
    
    if (enable) {
        if (videoOutputFile) {
            return YES;
        }
        NSString *fileName = @"new.yuv";
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docDir = [paths objectAtIndex:0];
        NSLog(@"写入地址为:%@",docDir);
        
        NSString *filePath = [docDir stringByAppendingPathComponent:fileName];
        
        videoOutputFile = fopen(filePath.UTF8String,  "wb+");
        
    }
    else
    {
        if(!videoOutputFile) return true;
        
        fclose(videoOutputFile);
        
        videoOutputFile = NULL;
    }
    
    return true;
}


-(void)didEnterBackground:(NSNotification*)notification{
//    if (_previewView)
//    [[AVUtil sharedContext].videoCtrl enableCamera:false complete:^(int result) {}];
    
    if (_imageView)
        [_imageView stopDisplay];

    _inBackGround = YES;
}

-(void)WillEnterForeground:(NSNotification*)notification{
//    if (_imageView)
//        [_imageView startDisplay];
    _inBackGround = NO;
}

-(BOOL)isOtherAudioPlaying{
    UInt32 otherAudioIsPlaying;
    UInt32 propertySize = sizeof (otherAudioIsPlaying);
    
    AudioSessionGetProperty (
                             kAudioSessionProperty_OtherAudioIsPlaying,
                             &propertySize,
                             &otherAudioIsPlaying
                             );
    
    return otherAudioIsPlaying;
}

-(void)showMembers:(id)sender
{
    MSDynamicsDrawerViewController *dynamicsDrawerViewController = (MSDynamicsDrawerViewController *)self.parentViewController;
    if ([dynamicsDrawerViewController isMemberOfClass:MSDynamicsDrawerViewController.class]) {
        [dynamicsDrawerViewController setPaneState:MSDynamicsDrawerPaneStateOpen inDirection:MSDynamicsDrawerDirectionLeft animated:YES allowUserInterruption:YES completion:nil];
    }
}
-(void)showSetting:(id)sender
{
    MSDynamicsDrawerViewController *dynamicsDrawerViewController = (MSDynamicsDrawerViewController *)self.parentViewController;
    if ([dynamicsDrawerViewController isMemberOfClass:MSDynamicsDrawerViewController.class]) {
        [dynamicsDrawerViewController setPaneState:MSDynamicsDrawerPaneStateOpen inDirection:MSDynamicsDrawerDirectionRight animated:YES allowUserInterruption:YES completion:nil];
    }
    
}
-(IBAction)leaveRoom:(id)sender
{
    [[AVUtil sharedContext].audioCtrl unregisterAudioDataCallbackAll];

    if (_imageView)
    {
        [_imageView destroyOpenGL];
        [_imageView stopDisplay];
        [_imageView removeFromSuperview];
        _imageView = nil;
    }
    _frameDispatcher.imageView = nil;
    
    if (_timerUpdateTips){
        [_timerUpdateTips invalidate];
        _timerUpdateTips = nil;
    }
    
    
    [[AVUtil sharedContext] exitRoom];
}

-(void) OnRefreshTips:(NSTimer*)timer{
    
    NSString*tips = [NSString stringWithFormat:@"%@\r%@\r%@",
                     [[AVUtil sharedContext].room getQualityTips],
                     [[AVUtil sharedContext].audioCtrl getQualityTips],
                     [[AVUtil sharedContext].videoCtrl getQualityTips]
                     ];
    
    [runningTipsView Show:tips parentView:self.view];
}

-(IBAction)toggleMic:(id)sender
{
    UIControl* control=sender;
    control.selected=!control.selected;

    [[AVUtil sharedContext].audioCtrl enableMic:!control.selected];
}


-(IBAction)toggleTips:(id)sender{
    //点击触发tips逻辑。
    if (_timerUpdateTips)
    {
        [runningTipsView hide];
        [_timerUpdateTips invalidate];
        _timerUpdateTips = nil;
    }
    else{
        
        
        
        NSString*tips = [NSString stringWithFormat:@"%@\r%@\r%@",
                         [[AVUtil sharedContext].room getQualityTips],
                         [[AVUtil sharedContext].audioCtrl getQualityTips],
                         [[AVUtil sharedContext].videoCtrl getQualityTips]
                         ];

        
        if ([runningTipsView ShowInCount:tips parentView:self.view])
        {
            _timerUpdateTips = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(OnRefreshTips:) userInfo:self repeats:YES];
        }
    }
}

-(IBAction)toggleSpeaker:(id)sender
{
    UIControl* control=sender;
    control.selected=!control.selected;
    
    [[AVUtil sharedContext].audioCtrl enableSpeaker:!control.selected];
}


//zhmark
-(IBAction)toggleCamera:(id)sender
{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        
        [AVUtil ShowMsg:@"相机没权限，请先打开相机权限"];
        return;
    }
    
    UIControl* control=sender;
    control.selected = !control.selected;
    
    BOOL isSelectd = control.selected;
    
    if(control.selected){
 
        //[self startPreview];
        [self showTips:@"打开摄像头..."];
    }else{
        [self closePreview];
        [self showTips:@"关闭摄像头..."];
    }
    
    BOOL bRet = [[AVUtil sharedContext].videoCtrl enableCamera:control.selected complete:^(int result){
        if (result==QAV_OK) {
            if (isSelectd)
                [self startPreview];
            
            [_memberCollectionView reloadData];
        }
        else{
            if (control.selected){
                [self closePreview];
            }
        }
        
        if(control.selected){
            [self hideTips:@"打开摄像头完成" afterDelay:0.1];
        }else{
            [self hideTips:@"关闭摄像头完成" afterDelay:0.1];
        }
    }];
    
//    if (!bRet){
//        if(control.selected){
//            [self hideTips:@"摄像头打开中..." afterDelay:0.5];
//        }else{
//            [self hideTips:@"摄像头关闭中..." afterDelay:0.5];
//        }
//    }
}

-(IBAction)switchCamera:(id)sender
{
    UIControl* control=sender;
    control.selected=!control.selected;
    
    [self showTips:@"切换摄像头..."];
    
    cameraPos pos = control.selected ? CameraPosFront : CameraPosBack;
    
    [[AVUtil sharedContext].videoCtrl switchCamera:pos complete:^(int result) {
        [self hideTips:@"切换摄像头完成" afterDelay:0.5];
    }];
}
-(IBAction)switchOutputMode:(id)sender
{
    UIControl* control=sender;
    control.selected=!control.selected;
    
    QAVOutputMode mode = control.selected ? QAVOUTPUTMODE_SPEAKER : QAVOUTPUTMODE_EARPHONE;
    [AVUtil sharedContext].audioCtrl.outputMode = mode;
}

#pragma mark remoteVideoDelegate
-(void)OnVideoPreview:(QAVVideoFrame*)frameData{
    if (!_inBackGround && ![_imageView isDisplay])
        [_imageView startDisplay];
    
    //临时先这么处理下，稍后再完善
    if(frameData.frameDesc.srcType == QAVVIDEO_SRC_TYPE_SCREEN)
    {
        int peerRotate = frameData.frameDesc.rotate;
        int selfRotate = 0;
        UIInterfaceOrientation currentOri=(UIInterfaceOrientation)[[UIDevice currentDevice] orientation];
        switch (currentOri) {
            case UIDeviceOrientationPortrait:
                selfRotate = 0;
                break;
            case UIDeviceOrientationLandscapeLeft:
                selfRotate = 1;
                break;
            case UIDeviceOrientationLandscapeRight:
                selfRotate = 3;
                break;
            case UIDeviceOrientationPortraitUpsideDown:
                selfRotate = 2;
                break;
            default:
                
                break;
        }
        frameData.frameDesc.rotate = selfRotate;//(selfRotate - peerRotate + 8) % 4;
    //NSLog(@"UIInterfaceOrientation currentOri %d, peerRotate %d selfRotate %d rotated %d.", (int)currentOri, peerRotate, selfRotate, frameData.frameDesc.rotate);
    }
    
    //yuv转rgb
    int width = frameData.frameDesc.width;
    int height = frameData.frameDesc.height;
    
    unsigned char *bgrData = (unsigned char *)malloc(width * height * 3);
    Mirror_YUV420SP_to_BGR24(frameData.data, width, height, bgrData, 0);
    
    
    
    //渲染远程画面
    AVFrameInfo *info = [[[AVFrameInfo alloc]init]autorelease];
    info.identifier = frameData.identifier;
    info.height = frameData.frameDesc.height;
    info.width = frameData.frameDesc.width;
    info.source_type = frameData.frameDesc.srcType;
    // data 需要copy一下
    info.data = [[[NSData alloc]initWithBytes:bgrData length:frameData.dataSize] autorelease];
    info.rotate = frameData.frameDesc.rotate;
    
    
    [_frameDispatcher dispatchVideoFrame:frameData isSubFrame:NO];
    
    //视频输出到文件示例
    BOOL isEnableRecord = [AVUtil isEnableRecord];
    if (isEnableRecord){
        // 只录制第一个大画面的视频
        BOOL isMain = NO;
        if (_identifierList && _identifierList.count > 0 && [_identifierList[0] isEqualToString:frameData.identifier])
            isMain = YES;
        
        if (!videoOutputFile)
            [self enableVideoOuput:isEnableRecord];
        
        if (videoOutputFile != NULL && isMain) {
            fwrite(frameData.data, 1, frameData.dataSize, videoOutputFile);
        }
    }
    else{
        if (videoOutputFile){
            [self enableVideoOuput:NO];
        }
    }
    
}

#pragma mark avRoomDelegate sdk回调
-(void)OnEnterRoomComplete:(int)result{
    if (result == QAV_OK){
        [self hideTips:@"创建房间成功" afterDelay:0.5];
        
        //设置
        if ([AVUtil sharedContext].videoCtrl){
            [[AVUtil sharedContext].videoCtrl setRemoteVideoDelegate:self];
            [[AVUtil sharedContext].videoCtrl setScreenVideoDelegate:self];
            
        }
        
    }
    else{
        [self hideTips:@"创建房间成功" afterDelay:0.5];
    }
    

}


-(void)OnExitRoomComplete:(int)result{
    if (_timerUpdateTips){
        [_timerUpdateTips invalidate];
        _timerUpdateTips = nil;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[AVUtil sharedContext] stopContext:^(QAVResult result) {
            [self dismissViewControllerAnimated:YES completion:^{
                [_memberCollectionView release];
                [_previewView release];
                [_model release];
                [self.roomMemberController release];
                [self.roomConfigController unInit];
                
                [[NSNotificationCenter defaultCenter] removeObserver:self];
//                NSLog(@"NMultiVideoViewController dealloc %x", (iMirror_YUV420SP_to_BGR24nt)self);
                //[QAVContext DestroyContext:[AVUtil sharedContext]];
                [AVUtil destroyShardContext];
            }];
        }];
    });
}

-(void)OnEndpointsUpdateInfo:(QAVUpdateEvent)eventID endpointlist:(NSArray*)endpoints{
    switch (eventID) {
        case QAV_EVENT_ID_ENDPOINT_HAS_CAMERA_VIDEO:
        case QAV_EVENT_ID_ENDPOINT_NO_CAMERA_VIDEO:
        case QAV_EVENT_ID_ENDPOINT_HAS_AUDIO:
        case QAV_EVENT_ID_ENDPOINT_NO_AUDIO:
        {
            [_model updateAudioAndCameraMember:endpoints];
            [_memberCollectionView reloadData];
        }
            break;
        case QAV_EVENT_ID_ENDPOINT_HAS_SCREEN_VIDEO:
        case QAV_EVENT_ID_ENDPOINT_NO_SCREEN_VIDEO:
        {
            [_model updateScreenMember:endpoints];
            [_memberCollectionView reloadData];
        }
            break;
        case QAV_EVENT_ID_ENDPOINT_EXIT:
        {
            [_model updateAudioAndCameraMember:endpoints];
            [_memberCollectionView reloadData];
            [_model updateScreenMember:endpoints];
            [_memberCollectionView reloadData];
        }
            break;
        default:
            break;
    }
    
    switch (eventID) {
            
        case QAV_EVENT_ID_ENDPOINT_NO_CAMERA_VIDEO:
        case QAV_EVENT_ID_ENDPOINT_NO_SCREEN_VIDEO:
        {
            int srcType = eventID == QAV_EVENT_ID_ENDPOINT_NO_CAMERA_VIDEO ? QAVVIDEO_SRC_TYPE_CAMERA : QAVVIDEO_SRC_TYPE_SCREEN;
        
            for (QAVEndpoint* endpoint in endpoints)
            {
                for(int i = 0; i < _identifierList.count; i++)
                {
                    NSString *identifier = [_identifierList objectAtIndex:i];
                    NSNumber *srcTypeTmp = [_srcTypeList objectAtIndex:(NSInteger)i];
                    int requestedSrcType = [srcTypeTmp intValue];
                    
                    if ([identifier compare:endpoint.identifier] == NSOrderedSame && requestedSrcType == srcType)
                    {
                        [_identifierList removeObjectAtIndex:i];
                        [_srcTypeList removeObjectAtIndex:i];
                        NSString *renderKey = [NSString stringWithFormat:@"%@%d", endpoint.identifier, (int)srcType];
                        [self releaseRender:renderKey];
                [self updateRender];
                        break;
                    }
                }
            }
        }
            break;
        case QAV_EVENT_ID_ENDPOINT_EXIT:
        {
            for (QAVEndpoint* endpoint in endpoints)
            {
                for(int i = 0; i < _identifierList.count; i++)
                {
                    NSString *identifier = [_identifierList objectAtIndex:i];
                    NSNumber *srcTypeTmp = [_srcTypeList objectAtIndex:(NSInteger)i];
                    int requestedSrcType = [srcTypeTmp intValue];
                    
                    if ([identifier compare:endpoint.identifier] == NSOrderedSame && requestedSrcType == QAVVIDEO_SRC_TYPE_CAMERA)
                    {
                        NSString *renderKey = [NSString stringWithFormat:@"%@%d", endpoint.identifier, (int)QAVVIDEO_SRC_TYPE_CAMERA];
                        [self releaseRender:renderKey];
                        [self updateRender];
                    }
                    else if ([identifier compare:endpoint.identifier] == NSOrderedSame && requestedSrcType == QAVVIDEO_SRC_TYPE_SCREEN)
                    {
                        NSString *renderKey = [NSString stringWithFormat:@"%@%d", endpoint.identifier, (int)QAVVIDEO_SRC_TYPE_SCREEN];
                        [self releaseRender:renderKey];
                        [self updateRender];
                    }
                }
            }
            
            for (QAVEndpoint* endpoint in endpoints)
            {
                for(int i = 0; i < _identifierList.count; i++)
                {
                    NSString *identifier = [_identifierList objectAtIndex:i];
                    if ([identifier compare:endpoint.identifier] == NSOrderedSame)
                    {
                        [_identifierList removeObjectAtIndex:i];
                        [_srcTypeList removeObjectAtIndex:i];
                        i--;
                    }
                }
            }

            
        }
            break;
        default:
            break;
    }

    if (self.roomMemberController){
        self.roomMemberController.model = _model;
    }
}
-(void)OnChangeAuthority:(int)ret{
    if (ret == QAV_OK)
        [AVUtil ShowMsg:@"修改权限成功"];
    else
        [AVUtil ShowMsg:@"修改权限失败"];
}
#pragma mark UICollectionView Delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _model.endpoints.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UserHeadCell* cell=[collectionView dequeueReusableCellWithReuseIdentifier:UserHeadCellID forIndexPath:indexPath];
    
    MemberData* userInfo=[_model.endpoints objectAtIndex:indexPath.item];
    if (userInfo) {
        cell.headView.image=[UIImage imageNamed: [NSString stringWithFormat:@"head"]];
        cell.nameLabel.text=userInfo.identifier;
        if ([userInfo.identifier isEqualToString:[AVUtil sharedContext].Config.identifier]) {
            cell.nameLabel.text=@"self";
        }
        cell.nameLabel.textColor = [UIColor grayColor];
		if(userInfo.isCameraVideo) cell.endpointStateTypes = EndpointStateTypeCamera;
        else if(userInfo.isScreenVideo) cell.endpointStateTypes = EndpointStateTypeScreen;
		else if(userInfo.isAudio) cell.endpointStateTypes = EndpointStateTypeAudio;
		else cell.endpointStateTypes = EndpointStateTypeNull;
        
    }
    
    return cell;
}
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    MemberData* userInfo=[_model.endpoints objectAtIndex:indexPath.item];
    if ([userInfo.identifier isEqualToString:[AVUtil sharedContext].Config.identifier]) {//是自己，不允许点击
        return NO;
    }
    
    UserHeadCell* cell=(UserHeadCell*)[collectionView cellForItemAtIndexPath:indexPath];
    if ([cell isMemberOfClass:[UserHeadCell class]]) {
        return  cell.endpointStateTypes == EndpointStateTypeCamera || cell.endpointStateTypes == EndpointStateTypeScreen;
    }
    
    return NO;
}

-(void)releaseRender:(NSString *)identifier{
    if (_imageView != nil) {
        [_imageView removeSubviewForKey:identifier];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    UserHeadCell* cell=(UserHeadCell*)[collectionView cellForItemAtIndexPath:indexPath];
    MemberData* userInfo=[_model.endpoints objectAtIndex:indexPath.item];
    int requestingSrcType = QAVVIDEO_SRC_TYPE_NONE;
    if(userInfo.isCameraVideo)
    {
        requestingSrcType = QAVVIDEO_SRC_TYPE_CAMERA;
    }
    else if(userInfo.isScreenVideo)
    {
        requestingSrcType = QAVVIDEO_SRC_TYPE_SCREEN;
    }
    else
    {
        return;
    }
    
    int requestedSrcType = QAVVIDEO_SRC_TYPE_NONE;
    if ([cell isMemberOfClass:[UserHeadCell class]]) {
        
        int index = 0;
        for (NSString *identifier in _identifierList) {
            NSNumber *srcTypeTmp = [_srcTypeList objectAtIndex:(NSInteger)index];
            requestedSrcType = [srcTypeTmp intValue];
            
            if ([identifier compare:userInfo.identifier] == NSOrderedSame && requestedSrcType == requestingSrcType) {
                break;
            }
            index++;
        }
        
        //update view list
        if (_identifierList.count  > 0 && index < _identifierList.count)
        {
            [_identifierList removeObjectAtIndex:index];
            [_srcTypeList removeObjectAtIndex:index];
            NSString *renderKey = [NSString stringWithFormat:@"%@%d", userInfo.identifier, requestedSrcType];
            [self releaseRender:renderKey];
        }
        else
        {
            [_identifierList addObject:userInfo.identifier];
            NSNumber *requestingSrcTypeObj = [NSNumber numberWithInt: requestingSrcType];
            [_srcTypeList addObject:requestingSrcTypeObj];
        }
        
        //request view
        if (_identifierList.count  > 0 ) {
            [QAVEndpoint requsetViewList:[AVUtil sharedContext] identifierList:_identifierList srcTypeList:_srcTypeList ret:^(QAVResult result) {
                if (result != QAV_OK){
                    [AVUtil ShowMsg:@"请求画面失败"];
                }
           }];
        }
        else
        {
            [QAVEndpoint cancelAllview:[AVUtil sharedContext] ret:^(QAVResult result) {

            }];
        }
        
        //update render
        [self updateRender];
    }
}

-(void)startPreview{
    if (!_previewView){
        //zhmark设置预览图
        _previewView=[[PreviewView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.bounds)- 120, CGRectGetHeight(self.view.bounds)-120-205, 120, 120)];
        AVCaptureVideoPreviewLayer* previewLayer = [[AVUtil sharedContext].videoCtrl getPreviewLayer];
        [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        _previewView.previewLayer=previewLayer;
        [self.view addSubview:_previewView];
        _previewView.hidden = NO;
        
        UITapGestureRecognizer* singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapPreview:)];
        singleRecognizer.numberOfTapsRequired = 1; // 单击
        [_previewView addGestureRecognizer:singleRecognizer];
        
        // 双击的 Recognizer
        UITapGestureRecognizer* doubleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapPreview:)];
        doubleRecognizer.numberOfTouchesRequired = 2; // 双击
        [_previewView addGestureRecognizer:doubleRecognizer];
    }
}

-(void)zoomPreview:(float)rate{
    // 以下是获取AVCaptureSession演示摄像头缩放的。iphone4s暂时不支持。
    if ([AVUtil isIphone4S:self])
        return;
    //to do
    AVCaptureSession*session = [[AVUtil sharedContext].videoCtrl getCaptureSession];
    if (session){
        for( AVCaptureDeviceInput *input in session.inputs){
            
            NSError* error = nil;
            AVCaptureDevice*device = input.device;
            
            if ( ![device hasMediaType:AVMediaTypeVideo] )
                continue;
            
            BOOL ret = [device lockForConfiguration:&error];
            if (error){
                
            }
            float factor = device.videoZoomFactor;
            factor += rate;
            if (factor <= 1.0f)
                factor = 1.0f;
            if (factor >= 4.0f)
                factor = 4.0f;
            [input.device rampToVideoZoomFactor:factor withRate:4.0f];
            CGPoint point = device.focusPointOfInterest;
            [device unlockForConfiguration];
            break;
        }
    }
}

-(void)handleSingleTapPreview:(UITapGestureRecognizer*)gesture{
   [ self zoomPreview:1.0f];
    return;
}

-(void)handleDoubleTapPreview:(UITapGestureRecognizer*)gesture{
   [ self zoomPreview:-1.0f];
    return;
}

-(void)closePreview{
    if (_previewView){
        [_previewView removeFromSuperview];
        [_previewView release];
        _previewView = nil;
    }
}

-(void)OnPreviewStart{
    [self startPreview];
    
    if (_previewView)
        _previewView.hidden = NO;
    
    if (!_cameraBtn.selected)
        _cameraBtn.selected = YES;
}

-(void)updateRender{
    
    if (_identifierList.count  > 0 ) {
        _imageView.hidden = NO;
        int index = 0;
        for (NSString *identifier in _identifierList) {
            NSNumber *srcTypeTmp = [_srcTypeList objectAtIndex:(NSInteger)index];
            int requestedSrcType = [srcTypeTmp intValue];
            
            NSString *renderKey = [NSString stringWithFormat:@"%@%d", identifier, requestedSrcType];
            
            //get rect by index
            CGRect rect = [self getRecvByIndex:index];
            
            AVGLRenderView * glView = [_imageView getSubviewForKey:renderKey];
            if (glView == nil) {
                glView = [[AVGLRenderView alloc] initWithFrame:rect];
                [_imageView addSubview:glView forKey:renderKey];

                [glView setHasBlackEdge:NO];
                
                glView.nickView.hidden = YES;
                [glView setBoundsWithWidth:0];
                [glView setDisplayBlock:NO];
                
                [glView setCuttingEnable:YES];
            }
            else {
                [glView setFrame:rect];
            }
            
            index++;
        }
      
    }
    else
    {
        _imageView.hidden = YES;
    }
   
}

-(CGRect)getRecvByIndex:(int)index {
    if (index == 0) {
        return CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    }
    else {
        return CGRectMake(5 + ((index -1) * (GROUP_SMALL_VIEW_WIDTH + 10)), CGRectGetHeight(self.view.bounds)-160,GROUP_SMALL_VIEW_WIDTH,GROUP_SMALL_VIEW_HEIGHT);
    }
}


@end
