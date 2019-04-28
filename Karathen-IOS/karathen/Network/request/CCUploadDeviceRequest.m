//
//  CCUploadDeviceRequest.m
//  Karathen
//
//  Created by Karathen on 2018/10/26.
//  Copyright © 2018 raistone. All rights reserved.
//

#import "CCUploadDeviceRequest.h"
#import "CCAppInfo.h"

@implementation CCUploadDeviceRequest

- (NSDictionary *)requestArgument {
    return @{
             @"id":@"1",
             @"method":@"uploadDevice",
             @"jsonrpc":@"2.0",
             @"params":@[[CCAppInfo getDeviceId],self.addressDic?:@""]
             };
}

- (void)uploadRequet:(void(^)(void))completion {
    [self startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        if (completion) {
            completion();
        }
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        if (completion) {
            completion();
        }
    }];
}

@end
