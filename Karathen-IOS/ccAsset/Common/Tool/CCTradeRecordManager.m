
//
//  CCTradeRecordManager.m
//  ccAsset
//
//  Created by SealWallet on 2018/8/2.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCTradeRecordManager.h"
#import "CCCoreData+TradeRecord.h"
#import "CCTradeRecordRequest.h"
#import "CCNEOApi.h"
#import "CCONTApi.h"
#import "CCETHMonitor.h"
#import "CCNEOMonitor.h"
#import "CCONTMonitor.h"

@interface CCTradeRecordManager ()

@property (nonatomic, weak) CCWalletData *walletData;
@property (nonatomic, strong) NSString *tokenAddress;

@end

@implementation CCTradeRecordManager

- (instancetype)initWithWallet:(CCWalletData *)walletData
                  tokenAddress:(NSString *)tokenAddress {
    if (self = [super init]) {
        self.walletData = walletData;
        self.tokenAddress = tokenAddress;
    }
    return self;
}

#pragma mark - dealData
- (void)requsetLocalData {
    self.localData = [[CCCoreData coreData] requsetTradeRecordsWithWalletAddress:self.walletData.address tokenAddress:self.tokenAddress coinType:self.walletData.type accountID:self.walletData.wallet.accountID];

    switch (self.walletData.type) {
        case CCCoinTypeETH:
            [[CCETHMonitor monitor] updateWithTimerCount:0];
            break;
        case CCCoinTypeNEO:
            [[CCNEOMonitor monitor] updateWithTimerCount:0];
            break;
        case CCCoinTypeONT:
            [[CCONTMonitor monitor] updateWithTimerCount:0];
            break;
        default:
            break;
    }
}

@end
