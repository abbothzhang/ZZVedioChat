//
//  TipsViewController.h
//  QAVSDKDemo_P
//
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface TipsViewController : UIViewController{
    MBProgressHUD* _tipsView;
}
-(void)showTips:(NSString*)msg;
-(void)hideTips;
-(void)hideTips:(NSString*)msg afterDelay:(NSTimeInterval)delay;
@end
