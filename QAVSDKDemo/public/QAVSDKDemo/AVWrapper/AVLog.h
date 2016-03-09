//
//  AVLog.h
//  QAVSDKDemo_P
//
//  Created by TOBINCHEN on 14-11-13.
//  Copyright (c) 2014年 TOBINCHEN. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef DEBUG
#define AVLog(...) do{ DDLogInfo(__VA_ARGS__); }while(0)
#else
#define AVLog(...) do{ DDLogInfo(__VA_ARGS__); }while(0)
#endif
