//
//  TLSLoginViewController.h
//  QAVSDKDemo
//
//  Created by AlexiChen on 15/8/20.
//  Copyright (c) 2015年 TOBINCHEN. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <TLSUI/TLSUI.h>
#import <TLSSDK/TLSLoginHelper.h>

@interface AVTLSLoginViewController : UIViewController<TLSRefreshTicketListener, TLSUILoginListener>

@property (nonatomic, retain) IBOutlet UILabel *tips;

@end
