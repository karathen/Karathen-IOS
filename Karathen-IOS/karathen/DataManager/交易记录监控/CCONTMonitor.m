//
//  CCONTMonitor.m
//  Karathen
//
//  Created by Karathen on 2018/12/10.
//  Copyright © 2018 raistone. All rights reserved.
//

#import "CCONTMonitor.h"
#import "CCTradeRecord+CoreDataClass.h"
#import "CCCoreData+TradeRecord.h"
#import "CCONTApi.h"

static CCONTMonitor *monitor = nil;

@interface CCONTMonitor ()

///没有块高的 status = 0,blockHeight = 0
@property (nonatomic, strong) NSMutableArray <CCTradeRecord *> *blockArray;
///status = 0 ,blockHeight != 0
@property (nonatomic, strong) NSMutableArray <CCTradeRecord *> *statusArray;

@end

@implementation CCONTMonitor

+ (instancetype)monitor {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        monitor = [[CCONTMonitor alloc] init];
    });
    return monitor;
}

#pragma mark - updateByTimerCount
- (void)updateWithTimerCount:(NSInteger)count {
    if (count%20 == 0) {
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
    [[CCONTApi manager] getONTTransactionWithTxid:tradeRecord.txId completion:^(NSDictionary *info) {
        @strongify(self)
        if (info && [info isKindOfClass:[NSDictionary class]]) {
            NSInteger blockHeight = [info[@"Height"] integerValue];
            if (blockHeight > 0) {
                [self updateTrade:tradeRecord blockHeight:[NSString stringWithFormat:@"%@",@(blockHeight)] blcokTime:0];
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
    NSMutableDictionary *tradeDic = [NSMutableDictionary dictionary];
    for (CCTradeRecord *record in self.statusArray) {
        if (!record) {
            continue;
        }
        [tradeDic setValue:record forKey:record.txId];
    }
    if (tradeDic.allKeys.count == 0) {
        return;
    }
    @weakify(self)
    [[CCONTApi manager] getONTTransactionStatusWithTxIds:tradeDic.allKeys completion:^(NSDictionary *statusDic) {
        @strongify(self)
        for (NSString *key in statusDic) {
            CCTradeRecord *record = tradeDic[key];
            NSInteger status = [statusDic[key] boolValue];
            [self updateTrade:record status:status];
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
        
        NSArray *blocks = [[CCCoreData coreData] requestNeedRequestBlockRecords:CCCoinTypeONT];
        if (blocks.count) {
            _blockArray = [blocks mutableCopy];
        }
    }
    return _blockArray;
}

- (NSMutableArray<CCTradeRecord *> *)statusArray {
    if (!_statusArray) {
        _statusArray = [NSMutableArray array];
        
        NSArray *status = [[CCCoreData coreData] requestNeedRequestStatusRecords:CCCoinTypeONT];
        if (status.count) {
            _statusArray = [status mutableCopy];
        }
    }
    return _statusArray;
}


@end
