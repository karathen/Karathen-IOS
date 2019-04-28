//
//  CCETHMonitor.m
//  Karathen
//
//  Created by Karathen on 2018/10/22.
//  Copyright © 2018 raistone. All rights reserved.
//

#import "CCETHMonitor.h"
#import "CCTradeRecord+CoreDataClass.h"
#import "CCCoreData+TradeRecord.h"

static CCETHMonitor *monitor = nil;

@interface CCETHMonitor ()

///没有块高的 status = 0,blockHeight = 0
@property (nonatomic, strong) NSMutableArray <CCTradeRecord *> *blockArray;
///status = 0 ,blockHeight != 0
@property (nonatomic, strong) NSMutableArray <CCTradeRecord *> *statusArray;

@end


@implementation CCETHMonitor

+ (instancetype)monitor {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        monitor = [[CCETHMonitor alloc] init];
    });
    return monitor;
}

#pragma mark - updateByTimerCount
- (void)updateWithTimerCount:(NSInteger)count {
    if (count%15 == 0) {
        [self updateBlocks];
        [self updateStatus];
    }
}

#pragma mark - 添加新交易
- (void)addRecord:(CCTradeRecord *)record {
    [self.blockArray addObject:record];
    [self requestUpdateTrade:record];
}

#pragma mark - 更新块高
- (void)updateBlocks {
    for (CCTradeRecord *record in self.blockArray) {
        if (!record) {
            continue;
        }
        [self requestUpdateTrade:record];
    }
}

- (void)requestUpdateTrade:(CCTradeRecord *)tradeRecord {
    @weakify(self)
    [CCETHApi getETHTransactionWithTxid:tradeRecord.txId completion:^(TransactionInfoPromise *info) {
        @strongify(self)
        if (!info.error) {
            TransactionInfo *value = info.value;
            if (value) {
                if (value.blockNumber > 0) {
                    [self updateTrade:tradeRecord blockHeight:[NSString stringWithFormat:@"%@",@(value.blockNumber)] blcokTime:value.timestamp];
                }
            } else {
                [self.blockArray removeObject:tradeRecord];
                [self updateTrade:tradeRecord status:0];
            }
        }
    }];
}

- (void)updateTrade:(CCTradeRecord *)tradeRecord blockHeight:(NSString *)blockHeight blcokTime:(double)blockTime {
    [self.blockArray removeObject:tradeRecord];
    [self.statusArray addObject:tradeRecord];
    if (blockTime > 0) {
        tradeRecord.blockTime = blockTime;
    }
    tradeRecord.blockHeight = blockHeight;
    [[CCCoreData coreData] saveDataCompletion:nil];
    [CCNotificationCenter postAssetTradeUpdateWithWalletAddress:tradeRecord.walletAddress tokenAddress:tradeRecord.tokenAddress];
}

#pragma mark - 更新状态
- (void)updateStatus {
    for (CCTradeRecord *record in self.statusArray) {
        if (!record) {
            continue;
        }
        [self requestUpdateStatus:record];
    }
}

- (void)requestUpdateStatus:(CCTradeRecord *)tradeRecord {
    @weakify(self)
    [CCETHApi getETHTransactionReceiptWithTxid:tradeRecord.txId completion:^(TransactionInfoPromise *info) {
        @strongify(self)
        NSDictionary *value = (NSDictionary *)info.value;
        if (value && [value isKindOfClass:[NSDictionary class]]) {
            NSString *status = value[@"status"];
            if (status) {
                BigNumber *statusNum = [BigNumber bigNumberWithHexString:status];
                [self updateTrade:tradeRecord status:statusNum.integerValue];
            }
        }
    }];
    
}

- (void)updateTrade:(CCTradeRecord *)tradeRecord status:(NSInteger)status {
    if (status == 1) {
        tradeRecord.txReceiptStatus = 1;
        [self.statusArray removeObject:tradeRecord];
    } else {
        tradeRecord.txReceiptStatus = -1;
    }
    [[CCCoreData coreData] saveDataCompletion:nil];
    [CCNotificationCenter postAssetTradeUpdateWithWalletAddress:tradeRecord.walletAddress tokenAddress:tradeRecord.tokenAddress];
}

#pragma mark - blockArray
- (NSMutableArray<CCTradeRecord *> *)blockArray {
    if (!_blockArray) {
        _blockArray = [NSMutableArray array];
        
        NSArray *blocks = [[CCCoreData coreData] requestNeedRequestBlockRecords:CCCoinTypeETH];
        if (blocks.count) {
            _blockArray = [blocks mutableCopy];
        }
    }
    return _blockArray;
}

- (NSMutableArray<CCTradeRecord *> *)statusArray {
    if (!_statusArray) {
        _statusArray = [NSMutableArray array];
        
        NSArray *status = [[CCCoreData coreData] requestNeedRequestStatusRecords:CCCoinTypeETH];
        if (status.count) {
            _statusArray = [status mutableCopy];
        }
    }
    return _statusArray;
}


@end
