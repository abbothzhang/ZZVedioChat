//
//  VideoChoosingViewController.h
//  QAVSDKDemo
//
//

#import <UIKit/UIKit.h>

@protocol VideoChoosingDelegate ;
@interface VideoChoosingViewController : UIViewController <UITableViewDelegate, UITableViewDataSource,UITextFieldDelegate>
{
}

@property (nonatomic,retain) id<VideoChoosingDelegate>chooseDelegate;

@end
@protocol VideoChoosingDelegate <NSObject>
- (void)playVideoWithVideo:(NSString*)video AndFrame:(NSString*)frame;
@end