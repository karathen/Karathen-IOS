//
//  CCAppInfo.m
//  ccAsset
//
//  Created by SealWallet on 2018/9/21.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCAppInfo.h"
#import <SAMKeychain/SAMKeychain.h>

@implementation CCAppInfo


+ (CCAppChannel)appChannel {
    return CCAppChannelAppstore;
//    return CCAppChannelEnterprise;
}

+ (NSString *)channelString {
    switch ([self appChannel]) {
        case CCAppChannelAppstore:
        {
            return @"Appstore";
        }
            break;
        case CCAppChannelEnterprise:
        {
            return @"Enterprise";
        }
            break;
        default:
            break;
    }
    return @"Appstore";
}

#pragma mark - 版本号
+ (NSString *)appVersion {
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [infoDic objectForKey:@"CFBundleShortVersionString"];
    return appVersion;
}


#pragma mark - build
+ (NSString *)appBuildVersion {
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [infoDic objectForKey:@"CFBundleVersion"];
    return appVersion;
}

#pragma mark - 获取标识符
+ (NSString *)getDeviceId {
    NSString *service = @" ";
    NSString * currentDeviceUUIDStr = [SAMKeychain passwordForService:service account:@"uuid"];
    if (currentDeviceUUIDStr == nil || [currentDeviceUUIDStr isEqualToString:@""]) {
        NSUUID * currentDeviceUUID = [UIDevice currentDevice].identifierForVendor;
        currentDeviceUUIDStr = currentDeviceUUID.UUIDString;
        currentDeviceUUIDStr = [currentDeviceUUIDStr stringByReplacingOccurrencesOfString:@"-" withString:@""];
        currentDeviceUUIDStr = [currentDeviceUUIDStr lowercaseString];
        [SAMKeychain setPassword: currentDeviceUUIDStr forService:service account:@"uuid"];
    }
    return currentDeviceUUIDStr;
}

@end
