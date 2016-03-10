//
//  VideoChoosingViewController.h
//  QAVSDKDemo
//
//

#import <UIKit/UIKit.h>

@protocol ChangeAuthorityDelegate <NSObject>
- (void)changeAuthority:(NSData*)authPirvateMap;
@end

@interface ChangeAuthorityController : UIViewController <UITableViewDelegate, UITableViewDataSource,UITextFieldDelegate>
{
}

@property (nonatomic,retain) id<ChangeAuthorityDelegate> changeDelegate;

@end
