//
//  runningTipsView.h
//  QAVSDKDemo
//
//

#import <UIKit/UIKit.h>

@interface runningTipsView : UIView{

    UILabel*_plabel;
    UIView*_parent;
}

+(runningTipsView*)Shared;
-(id)init;

-(void)ShowInParent:(NSString*)msg parentView:(UIView*)parent;

+(void)Show:(NSString*)msg parentView:(UIView*)parent;
+(BOOL)ShowInCount:(NSString*)msg parentView:(UIView*)parent;
+(void)hide;
@end
