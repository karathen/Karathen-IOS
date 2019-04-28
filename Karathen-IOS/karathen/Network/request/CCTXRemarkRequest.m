//
//  CCTXRemarkRequest.m
//  Karathen
//
//  Created by 孟利明 on 2018/8/8.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCTXRemarkRequest.h"

@implementation CCTXRemarkRequest

- (NSString *)requestUrl {
    return @"";
}

- (NSDictionary *)requestArgument {
    NSString *remark = [self.remark stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

    return @{
             @"id":@"1",
             @"method":@"addTxRemark",
             @"jsonrpc":@"2.0",
             @"params":@[self.txId,remark?:@""]
             };
}

- (void)requestCompletion:(void(^)(BOOL suc))completion {
    [self startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        NSDictionary *responseBody = request.responseObject;
        if (completion) {
            completion([responseBody[@"result"] boolValue]);
        }
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        if (completion) {
            completion(NO);
        }
    }];
}

@end
