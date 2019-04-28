//
//  CCWalletInfoHeadView.h
//  Karathen
//
//  Created by Karathen on 2018/7/18.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CCWalletInfoHeadView;
@protocol CCWalletInfoHeadViewDelegate <NSObject>

@optional
- (void)headView:(CCWalletInfoHeadView *)headView didSelectedAtIndex:(NSInteger)index;
- (void)headView:(CCWalletInfoHeadView *)headView changeToIndex:(NSInteger)index;
- (void)headView:(CCWalletInfoHeadView *)headView endAtIndex:(NSInteger)index;
- (void)headView:(CCWalletInfoHeadView *)headView extractGasWithWallet:(CCWalletData *)walletData;

@end


@interface CCWalletInfoHeadView : UIView

@property (nonatomic, weak) id<CCWalletInfoHeadViewDelegate> delegate;

- (void)reloadHeader;
- (void)reloadData;

@end

@class CCWalletInfoHeadViewCell;
@protocol CCWalletInfoHeadViewCellDelegate <NSObject>

@optional
- (void)extractGasHeadCell:(CCWalletInfoHeadViewCell *)cell withWallet:(CCWalletData *)walletData;

@end

@interface CCWalletInfoHeadViewCell : UICollectionViewCell

@property (nonatomic, weak) id<CCWalletInfoHeadViewCellDelegate> delegate;

- (void)bindCellWithWallet:(CCWalletData *)wallet;

@end
