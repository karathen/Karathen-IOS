//
//  CCGetTxRemarkRequest.m
//  Karathen
//
//  Created by Karathen on 2018/9/20.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCGetTxRemarkRequest.h"

@implementation CCGetTxRemarkRequest

- (NSString *)requestUrl {
    return @"";
}

- (NSDictionary *)requestArgument {
    return @{
             @"id":@"1",
             @"method":@"getTxRemark",
             @"jsonrpc":@"2.0",
             @"params":@[self.txId]
             };
}

- (void)requestCompletion:(void(^)(NSString *remark))completion {
    [self startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        NSDictionary *responseBody = request.responseObject;
        NSString *result = responseBody[@"result"];
        if ([result isKindOfClass:[NSNull class]]) {
            result = nil;
        }
        if (completion) {
            completion(result);
        }
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        if (completion) {
            completion(nil);
        }
    }];
}

@end
