//
//  CCTokenInfoRequest.m
//  ccAsset
//
//  Created by SealWallet on 2018/7/27.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCTokenInfoRequest.h"

@implementation CCTokenInfoRequest

- (NSDictionary *)requestArgument {
    return @{
             @"id":@"1",
             @"method":@"getTokenInfo_2",
             @"jsonrpc":@"2.0",
             @"params":@[self.keyWord,self.coinType]
             };
}


- (void)requestCompletion:(void (^)(NSArray<CCTokenInfoModel *> *))completion {
    [self startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        NSArray *result = [CCTokenInfoModel mj_objectArrayWithKeyValuesArray:request.responseObject[@"result"]];
        if (result.count) {
            if (completion) {
                completion(result);
            }
        } else {
            if (completion) {
                completion(nil);
            }
        }
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        if (completion) {
            completion(nil);
        }
    }];
}


@end


@implementation CCTokenInfoModel

@end
