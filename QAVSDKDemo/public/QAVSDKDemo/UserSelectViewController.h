//
//  UserSelectViewController.h
//  QAVSDKDemo_P
//
//

#import <UIKit/UIKit.h>
#import "UserConfig.h"

@protocol UserSelectViewControllerDelegate <NSObject>

-(void)userSelected:(NSString*)openId;
@end


@interface UserSelectViewController : UITableViewController{
    UIButton*_addBtn;
    UIButton*_cancelbtn;
    id<UserSelectViewControllerDelegate> _delegate;
}
@property (nonatomic,assign) id<UserSelectViewControllerDelegate> delegate;
@end
