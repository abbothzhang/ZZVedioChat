//
//  VideoRenderView.m
//  QAVSDKDemo_P
//
//  Created by TOBINCHEN on 14-11-21.
//  Copyright (c) 2014年 TOBINCHEN. All rights reserved.
//

#import "VideoRenderView.h"


@implementation VideoRenderView

-(id)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        _views=[[NSMutableArray alloc] init];
        _listView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.bounds)-220, frame.size.width, 120)];
        [self addSubview:_listView];
        
        UITapGestureRecognizer* tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandle:)];
        tapGestureRecognizer.numberOfTapsRequired = 1;
        [_listView addGestureRecognizer:tapGestureRecognizer];
        self.translatesAutoresizingMaskIntoConstraints=YES;
        self.clipsToBounds=NO;
        self.autoresizesSubviews=NO;
        _listView.clipsToBounds=NO;
    }
    return self;
}
-(void)dealloc
{
    [_selectedView release];
    [_views release];
    [_listView release];
    [super dealloc];
}
-(void)selectView:(UIView*)aView
{
    if (_views.count<=0) {
        return;
    }
    
    NSUInteger index=[_views indexOfObject:aView];
    if (index==NSNotFound) {
        return;
    }
    
    if (!_selectedView) {
        _selectedView=aView;
        //CGPoint srcCenter=[self convertPoint:_selectedView.center fromView:_selectedView.superview];
        
        [_selectedView removeFromSuperview];
        [_views removeObject:_selectedView];
        [self insertSubview:_selectedView atIndex:0];
        
        //_selectedView.center=srcCenter;
        [self doLayout:NO];
        
    }else{
        CGPoint srcCenter=[self convertPoint:aView.center fromView:_listView];
        [aView removeFromSuperview];
        [self insertSubview:aView atIndex:0];
        aView.center=srcCenter;
        
        srcCenter=[_listView convertPoint:_selectedView.center fromView:self];
        [_views replaceObjectAtIndex:index withObject:_selectedView];
        [_selectedView removeFromSuperview];
        [_listView insertSubview:_selectedView atIndex:0];
        _selectedView.center=srcCenter;
        
        _selectedView=aView;
        
        [self doLayout:NO];
        
    }
}
-(void)tapHandle:(UITapGestureRecognizer*)sender
{
    UIView* tapedView=nil;
    for (UIView* aView in _views) {
        if(CGRectContainsPoint(aView.frame, [sender locationInView:_listView])){
            tapedView=aView;
        }
    }
    if (tapedView) {
        [self selectView:tapedView];
    }
}

- (UIColor *)randomColor {
    static BOOL seeded = NO;
    if (!seeded) {
        seeded = YES;
        (time(NULL));
    }
    CGFloat red = (CGFloat)random() / (CGFloat)RAND_MAX;
    CGFloat green = (CGFloat)random() / (CGFloat)RAND_MAX;
    CGFloat blue = (CGFloat)random() / (CGFloat)RAND_MAX;
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
}

-(void)addRenderView:(UIView*)aView
{
    //aView.backgroundColor=[self randomColor];
    
    #define _TEST_ADD_VIEW
#ifdef _TEST_ADD_VIEW
    //aView=[[UIView alloc] init];
    aView.clipsToBounds=YES;
    aView.contentMode=UIViewContentModeCenter;
#endif//_TEST_ADD_VIEW
    [_views addObject:aView];
    [_listView addSubview:aView];
    [_listView setContentSize:CGSizeMake(_views.count*100, CGRectGetHeight(_listView.bounds))];
    [self doLayout:NO];
}
-(void)removeRenderView:(UIView*)aView
{
    if(aView==_selectedView){
        [_selectedView removeFromSuperview];
        _selectedView=nil;
        
        if (_views.count>0) {
            [self selectView:[_views objectAtIndex:0]];
        }
    }else{
        [_views removeObject:aView];
        [aView removeFromSuperview];
        [_listView setContentSize:CGSizeMake(_views.count*100, CGRectGetHeight(_listView.bounds))];
        [self doLayout:NO];
    }
}
-(void)doLayout:(BOOL)animate{
    if (_selectedView==nil) {
        [self selectView:[_views objectAtIndex:0]];
    }
    void (^layoutblock)()=^(){
        for (int i=0; i<_views.count; i++) {
            UIView* view=[_views objectAtIndex:i];
            view.frame=CGRectMake(i*100, 0, 100, 120);
        }
        _selectedView.frame=self.bounds;
    };
    if (animate) {
        [UIView animateWithDuration:0.3 animations:layoutblock completion:^(BOOL finished) {
        }];
    }else{
        layoutblock();
    }
    
    
}
-(void)layoutSublayersOfLayer:(CALayer *)layer
{
    [super layoutSublayersOfLayer:layer];
}
-(void)layoutSubviews{
    [super layoutSubviews];
}
@end

