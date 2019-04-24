//
//  CCWallteAssetBallanceCell.h
//  ccAsset
//
//  Created by SealWallet on 2018/7/20.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCBottomLineTableViewCell.h"


@interface CCWallteAssetBallanceCell : CCBottomLineTableViewCell

@property (nonatomic, copy) void(^showAssetDetail)(CCAsset *asset,UIButton *button);

- (void)bindCellWithAsset:(CCAsset *)asset walletData:(CCWalletData *)walletData;

@end
