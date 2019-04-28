//
//  KarathenFilterView.h
//  Karathen
//
//  Created by Karathen on 2018/9/4.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "MLMOptionSelectView.h"

@interface CCAssetFilterView : MLMOptionSelectView

@property (nonatomic, weak) CCWalletData *walletData;

- (void)showTargetView:(UIView *)view;

@end


@interface CCAssetFilterCell : UITableViewCell

@property (nonatomic, strong) UILabel *titleLab;

@end


@interface CCAssetNoBalanceCell : UITableViewCell

@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UISwitch *switchBtn;

@end
