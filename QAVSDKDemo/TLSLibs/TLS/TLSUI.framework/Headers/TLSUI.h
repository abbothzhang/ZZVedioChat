//
//  TLSUI.h
//  TLSUI
//
//  Created by okhowang on 15/7/20.
//  Copyright (c) 2015年 tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
//! Project version number for TLSUI.
FOUNDATION_EXPORT double TLSUIVersionNumber;

//! Project version string for TLSUI.
FOUNDATION_EXPORT const unsigned char TLSUIVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <TLSUI/PublicHeader.h>
@class TLSUserInfo;
@class SendAuthResp;
@class TencentOAuth;
@protocol WXApiDelegate;
@protocol TLSUILoginListener

@required
/*! @brief 用户关闭登录框*/
-(void)TLSUILoginCancel;
/*! @brief TLS登录成功*/
-(void)TLSUILoginOK:(TLSUserInfo*)userinfo;
/*! @brief QQ登录成功 票据在QQ API对象中*/
-(void)TLSUILoginQQOK;
/*! @brief 微信登录成功*/
-(void)TLSUILoginWXOK:(SendAuthResp*)resp;

@end

@interface TLSUILoginSetting: NSObject
@property (strong) TencentOAuth *openQQ;
@property (strong) NSArray *qqScope;
@property (strong) NSString *wxScope;
@property BOOL needBack;
@end
/*! @brief 拉起TLSUI登录框
 *
 * @param vc 当前view controller 需要实现TLSUILoginListener接口
 * @param qq QQ SDK对象 不需要QQ登录则传nil
 * @param qqScope QQ登录权限字串
 * @param wxScope 微信登录权限字串
 * @return 回调对象，目前仅用于微信登录回调
 */
FOUNDATION_EXPORT id<WXApiDelegate> TLSUILogin(UIViewController<TLSUILoginListener> *vc, TLSUILoginSetting *setting);
