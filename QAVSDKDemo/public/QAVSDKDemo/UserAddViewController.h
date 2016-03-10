//
//  UserAddViewController.h
//  QAVSDKDemo_P
//
//

#import <UIKit/UIKit.h>
#import "UserSelectViewController.h"

@interface UserAddViewController : UITableViewController{
    IBOutlet UITextField* _openIdTextField;
    id<UserSelectViewControllerDelegate> _delegate;
}
@property (nonatomic,assign) id<UserSelectViewControllerDelegate> delegate;
@end
