//
//  CCTradeDetailViewController.h
//  Karathen
//
//  Created by Karathen on 2018/8/3.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCViewController.h"

@class CCTradeRecordModel;
@interface CCTradeDetailViewController : CCViewController

@property (nonatomic, weak) CCWalletData *walletData;
@property (nonatomic, strong) CCTradeRecordModel *tradeModel;
@property (nonatomic, strong) NSString *value;
@property (nonatomic, weak) CCAsset *asset;

@end
