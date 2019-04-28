//
//  CCChangeWalletView.h
//  Karathen
//
//  Created by Karathen on 2018/9/10.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "MLMOptionSelectView.h"

@interface CCChangeWalletView : MLMOptionSelectView

@property (nonatomic, copy) void(^chooseWallet)(CCWalletData *walletData);


- (instancetype)initWithAsset:(CCAsset *)asset walletData:(CCWalletData *)walletData;
- (void)showTargetView:(UIView *)view space:(CGFloat)space;

@end

@interface CCChangeWalletCell : UITableViewCell

@property (nonatomic, strong) UILabel *nameLab;
@property (nonatomic, strong) UILabel *typeLab;
@property (nonatomic, strong) UILabel *addressLab;
@property (nonatomic, strong) UILabel *balanceLab;
@property (nonatomic, strong) UIView *lineView;

- (void)bindCellWithWalletData:(CCWalletData *)walletData asset:(CCAsset *)asset isSelecterd:(BOOL)isSelected;

@end
