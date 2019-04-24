//
//  CCTradeRecordRequest.m
//  ccAsset
//
//  Created by SealWallet on 2018/7/24.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCTradeRecordRequest.h"
#import "CCNEOApi.h"
#import "CCETHApi.h"
#import "CCONTApi.h"
#import "CCTradeRecordModel.h"

@interface CCTradeRecordRequest ()

@property (nonatomic, assign) NSInteger page;
@property (nonatomic, strong) NSMutableArray <CCTradeRecordModel *> *dataArray;

@end

@implementation CCTradeRecordRequest

//一页8个
- (NSInteger)pageCount {
    return 8;
}

- (void)headRefreshBlock:(loadFinish)block {
    self.page = 1;
    [self requestBlock:block];
}

- (void)footRefreshBlock:(loadFinish)block {
    self.page += 1;
    [self requestBlock:block];
}

- (void)requestBlock:(loadFinish)block {
    @weakify(self)
    switch (self.coinType) {
        case CCCoinTypeETH:
        {
            [[CCETHApi manager] getTransationWithAddress:self.address tokenAddress:self.tokenAddress page:self.page completion:^(BOOL suc, NSArray *records) {
                @strongify(self)
                [self dealRequestSuc:suc records:records finish:block];
            }];
        }
            break;
        case CCCoinTypeNEO:
        {
            [[CCNEOApi manager] getTransationWithAddress:self.address tokenAddress:self.tokenAddress page:self.page completion:^(BOOL suc, NSArray *records) {
                @strongify(self)
                [self dealRequestSuc:suc records:records finish:block];
            }];
        }
            break;
        case CCCoinTypeONT:
        {
            [[CCONTApi manager] getTransationWithAddress:self.address tokenAddress:self.tokenAddress page:self.page completion:^(BOOL suc, NSArray *records) {
                @strongify(self)
                [self dealRequestSuc:suc records:records finish:block];
            }];
        }
            break;
        default:
            break;
    }
}

- (void)dealRequestSuc:(BOOL)suc records:(NSArray *)records finish:(loadFinish)finish {
    if (suc) {
        NSArray *models = [CCTradeRecordModel mj_objectArrayWithKeyValuesArray:records];
        if (self.page == 1) {
            self.dataArray = [models mutableCopy];
        } else {
            [self.dataArray addObjectsFromArray:models];
        }
        self.hadMore = models.count >= self.pageCount;
        finish(models);
    } else {
        if (self.page > 1) {
            self.page -= 1;
        }
        finish(nil);
    }
}

- (NSString *)tokenAddress {
    return [self.asset.tokenSynbol isEqualToString:@"ETH"]?nil:self.asset.tokenAddress;
}

- (NSMutableArray<CCTradeRecordModel *> *)dataArray {
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}

@end


