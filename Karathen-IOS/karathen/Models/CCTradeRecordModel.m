//
//  CCTradeRecordModel.m
//  Karathen
//
//  Created by Karathen on 2018/9/10.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCTradeRecordModel.h"
#import "NSDate+Category.h"

@interface CCTradeRecordModel ()

@property (nonatomic, strong) NSString *blockTimeString;
@property (nonatomic, strong) NSString *decimalValue;

@end

@implementation CCTradeRecordModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{
             @"blockHeight":@"blockNumber"
             };
}

- (NSString *)blockTimeString {
    if (!_blockTimeString) {
        _blockTimeString = [NSDate timeWithTimeStamp:self.blockTime dateFormatter:@"yyyy-MM-dd HH:mm"];
    }
    return _blockTimeString;
}

+ (CCTradeRecordModel *)recorModelWithRecord:(CCTradeRecord *)record {
    CCTradeRecordModel *recordModel = [[CCTradeRecordModel alloc] init];
    recordModel.addressFrom = record.addressFrom;
    recordModel.addressTo = record.addressTo;
    recordModel.blockHeight = record.blockHeight;
    recordModel.blockTime = record.blockTime;
    recordModel.gas = record.gas;
    recordModel.gasPrice = record.gasPrice;
    recordModel.txId = record.txId;
    recordModel.value = record.value;
    recordModel.data = record.data;
    recordModel.remark = record.remark;
    recordModel.coinType = record.coinType;
    recordModel.txReceiptStatus = record.txReceiptStatus;
    return recordModel;
}

- (NSString *)decimalStringWithDecimal:(NSString *)decimal coinType:(CCCoinType)coinType {
    if (!self.decimalValue) {
        if (coinType == CCCoinTypeETH || coinType == CCCoinTypeONT) {
            self.decimalValue = [NSString valueString:self.value decimal:decimal];
        } else {
            self.decimalValue = self.value;
        }
    }
    return self.decimalValue;
}

@end
