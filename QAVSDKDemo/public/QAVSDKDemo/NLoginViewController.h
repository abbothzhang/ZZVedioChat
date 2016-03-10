//
//  LoginViewController.h
//  QAVSDKDemo_P
//
//

#import <UIKit/UIKit.h>
#import "UserSelectViewController.h"
#import "QAVSDK/QAVContext.h"
#import "InputTableViewCell.h"

@interface NLoginViewController : UITableViewController<UserSelectViewControllerDelegate, UIAlertViewDelegate>{
    InputTableViewCell *roomCell;
    InputTableViewCell *roomRoleCell;
    BOOL _bMulti;
}
-(IBAction)setting:(id)sender;
@end
