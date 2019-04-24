//
//  CCTokenIdsRequest.m
//  ccAsset
//
//  Created by SealWallet on 2018/9/15.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCTokenIdsRequest.h"
#import "CCErc721TokenInfoModel.h"

@interface CCTokenIdsRequest ()

@property (nonatomic, assign) NSInteger page;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end


@implementation CCTokenIdsRequest

//一页8个
- (NSInteger)pageCount {
    return 8;
}

- (void)headRefreshBlock:(void(^)(void))block {
    self.page = 1;
    [self requestBlock:block];
}

- (void)footRefreshBlock:(void(^)(void))block {
    self.page += 1;
    [self requestBlock:block];
}


- (void)requestBlock:(void(^)(void))block {
    @weakify(self)
    [[CCETHApi manager] getTokensOfOwner:self.address tokenAddress:self.tokenAddress page:self.page completion:^(BOOL suc, NSArray *tokens) {
        @strongify(self)
        [self dealRequestSuc:suc records:tokens finish:block];
    }];
}

- (void)dealRequestSuc:(BOOL)suc records:(NSArray *)records finish:(void(^)(void))finish {
    if (suc) {
        NSArray *models = [CCErc721TokenInfoModel mj_objectArrayWithKeyValuesArray:records];
        if (self.page == 1) {
            self.dataArray = [models mutableCopy];
        } else {
            [self.dataArray addObjectsFromArray:models];
        }
        self.hadMore = models.count >= self.pageCount;
        finish();
    } else {
        if (self.page > 1) {
            self.page -= 1;
        }
        finish();
    }
}

@end
