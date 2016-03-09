//
//  SettingViewController.h
//  QAVSDKDemo_P
//
//  Created by TOBINCHEN on 14-12-16.
//  Copyright (c) 2014年 TOBINCHEN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingViewController : UITableViewController<UITableViewDataSource,UITableViewDelegate>{
    IBOutlet UISwitch *_isTestSwitch;
    IBOutlet UITableViewCell *_authAudioSend;
    IBOutlet UITableViewCell *_authAudioRev;
    IBOutlet UITableViewCell *_authVideoSend;
    IBOutlet UITableViewCell *_authVideoRev;
    
    IBOutlet UISegmentedControl *_segType;
}
@property (retain, nonatomic) IBOutlet UITableView *settingTableView;
@property (assign, nonatomic) NSInteger selectedCategory;
-(IBAction)save:(id)sender;
-(IBAction)reset:(id)sender;
@end
