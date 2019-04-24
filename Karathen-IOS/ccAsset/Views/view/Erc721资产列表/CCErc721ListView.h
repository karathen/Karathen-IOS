//
//  CCErc721ListView.h
//  ccAsset
//
//  Created by SealWallet on 2018/9/13.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CCErc721ListView,CCErc721TokenInfoModel;
@protocol CCErc721ListViewDelegate <NSObject>

@optional
- (void)listView:(CCErc721ListView *)listView didSelectedModel:(CCErc721TokenInfoModel *)model;

@end

@interface CCErc721ListView : UICollectionView

@property (nonatomic, weak) id<CCErc721ListViewDelegate> listDelegate;

- (instancetype)initWithAsset:(CCAsset *)asset walletData:(CCWalletData *)walletData;

@end

@interface CCErc721ListCell : UICollectionViewCell

@property (nonatomic, strong) UILabel *idLab;

- (void)bindCellWithModel:(CCErc721TokenInfoModel *)model asset:(CCAsset *)asset walletData:(CCWalletData *)walletData;
- (void)createView;

@end

//CK猫
@interface CCErcCKListCell : CCErc721ListCell

@end
