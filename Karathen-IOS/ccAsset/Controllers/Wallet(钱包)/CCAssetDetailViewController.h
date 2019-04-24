//
//  CCAssetDetailViewController.h
//  ccAsset
//
//  Created by SealWallet on 2018/7/23.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCBlueViewController.h"

@interface CCAssetDetailViewController : CCBlueViewController

@property (nonatomic, weak) CCWalletData *wallet;
@property (nonatomic, weak) CCAsset *asset;

@end
