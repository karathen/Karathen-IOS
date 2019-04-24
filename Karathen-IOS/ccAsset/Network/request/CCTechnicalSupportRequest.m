//
//  CCTechnicalSupportRequest.m
//  ccAsset
//
//  Created by SealWallet on 2018/10/26.
//  Copyright © 2018 raistone. All rights reserved.
//

#import "CCTechnicalSupportRequest.h"
#import "UIImageTool.h"
#import "CCAppInfo.h"

@implementation CCTechnicalSupportRequest

- (NSDictionary *)requestArgument {
    return @{
             @"id":@"1",
             @"method":@"feedBack",
             @"jsonrpc":@"2.0",
             @"params":@[self.email?:@"",self.telephone?:@"",self.title?:@"",self.content?:@"",[self.urls componentsJoinedByString:@","],[CCAppInfo getDeviceId]]
             };
}

- (void)supportRequet:(void(^)(BOOL suc,NSString *msg))completion {
    [self startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        NSDictionary *responseBody = request.responseObject;
        BOOL result = [responseBody[@"result"] boolValue];
        if (result) {
            completion(YES,Localized(@"Submission succeeded"));
        } else {
            completion(NO,Localized(@"The submission is out of limit, please try again later."));
        }
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        completion(NO,Localized(@"Submission failed"));
    }];
}

@end
