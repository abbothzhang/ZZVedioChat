//
//  RoomConfigViewController.m
//  QAVSDKDemo_P
//
//  Created by TOBINCHEN on 14-11-19.
//  Copyright (c) 2014年 TOBINCHEN. All rights reserved.
//

#import "MultiRoomConfigViewController.h"
#import "AVMultiManager.h"
#import "MSDynamicsDrawerViewController.h"
#import "UserConfig.h"

@interface MultiRoomConfigViewController (){
    FILE*_videoFile;
    BOOL _bExitVideo;
    UInt8* _buf;
}
@end

@implementation MultiRoomConfigViewController
-(void)dealloc{
    int a =11;
}

-(id)init{
    return [super init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.bounces=NO;
    _videoFile = NULL;
    _bExitVideo = YES;
    _buf = NULL;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)playVideoWithVideo:(NSString*)videoName AndFrame:(NSString*)frame
{
    [[AVMultiManager shareManager] enableExternalCapture];
    
    _bExitVideo = NO;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self runImportVideo:frame file:videoName];
    });
}

- (void)changeAuthority:(NSString*)authPirvateMap;
{
    if(authPirvateMap != nil)
    {
        [[AVMultiManager shareManager] changeAuthority:authPirvateMap];
    }
}

-(void)runImportVideo:(NSString*)frame file:(NSString*)file{
    
    if (_videoFile){
        fclose(_videoFile);
        _videoFile = NULL;
    }
    
    if (_buf)
        free(_buf);
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    NSLog(@"地址为:%@",docDir);
    
    NSString *filePath = [docDir stringByAppendingPathComponent:file];
    
    _videoFile = fopen(filePath.UTF8String, ("rb"));
    
    if (!_videoFile)
        return;
    
    int width = [[[frame componentsSeparatedByString:@"*"] objectAtIndex:0]intValue];
    int height = [[[frame componentsSeparatedByString:@"*"] objectAtIndex:1]intValue];
    
    int size = width * height * 3 / 2;
    
    UInt8*temp = (UInt8*)malloc(size);
    memset(temp, 0, size);
    
    _buf = temp;
    
    while(!_bExitVideo){
        
        if( size != fread((void*)temp , 1, size, _videoFile) )
        {
            fseek(_videoFile, 0, SEEK_SET);
            continue;
        }
        
        if (![[AVMultiManager shareManager]captureVideo:width height:height data:temp size:size])
            break;
        
        usleep(66666);
    }
    
    free(temp);
    
    fclose(_videoFile);
    _videoFile = NULL;
    _bExitVideo = YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 9;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section==0) {
        return @"房间设置";
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellId"];
    
    if (!cell) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellId"];
    }
    cell.textLabel.textAlignment=NSTextAlignmentRight;
    //cell.selectionStyle=UITableViewCellSelectionStyleNone;
    
    switch (indexPath.row) {
        case 0:
        {
            cell.textLabel.text=@"切摄像头";
            if ([[AVMultiManager shareManager] CameraCount]<2) {
                cell.selectionStyle=UITableViewCellSelectionStyleNone;
                cell.textLabel.textColor=[UIColor grayColor];
            }
            break;
        }
            
        case 1:
        {
            cell.textLabel.text=@"切外放";
            
        }
            break;
        case 2:
        {
            cell.textLabel.text=@"禁麦";
            cell.accessoryType=UITableViewCellAccessoryCheckmark;
        }
            break;
        case 3:
        {
            cell.textLabel.text=@"音频输入";
        }
            break;
        case 4:
        {
            cell.textLabel.text=@"音频录制";
        }
            break;
        case 5:
        {
            cell.textLabel.text=@"输入视频流";
        }
            break;
        case 6:
        {
            cell.textLabel.text = @"录制视频";
        }
            break;
        case 7:
        {
            cell.textLabel.text = @"修改权限";
        }
            break;
        case 8:
        {
            cell.textLabel.text = @"监听自己声音";
        }
            break;
        default:
            break;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    BOOL selected=NO;
    if(cell.accessoryType==UITableViewCellAccessoryCheckmark){
        selected=NO;
        cell.accessoryType=UITableViewCellAccessoryNone;
    }else{
        selected=YES;
        cell.accessoryType=UITableViewCellAccessoryCheckmark;
    }
    
    switch (indexPath.row) {
        case 0:
        {
            if ([[AVMultiManager shareManager] CameraCount]<2) {
                cell.accessoryType=UITableViewCellAccessoryNone;
            }else{
                [[AVMultiManager shareManager] selectCamera:selected completion:^(NSInteger cameraId, AVResult result) {
                    
                }];
            }

        }
            break;
        case 1:
        {
            [[AVMultiManager shareManager] changeSpeakerMode:selected?1:0];
        }
            break;
        case 2:
        {
            [[AVMultiManager shareManager] enableMic:!selected];
            
        }
            break;
        case 3:
        {
            bool ret = [[AVMultiManager shareManager] enableInputAudio:selected];
            if(!ret)
            {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
            break;
        case 4:
        {
            bool ret = [[AVMultiManager shareManager] enableOutputAudio:selected];
            if(!ret)
            {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
            break;
            
        case 5:
        {
            videoChoosingView = [[[VideoChoosingViewController alloc]init]autorelease];
            videoChoosingView.chooseDelegate = self;
            UINavigationController* nav=[[[UINavigationController alloc] initWithRootViewController:videoChoosingView] autorelease];
            
            [self presentViewController:nav animated:YES completion:nil];
        }
            break;
        
        case 6:
        {
            bool ret = [[AVMultiManager shareManager] enableVideoInput:selected];
            if(!ret)
            {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
            break;
        case 7:
        {
            changeAuthirtyView = [[[ChangeAuthorityController alloc]init]autorelease];
            changeAuthirtyView.changeDelegate = self;
            UINavigationController* nav=[[[UINavigationController alloc] initWithRootViewController:changeAuthirtyView] autorelease];
            
            [self presentViewController:nav animated:YES completion:nil];
            //if(!ret)
            {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
            break;
            
        case 8:{
            [[AVMultiManager shareManager] enableLoopBack:selected];
        }
            break;
        default:
            break;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    MSDynamicsDrawerViewController *dynamicsDrawerViewController = (MSDynamicsDrawerViewController *)self.parentViewController;
    [dynamicsDrawerViewController setPaneState:MSDynamicsDrawerPaneStateClosed inDirection:MSDynamicsDrawerDirectionRight animated:YES allowUserInterruption:YES completion:^{
        
    }];
}

- (nullable NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 8 && [UserConfig shareConfig].categoryNum !=2 ){
        return nil;
    }
    return indexPath;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 8){
        if ([UserConfig shareConfig].categoryNum != 2) {
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            cell.textLabel.textColor=[UIColor grayColor];
        }
    }
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
