//
//  CCTransferViewController.h
//  ccAsset
//
//  Created by SealWallet on 2018/7/23.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCScrollViewController.h"

@class CCErc721TokenInfoModel;

@interface CCTransferViewController : CCScrollViewController

@property (nonatomic, strong) NSString *toAddress;
//721
@property (nonatomic, weak) CCErc721TokenInfoModel *tokenModel;

@property (nonatomic, weak) CCWalletData *walletData;
@property (nonatomic, weak) CCAsset *asset;


@end
