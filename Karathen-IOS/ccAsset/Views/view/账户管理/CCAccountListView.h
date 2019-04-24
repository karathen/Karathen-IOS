//
//  CCAccountListView.h
//  ccAsset
//
//  Created by SealWallet on 2018/11/27.
//  Copyright © 2018 raistone. All rights reserved.
//

#import "CCTableView.h"
#import "CCTableViewCell.h"

@class CCAccountListCell;
@protocol CCAccountListViewDelegate <NSObject>

@optional
- (void)addNewWallet;
- (void)changeWalletNameWithAccount:(CCAccountData *)account;
- (void)changeWalletPwdWithAccount:(CCAccountData *)account;
- (void)showWalletPwdInfoWithAccount:(CCAccountData *)account;
- (void)walletCoinManagerWithAccount:(CCAccountData *)account;
- (void)walletBackUpWithAccount:(CCAccountData *)account;
- (void)deleteWalletWithAccount:(CCAccountData *)account;

@end


@protocol CCAccountListCellDelegate <NSObject>

@optional
- (void)moreAccountCell:(CCAccountListCell *)cell account:(CCAccountData *)account targetView:(UIView *)targetView;

@end

@interface CCAccountListView : CCTableView

@property (nonatomic, weak) id<CCAccountListViewDelegate> accountDelegate;

@end

@interface CCAccountListCell: CCTableViewCell

@property (nonatomic, weak) id<CCAccountListCellDelegate> delegate;

- (void)bindCellWithAccount:(CCAccountData *)account;

@end


@interface CCAccountListFootView : UITableViewHeaderFooterView

@property (nonatomic, strong) UIButton *addBtn;

@end
