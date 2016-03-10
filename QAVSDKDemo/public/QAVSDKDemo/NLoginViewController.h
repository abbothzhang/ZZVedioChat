//
//  LoginViewController.h
//  QAVSDKDemo_P
//
//

#import <UIKit/UIKit.h>
#import "UserSelectViewController.h"
#import "QAVSDK/QAVContext.h"

@interface NLoginViewController : UITableViewController<UserSelectViewControllerDelegate, UIAlertViewDelegate>{
    IBOutlet UITextField* _textFiledRoomId;
    IBOutlet UITextField* _textFiledRoomRole;
    BOOL _bMulti;
}
-(IBAction)setting:(id)sender;
@end
