//
//  SettingViewController.h
//  QAVSDKDemo_P
//
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
