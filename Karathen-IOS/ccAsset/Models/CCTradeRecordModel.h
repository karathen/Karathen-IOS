//
//  CCTradeRecordModel.h
//  ccAsset
//
//  Created by SealWallet on 2018/9/10.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCTradeRecord+CoreDataClass.h"

@interface CCTradeRecordModel : NSObject

@property (nonatomic, strong) NSString *addressFrom;
@property (nonatomic, strong) NSString *addressTo;
@property (nonatomic, strong) NSString *asset;
@property (nonatomic, strong) NSString *blockHeight;
@property (nonatomic, assign) NSTimeInterval blockTime;
@property (nonatomic, strong) NSString *data;
@property (nonatomic, strong) NSString *gas;
@property (nonatomic, strong) NSString *gasPrice;
@property (nonatomic, strong) NSString *txId;
@property (nonatomic, strong) NSString *value;
@property (nonatomic, strong) NSString *remark;
@property (nonatomic, assign) CCCoinType coinType;
@property (nonatomic, assign) NSInteger txReceiptStatus;//-1 0 1


- (NSString *)blockTimeString;
//
+ (CCTradeRecordModel *)recorModelWithRecord:(CCTradeRecord *)record;


- (NSString *)decimalStringWithDecimal:(NSString *)decimal coinType:(CCCoinType)coinType;

@end
