//
//  CCWalletOptionView.h
//  ccAsset
//
//  Created by SealWallet on 2018/10/25.
//  Copyright © 2018 raistone. All rights reserved.
//

#import "MLMOptionSelectView.h"
#import "CCTableViewCell.h"

@interface CCWalletOptionView : MLMOptionSelectView

@property (nonatomic, copy) void(^chooseWallet)(CCWalletData *walletData);

- (instancetype)initWithCoinType:(CCCoinType)coinType walletData:(CCWalletData *)walletData;
- (void)showTargetView:(UIView *)view space:(CGFloat)space;

@end

@interface CCWalletOptionCell : CCTableViewCell

- (void)bindCellWithWallet:(CCWalletData *)walletData withSelected:(BOOL)isSelected;

@end
