//
//  CCAssetHistoryCell.h
//  ccAsset
//
//  Created by SealWallet on 2018/7/23.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCBottomLineTableViewCell.h"

@class CCTradeRecordModel,CCTradeRecord;
@interface CCAssetHistoryCell : CCBottomLineTableViewCell

//YES 转出
- (void)bindCellWithModel:(CCTradeRecordModel *)model walletData:(CCWalletData *)walletData asset:(CCAsset *)asset value:(NSString *)value;

@end
