//
//  CCFindPageRequest.m
//  ccAsset
//
//  Created by SealWallet on 2018/8/8.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCFindPageRequest.h"

@implementation CCFindPageRequest

- (NSString *)requestUrl {
    return @"";
}

- (NSInteger)cacheSecond {
    return 60*60*24;
}

- (NSDictionary *)requestArgument {
    return @{
             @"id":@"1",
             @"method":@"getFindPage",
             @"jsonrpc":@"2.0",
             @"params":@[]
             };
}

- (void)requsetCompletion:(void(^)(void))completion {
    if ([self loadCacheWithError:nil]) {
        NSDictionary *responseBody = [self responseJSONObject];
        self.dataArray = [CCFindPageModel mj_objectArrayWithKeyValuesArray:responseBody[@"result"]];
        if (completion) {
            completion();
        }
    }
    
    @weakify(self)
    [self setCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        NSDictionary *result = request.responseObject[@"result"];
        @strongify(self)
        if (result) {
            self.dataArray = [CCFindPageModel mj_objectArrayWithKeyValuesArray:result];
        }
        if (completion) {
            completion();
        }
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        if (completion) {
            completion();
        }
    }];
    [self startWithoutCache];
}

@end

@implementation CCFindPageModel

+ (NSDictionary *)mj_objectClassInArray {
    return @{
             @"content":[CCFindPageSingle class]
             };
}

@end

@implementation CCFindPageSingle

@end
