//
//  AppDelegate.h
//  AVTest
//
//  Created by TOBINCHEN on 14-8-13.
//  Copyright (c) 2014年 TOBINCHEN. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <TencentOpenAPI/TencentOAuth.h>
#import "WXApi.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, TencentSessionDelegate, WXApiDelegate>

@property (nonatomic, retain) TencentOAuth *openQQ;
@property (nonatomic, retain) id<WXApiDelegate> tlsuiwx;

- (void)switchToLoginView;

- (void)switchToMain;

@property (strong, nonatomic) UIWindow *window;

@end
