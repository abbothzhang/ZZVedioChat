//
//  VideoChoosingViewController.h
//  QAVSDKDemo
//
//  Created by roger lin on 15/8/31.
//  Copyright (c) 2015年 TOBINCHEN. All rights reserved.
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
