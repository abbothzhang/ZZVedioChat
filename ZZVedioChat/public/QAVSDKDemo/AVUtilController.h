//
//  AVUtilController.h
//  ZZVCSDKDemo
//
//  Created by xianhuanlin on 15/12/2.
//  Copyright © 2015年 TOBINCHEN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZZVideoChat.h"

struct auidoTransmitInfo{
    NSInteger channel;
    NSInteger sampleRate;
    NSInteger volume;
};

@interface netStreamState : NSObject{
    
}
@property(assign, nonatomic)FILE*file;
@property(copy, nonatomic)NSString*fileName;
@property(copy, nonatomic)NSString*identifier;
-(void)openFile:(NSString*)file;
@end

@interface audioCallbackHandler : NSObject{
    
}

-(void)openFile:(NSString*)file flag:(NSString*)flag;

@property(assign,nonatomic)struct auidoTransmitInfo transInfo;

@property(assign, nonatomic)FILE*file;
@property(assign, nonatomic)int offset;
@property(copy, nonatomic)NSString*fileName;
@property(retain,nonatomic)NSMutableDictionary*dicNetStream;

@end

@interface AVUtilController : UITableViewController<UIPickerViewDataSource,UIPickerViewDelegate,ZZVCAudioDataDelegate>{
    NSArray*g_audioDdataTypes;
    NSArray*g_audioDataSampleRates;
    NSArray*g_audioDataChannelNums;
    NSArray*g_DataEnable;
    NSArray*g_dataSources;
    NSArray*_arraySwitchs;
    IBOutlet UISwitch *_switchSendOutput;
    IBOutlet UISwitch *_switchMicOuput;
    
    IBOutlet UISwitch *_switchMixInput;
    IBOutlet UISwitch *_switchRemoteAudioOut;
    IBOutlet UISwitch *_switchSpeakerOut;
    
    IBOutlet UISwitch *_switchSpeakerInput;
    
    IBOutlet UISwitch *_switchTransmit;
    IBOutlet UISlider *_sliderVolume;
    
    IBOutlet UITextField *_textMixInput;
    
    IBOutlet UITextField *_textSpeakerInput;
    
    BOOL _isEnalbeMic;
    BOOL _isEnalbeMixToSend;
    BOOL _isEnalbeSend;
    BOOL _isEnalbeMixToPlay;
    BOOL _isEnalbePlay;
    BOOL _isEnalbeNetStream;
    BOOL _isEnalbeEnd;
    
    NSMutableDictionary* _dicRunningState;
    
    NSTimer* _audioTimer;
    
    NSLock *_lock;
}
@property (retain, nonatomic) IBOutlet UIPickerView *pickTypes;
@property (retain, nonatomic) IBOutlet UIPickerView *pickSamples;
@property (retain, nonatomic) IBOutlet UIPickerView *pickChannels;


-(void)reset;
@end
