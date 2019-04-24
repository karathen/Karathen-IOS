//
//  CCDataCache.m
//  ccAsset
//
//  Created by SealWallet on 2018/7/13.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCDataCache.h"

@implementation CCDataCache


#pragma mark - 获取Documents
+ (NSString *)documents {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

#pragma mark - 获取temp
+ (NSString *)temp {
    return NSTemporaryDirectory();
}

#pragma mark - 获取library
+ (NSString *)library {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

#pragma mark - 获取Library/Caches
+ (NSString *)libraryCache {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

#pragma mark - 创建目录
+ (BOOL)createDirectory:(NSString *)path {
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return YES;
    }
    
    return [[NSFileManager defaultManager] createDirectoryAtPath:path
                                     withIntermediateDirectories:YES
                                                      attributes:nil
                                                           error:NULL];
}


@end
