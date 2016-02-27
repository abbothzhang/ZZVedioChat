//
//  AVUtilController.m
//  QAVSDKDemo
//
//  Created by xianhuanlin on 15/12/2.

//

#import "AVUtilController.h"
#import "AVUtil.h"
char*buf = NULL;
NSInteger len = 0;

@interface AVUtilController ()

@end

@implementation netStreamState

-(void)openFile:(NSString*)fileName{
    if (self.file)
        fclose(self.file);
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    docDir = [docDir stringByAppendingString:@"/"];
    NSString*fullPath = [docDir stringByAppendingString:fileName];
    
    self.file = fopen(fullPath.UTF8String, "wb+");
}

-(void)dealloc{
    if (self.file){
        fclose(self.file);
    }
    
    [super dealloc];
}

@end

@implementation audioCallbackHandler

-(void)dealloc{
    if (self.file){
        fclose(self.file);
    }
    
    [self.dicNetStream removeAllObjects];
    [super dealloc];
}

-(void)openFile:(NSString*)file flag:(NSString*)flag{
    if (self.file)
        fclose(self.file);
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    docDir = [docDir stringByAppendingString:@"/"];
    NSString*fullPath = [docDir stringByAppendingString:file];
    
    self.file = fopen(fullPath.UTF8String, flag.UTF8String);
    self.fileName = file;
}

-(void)closeNetStreamFile{
    
}

@end

@implementation AVUtilController

-(void)initAudioSetting{
    _lock = [[NSLock alloc]init];
    
    [[AVUtil sharedContext].audioCtrl setAudioDataEventDelegate:self];
    
    g_audioDdataTypes = [[NSArray alloc]initWithObjects:@"麦克风输出",@"发送混音输入",@"发送输出",@"扬声器混音输入",@"扬声器输出",@"远端音频输出",nil];
    g_audioDataSampleRates = [[NSArray alloc]initWithObjects:@"8000",@"16000",@"32000",@"44100",@"48000",nil];
    g_audioDataChannelNums = [[NSArray alloc]initWithObjects:@"1",@"2",nil];
    g_dataSources = [[NSArray alloc]initWithObjects:g_audioDdataTypes,g_audioDataSampleRates,g_audioDataChannelNums,nil];
    
    NSArray*array = @[self.pickChannels, self.pickSamples, self.pickTypes];
    for (UIPickerView*view in array){
        [view setDelegate:self];
        [view setDataSource:self];
    }
    
    _arraySwitchs = [[NSArray alloc]initWithObjects:_switchMicOuput, _switchMixInput,_switchSendOutput,_switchSpeakerInput,_switchSpeakerOut,_switchRemoteAudioOut,nil];

    for (NSInteger n = 0; n < _arraySwitchs.count; n++){
        UISwitch*swi = (UISwitch*)_arraySwitchs[n];
        swi.tag = n;
        [swi addTarget:self action:@selector(OnSwitchChange:) forControlEvents:UIControlEventValueChanged];
    }
    
    _dicRunningState = [NSMutableDictionary new];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self pickerView:_pickTypes didSelectRow:0 inComponent:0];
    });

}

-(IBAction)OnSwitchChange:(id)sender{
    for (UISwitch*swi in _arraySwitchs) {
        if (swi == sender){
            QAVAudioDataSourceType type = (swi.tag);
            NSString*key = [NSString stringWithFormat:@"%ld", (long)type];
            if ([swi isOn]){
                audioCallbackHandler*state = [_dicRunningState objectForKey:key];
                if (state){
                    continue;
                }
                else{
                    state = [[[audioCallbackHandler alloc]init]autorelease];
                    state.dicNetStream = [NSMutableDictionary new];
                    //struct QAVAudioFrameDesc framedesc = [[AVUtil sharedContext].audioCtrl GetAudioDataFormat:type];
                    //float vol = [[AVUtil sharedContext].audioCtrl GetAudioDataVolume:type];
                    
                    //struct auidoTransmitInfo info;
//                    info.channel = framedesc.ChannelNum;
//                    info.sampleRate = framedesc.SampleRate;
//                    info.volume = vol;
//                    
//                    state.transInfo = info;
                    
                    [_dicRunningState setObject:state forKey:key];
                }
                
                if (type == QAVAudioDataSource_MixToSend || type == QAVAudioDataSource_MixToPlay){
                    [self enableMixInput:YES type:type];
                }
                else{
                    [self enableAudioOutput:YES type:type];
                }
                
            }
            else{
                audioCallbackHandler*state = [_dicRunningState objectForKey:key];
                if (state){
                    //[_dicRunningState removeObjectForKey:key];
                    if (type == QAVAudioDataSource_MixToSend || type == QAVAudioDataSource_MixToPlay){
                        [self enableMixInput:NO type:type];
                    }
                    else{
                        [self enableAudioOutput:NO type:type];
                    }
                }
            }
            break;
            
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:self action:@selector(onReturn)];
    //UIBarButtonItem *rightButton = [[UIBarButtonItem alloc]initWithTitle:@"保存" style:UIBarButtonItemStyleDone target:self action:@selector(OnSave)];
    self.navigationItem.leftBarButtonItem = backButton;
    //self.navigationItem.rightBarButtonItem = rightButton;

    [self initAudioSetting];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

#pragma mark - Table view data source

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

//
// Override to support conditional editing of the table view.
//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
//     Return NO if you do not want the specified item to be editable.
//    return YES;
//}
//

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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1)
        return 80.0f;
    
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if (pickerView.tag > 0 && g_dataSources && g_dataSources.count > 0){
       NSInteger idnex = pickerView.tag - 1;
       NSArray*dataSource =[g_dataSources objectAtIndex:idnex];
        return dataSource ? dataSource.count : 0;
    }
    
    return 0;
}
- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if (pickerView.tag == 0)
        return nil;
    
    if (!g_dataSources || g_dataSources.count == 0)
        return nil;
    
    NSInteger index = pickerView.tag - 1;
    NSArray*dataSource = [g_dataSources objectAtIndex:index];
    return dataSource[row];
    
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if (pickerView != _pickTypes)
        return;
    
//    NSString*key = [NSString stringWithFormat:@"%ld", row];
    
//    audioCallbackHandler*state = [_dicRunningState objectForKey:key];
//    if (!state){
//        return;
//    }
//    else{
    
        struct QAVAudioFrameDesc framedesc = [[AVUtil sharedContext].audioCtrl getAudioDataFormat:(QAVAudioDataSourceType)row];
        
        NSInteger channel = framedesc.ChannelNum;
        NSInteger sampleRate = framedesc.SampleRate;
        NSInteger volume = [[AVUtil sharedContext].audioCtrl getAudioDataVolume:(QAVAudioDataSourceType)row];
        
        for (int n = 0; n < g_audioDataChannelNums.count; n++) {
            if ([g_audioDataChannelNums[n] integerValue] == channel){
                [_pickChannels selectRow:n inComponent:0 animated:NO];
                break;
            }
        }
        
        for (int n = 0; n < g_audioDataSampleRates.count; n++) {
            if ([g_audioDataSampleRates[n] integerValue] == sampleRate){
                [_pickSamples selectRow:n inComponent:0 animated:NO];
                break;
            }
        }
        
        [_sliderVolume setValue:volume animated:NO];
        
  //  }
    
    
}
-(void)onReturn{
    [self dismissViewControllerAnimated:YES completion:^{
        //
    }];
}

-(IBAction)OnSave:(id)sender{
    
    NSInteger selectType = [_pickTypes selectedRowInComponent:0];
    NSString*key = [NSString stringWithFormat:@"%ld", selectType];
    audioCallbackHandler*state = [_dicRunningState objectForKey:key];
    if (state){
        NSInteger sel = [_pickChannels selectedRowInComponent:0];
        NSInteger channel = [g_audioDataChannelNums[sel] integerValue];
        
        sel = [_pickSamples selectedRowInComponent:0];
        NSInteger sample = [g_audioDataSampleRates[sel] integerValue];

        float volume = [_sliderVolume value];
        
        //struct auidoTransmitInfo info = {channel,sample, volume};
        //state.transInfo = info;
        
        struct QAVAudioFrameDesc desc = {sample, channel};
        
        [[AVUtil sharedContext].audioCtrl setAudioDataFormat:(QAVAudioDataSourceType)selectType desc:desc];
        [[AVUtil sharedContext].audioCtrl setAudioDataVolume:(QAVAudioDataSourceType)selectType volume:volume];

        struct QAVAudioFrameDesc framedesc = [[AVUtil sharedContext].audioCtrl getAudioDataFormat:selectType];
        
        if (framedesc.ChannelNum != channel || framedesc.SampleRate != sample){
            [AVUtil ShowMsg:@"设置音频参数失败"];
            
            for (int n = 0; n < g_audioDataSampleRates.count; n++) {
                if ([g_audioDataSampleRates[n] integerValue] == framedesc.SampleRate){
                    [_pickSamples selectRow:n inComponent:0 animated:NO];
                    break;
                }
            }
            
            for (int n = 0; n < g_audioDataChannelNums.count; n++) {
                if ([g_audioDataChannelNums[n] integerValue] == framedesc.ChannelNum){
                    [_pickChannels selectRow:n inComponent:0 animated:NO];
                    break;
                }
            }
            
            float vol = [[AVUtil sharedContext].audioCtrl getAudioDataVolume:(QAVAudioDataSourceType)selectType];
            [_sliderVolume setValue:vol];
        }
        else{
            [AVUtil ShowMsg:@"设置音频参数成功"];
        }
 
    }

//    [self dismissViewControllerAnimated:YES completion:^{
//
//    }];
}



-(void)enableMixInput:(BOOL)isEnable type:(QAVAudioDataSourceType)type{
    NSString*key = [NSString stringWithFormat:@"%ld", type];
    audioCallbackHandler*handler = [_dicRunningState objectForKey:key];
    
    if (isEnable){
        if (type == QAVAudioDataSource_MixToPlay){
            if (_textSpeakerInput.text.length == 0){
                [AVUtil ShowMsg:@"扬声器混音输入文件没有文件名"];
                return;
            }
            
            if (handler){
                [handler openFile:_textSpeakerInput.text flag:@"rb"];
                [[AVUtil sharedContext].audioCtrl registerAudioDataCallback:type];
                int sampleRate = 0, channelNum = 0, ret = 0;
                ret = sscanf(handler.fileName.UTF8String,_textSpeakerInput.text.UTF8String, &sampleRate, &channelNum);
                struct QAVAudioFrameDesc desc = {sampleRate, channelNum};
                [[AVUtil sharedContext].audioCtrl setAudioDataFormat:type desc:desc];
                struct auidoTransmitInfo info = {channelNum, sampleRate,0};
                
                handler.transInfo = info;
            }
        }
        else if (type == QAVAudioDataSource_MixToSend) {
            if (_textMixInput.text.length == 0){
                [AVUtil ShowMsg:@"发送混音输入文件没有文件名"];
                return;
            }
            
            if (handler){
                [handler openFile:_textMixInput.text flag:@"rb"];
                [[AVUtil sharedContext].audioCtrl registerAudioDataCallback:type];
                int sampleRate = 0, channelNum = 0, ret = 0;
                ret = sscanf(handler.fileName.UTF8String,_textMixInput.text.UTF8String, &sampleRate, &channelNum);
                struct QAVAudioFrameDesc desc = {sampleRate, channelNum,16};
                [[AVUtil sharedContext].audioCtrl setAudioDataFormat:type desc:desc];
                
                struct auidoTransmitInfo info = {channelNum, sampleRate,0};
                
                handler.transInfo = info;
            }
        }
    }
    else{
        [_dicRunningState removeObjectForKey:key];
        [[AVUtil sharedContext].audioCtrl unregisterAudioDataCallback:type];
    }
    
  
}

-(void)enableAudioOutput:(BOOL)isEnable type:(QAVAudioDataSourceType)type{
    NSString*key = [NSString stringWithFormat:@"%ld", type];
    //audioCallbackHandler*handler = [_dicRunningState objectForKey:key];
    
    if (isEnable){
        [[AVUtil sharedContext].audioCtrl registerAudioDataCallback:type];
    }
    else{
        [_dicRunningState removeObjectForKey:key];
        [[AVUtil sharedContext].audioCtrl unregisterAudioDataCallback:type];
    }

}

-(void)reset{
    [_dicRunningState removeAllObjects];
    for (UISwitch *swi in _arraySwitchs){
        [swi setOn:NO];
    }
}

- (void)dealloc {
    
    [_pickTypes release];
    [_pickSamples release];
    [_pickChannels release];
    [g_dataSources release];
    [_switchMicOuput release];
    [_switchSendOutput release];
    [_switchSpeakerOut release];
    [_switchRemoteAudioOut release];
    [_switchMixInput release];
    [_switchSpeakerInput release];
    [_switchTransmit release];
    [_sliderVolume release];
    [_textMixInput release];
    [_textSpeakerInput release];
    
    [super dealloc];
}

-(NSString*)getTypeString:(QAVAudioDataSourceType)type{
    NSArray * array = @[@"Mic",@"MixToSend",@"Send",@"MixToPlay",@"Play",@"NetStream"];

    return array[type];
}

-(void)writeNetStream:(QAVAudioFrame*)audioFrame{
    if (audioFrame.identifier.length == 0)
        return;
    
    NSString*key = [NSString stringWithFormat:@"%ld", QAVAudioDataSource_NetStream];
    audioCallbackHandler*handler = _dicRunningState[key];
    if (handler){
        if (handler.transInfo.channel != audioFrame.desc.ChannelNum || handler.transInfo.sampleRate != audioFrame.desc.SampleRate){
            [handler.dicNetStream removeAllObjects];
            
            struct auidoTransmitInfo info;
            info.channel = audioFrame.desc.ChannelNum;
            info.sampleRate = audioFrame.desc.SampleRate;
            handler.transInfo = info;
        }

        FILE*fileToWrite = NULL;
        NSString*fileName = [NSString stringWithFormat:@"%@-%@-%ld_%ld_%ld.pcm",@"NetStream",audioFrame.identifier,handler.transInfo.channel,(long)handler.transInfo.sampleRate, time(0)];
        NSString*iden = audioFrame.identifier;
        netStreamState*netState = [handler.dicNetStream objectForKey:iden];
        
        if (!netState){
            netState = [[[netStreamState alloc]init]autorelease];
            netState.identifier = iden;
            [netState openFile:fileName];
            [handler.dicNetStream setObject:netState forKey:iden];
            
            fileToWrite = netState.file;
        }
        
        else if (netState){
            fileToWrite = netState.file;
        }
        
        if (fileToWrite){
            fwrite(audioFrame.buffer.bytes, 1, audioFrame.buffer.length, fileToWrite);
        }

    }
}

#pragma mark QAVAUDIACALLBACK
-(QAVResult)audioDataComes:(QAVAudioFrame*)audioFrame type:(QAVAudioDataSourceType)type{
    NSString*key = [NSString stringWithFormat:@"%ld", type];
    NSString*typeString = [self getTypeString:type];
    audioCallbackHandler*handler = _dicRunningState[key];
    
    if (type == QAVAudioDataSource_NetStream){
        if (handler){
            [self writeNetStream:audioFrame];
        }
        return QAV_OK;
    }
    else{
        if (handler){
            if (handler.transInfo.channel != audioFrame.desc.ChannelNum || handler.transInfo.sampleRate != audioFrame.desc.SampleRate){
                struct auidoTransmitInfo info;
                info.channel = audioFrame.desc.ChannelNum;
                info.sampleRate = audioFrame.desc.SampleRate;
                handler.transInfo = info;
 
                NSString*fileName = [NSString stringWithFormat:@"%@-%ld_%ld_%ld.pcm",typeString,handler.transInfo.channel,(long)handler.transInfo.sampleRate, time(0)];
                [handler openFile:fileName flag:@"wb+"];
            }
            
            if (handler.file){
                fwrite(audioFrame.buffer.bytes, 1, audioFrame.buffer.length, handler.file);
            }
        }
        return QAV_OK;
    }

}




-(QAVResult)audioDataShouInput:(QAVAudioFrame*)audioFrame type:(QAVAudioDataSourceType)type{
    NSString*key = [NSString stringWithFormat:@"%ld", type];
    audioCallbackHandler*handler = [_dicRunningState objectForKey:key];
    if (handler && handler.fileName && handler.file){
        int sampleRate = 0, channelNum = 0, ret = 0;
        ret = sscanf(handler.fileName.UTF8String, "%d_%d.pcm", &sampleRate, &channelNum);
        if (ret < 2)
            return QAV_ERR_FAILED;

        if (sampleRate != audioFrame.desc.ChannelNum || channelNum != audioFrame.desc.SampleRate){
            
            
        }
        
        struct QAVAudioFrameDesc desc;
        desc.ChannelNum = channelNum;
        desc.SampleRate = sampleRate;
        
        audioFrame.desc = desc;
        
        NSInteger frameLen = sampleRate * channelNum * 2 / 50;
        
        size_t size = fread((char*)audioFrame.buffer.bytes, 1, frameLen, handler.file);
        if( size < frameLen ) {
            fseek( handler.file, 0, SEEK_SET);
            fread((char*)audioFrame.buffer.bytes, 1, frameLen, handler.file);
        }
        
        audioFrame.buffer = [NSData dataWithBytesNoCopy:(void*)audioFrame.buffer.bytes length:frameLen];
        
        return QAV_OK;
        
    }
    return QAV_OK;
}

@end
