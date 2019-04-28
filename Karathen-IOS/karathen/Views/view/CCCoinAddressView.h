//
//  CCCoinAddressView.h
//  Karathen
//
//  Created by Karathen on 2018/8/31.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCTableView.h"
#import "CCTableViewCell.h"

@protocol CCCoinAddressViewDelegate <NSObject>

@optional
- (void)manageExportPrivateKey:(CCWalletData *)walletData;
- (void)manageExportWIF:(CCWalletData *)walletData;
- (void)manageExportKeystore:(CCWalletData *)walletData;
- (void)manageEnterTheExplorer:(CCWalletData *)walletData;
- (void)manageDeleteAddress:(CCWalletData *)walletData;
- (void)manageChangeName:(CCWalletData *)walletData;
- (void)manageClaimGas:(CCWalletData *)walletData;

@end

@class CCCoinAddressCell;
@protocol CCCoinAddressCellDelegate <NSObject>

@optional
- (void)copyAddressCell:(CCCoinAddressCell *)cell walletData:(CCWalletData *)walletData;
- (void)moreAddressCell:(CCCoinAddressCell *)cell walletData:(CCWalletData *)walletData targetView:(UIView *)targetView;

@end


@interface CCCoinAddressView : CCTableView

@property (nonatomic, weak) id<CCCoinAddressViewDelegate> addressDelegate;

- (instancetype)initWithCoinData:(CCCoinData *)coinData;
- (void)scrollToIndex:(NSInteger)index;

@end


@interface CCCoinAddressCell : CCTableViewCell

@property (nonatomic, weak) id<CCCoinAddressCellDelegate> delegate;
- (void)bindCellWithWallet:(CCWalletData *)walletData;

@end
