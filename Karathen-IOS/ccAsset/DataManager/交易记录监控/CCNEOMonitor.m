//
//  CCNEOMonitor.m
//  ccAsset
//
//  Created by SealWallet on 2018/10/29.
//  Copyright © 2018 raistone. All rights reserved.
//

#import "CCNEOMonitor.h"
#import "CCTradeRecord+CoreDataClass.h"
#import "CCCoreData+TradeRecord.h"
#import "CCNEOApi.h"

static CCNEOMonitor *monitor = nil;

@interface CCNEOMonitor ()

///没有块高的 status = 0,blockHeight = 0
@property (nonatomic, strong) NSMutableArray <CCTradeRecord *> *blockArray;
///status = 0 ,blockHeight != 0
@property (nonatomic, strong) NSMutableArray <CCTradeRecord *> *statusArray;

@end

@implementation CCNEOMonitor

+ (instancetype)monitor {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        monitor = [[CCNEOMonitor alloc] init];
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
    [[CCNEOApi manager] getNEOTransactionWithTxid:tradeRecord.txId completion:^(NSDictionary *info) {
        @strongify(self)
        if (info && [info isKindOfClass:[NSDictionary class]]) {
            NSInteger blockHeight = [info[@"block_height"] integerValue];
            NSTimeInterval blockTime = [info[@"time"] doubleValue];
            if (blockHeight > 0) {
                [self updateTrade:tradeRecord blockHeight:[NSString stringWithFormat:@"%@",@(blockHeight)] blcokTime:blockTime];
            }
        }
    }];
}

- (void)updateTrade:(CCTradeRecord *)tradeRecord blockHeight:(NSString *)blockHeight blcokTime:(double)blockTime {
    [self.blockArray removeObject:tradeRecord];
    //是NEO或者GAS 有块高就直接成功
    if ([self isNEOOrGas:tradeRecord]) {
        [self updateTrade:tradeRecord status:1];
    } else {
        [self.statusArray addObject:tradeRecord];
    }
    if (blockTime > 0) {
        tradeRecord.blockTime = blockTime;
    }
    tradeRecord.blockHeight = blockHeight;
    [[CCCoreData coreData] saveDataCompletion:nil];
    [CCNotificationCenter postAssetTradeUpdateWithWalletAddress:tradeRecord.walletAddress tokenAddress:tradeRecord.tokenAddress];
}

#pragma mark - 更新状态
- (void)updateStatus {
    NSMutableDictionary *tradeDic = [NSMutableDictionary dictionary];
    
    NSMutableArray *neoGasArray = [NSMutableArray array];
    for (CCTradeRecord *record in self.statusArray) {
        if (!record) {
            continue;
        }
        if ([self isNEOOrGas:record]) {
            [neoGasArray addObject:record];
        } else {
            [tradeDic setValue:record forKey:record.txId];
        }
    }
    
    for (CCTradeRecord *record in neoGasArray) {
        [self updateTrade:record status:1];
    }
    
    if (tradeDic.allKeys.count == 0) {
        return;
    }
    
    @weakify(self)
    [[CCNEOApi manager] getNEOTransactionStatusWithTxIds:tradeDic.allKeys completion:^(NSDictionary *statusDic) {
        @strongify(self)
        for (NSString *key in statusDic) {
            CCTradeRecord *record = tradeDic[key];
            NSInteger status = [statusDic[key] boolValue];
            [self updateTrade:record status:status];
        }
    }];
}

#pragma mark - 是NEO或者GAS
- (BOOL)isNEOOrGas:(CCTradeRecord *)tradeRecord {
    return [CCWalletData isNEOOrNEOGas:tradeRecord.tokenAddress];
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
        
        NSArray *blocks = [[CCCoreData coreData] requestNeedRequestBlockRecords:CCCoinTypeNEO];
        if (blocks.count) {
            _blockArray = [blocks mutableCopy];
        }
    }
    return _blockArray;
}

- (NSMutableArray<CCTradeRecord *> *)statusArray {
    if (!_statusArray) {
        _statusArray = [NSMutableArray array];
        
        NSArray *status = [[CCCoreData coreData] requestNeedRequestStatusRecords:CCCoinTypeNEO];
        if (status.count) {
            _statusArray = [status mutableCopy];
        }
    }
    return _statusArray;
}



@end
