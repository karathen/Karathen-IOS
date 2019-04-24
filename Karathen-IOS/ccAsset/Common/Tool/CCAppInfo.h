//
//  CCAppInfo.h
//  ccAsset
//
//  Created by SealWallet on 2018/9/21.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCAppInfo : NSObject


/**
 app渠道

 @return 渠道
 */
+ (CCAppChannel)appChannel;
+ (NSString *)channelString;

/**
 app版本号

 @return 版本号
 */
+ (NSString *)appVersion;


/**
 build版本

 @return 版本
 */
+ (NSString *)appBuildVersion;


/**
 获取标识符

 @return 标识符
 */
+ (NSString *)getDeviceId;

@end
