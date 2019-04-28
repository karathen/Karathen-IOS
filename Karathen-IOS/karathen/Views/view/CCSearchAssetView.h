//
//  CCSearchAssetView.h
//  Karathen
//
//  Created by Karathen on 2018/7/27.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCBottomLineTableViewCell.h"

@class CCSearchAssetCell;
@protocol CCSearchAssetCellDelegate<NSObject>

@optional
- (void)addWithAssetCell:(CCSearchAssetCell *)cell;

@end

@interface CCSearchAssetView : UITableView

+ (CCSearchAssetView *)searchViewWithWallet:(CCWalletData *)wallet;

- (void)searchAsset:(NSString *)keywords;

@end


@interface CCSearchAssetCell : CCBottomLineTableViewCell

@property (nonatomic, weak) id<CCSearchAssetCellDelegate> delegate;
@property (nonatomic, weak, readonly) CCTokenInfoModel *asset;

- (void)bindCellWithAsset:(CCTokenInfoModel *)asset
              hadAddAsset:(CCAsset *)hadAddAsset
               walletData:(CCWalletData *)walletData;

@end
