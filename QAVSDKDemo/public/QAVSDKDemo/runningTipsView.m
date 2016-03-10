//
//  runningTipsView.m
//  QAVSDKDemo
//
//

#import "runningTipsView.h"

@implementation runningTipsView
-(id)init{
    id i = [super init];
    
    _plabel = [[UILabel alloc]init];
    _plabel.numberOfLines = 0;
    _plabel.textColor = [UIColor redColor];
    _plabel.font = [UIFont fontWithName:@"Helvetica" size:12];
    _plabel.textAlignment = NSTextAlignmentLeft;
    _plabel.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0 alpha:0.5f];
    
    [self addSubview:_plabel];
     self.userInteractionEnabled = NO;
//    
//    UITapGestureRecognizer*tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(Actiondo:)];
//    
//    [self addGestureRecognizer:tapGesture];
    
    return i;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)ShowInParent:(NSString*)msg parentView:(UIView*)parent{
    if (self.superview == nil)
    {
    [parent addSubview:self];
    _parent = [parent retain];
    }
    
    CGRect appRect = [UIScreen mainScreen].applicationFrame;
    CGSize size = [msg sizeWithFont:_plabel.font constrainedToSize:appRect.size lineBreakMode:UILineBreakModeWordWrap];
    [_plabel setFrame:CGRectMake(appRect.origin.x, appRect.origin.y, size.width, size.height)];
  
    _plabel.text = msg;
}

+(void)Show:(NSString*)msg parentView:(UIView*)parent{
    
    [[runningTipsView Shared] ShowInParent:msg parentView:parent];
    
}

int count = 0;
clock_t g_lasttime = 0;
+(BOOL)ShowInCount:(NSString*)msg parentView:(UIView*)parent{
    //count++;
    //if (count >= 3)
    {
        [[runningTipsView Shared] ShowInParent:msg parentView:parent];
        return YES;
    }
    return NO;
}
-(void)Actiondo:(id)sender{
    
   // [self hide];
}
+(runningTipsView*)Shared{
    static runningTipsView* pinit = nil;
    if (pinit == nil){
        pinit = [[runningTipsView alloc]init];
    }
    return pinit;
    
}
+(void)hide{
    [[runningTipsView Shared]  removeFromSuperview];
}
@end
