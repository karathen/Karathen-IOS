//
//  CCChangeWalletView.m
//  ccAsset
//
//  Created by SealWallet on 2018/9/10.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCChangeWalletView.h"

@interface CCChangeWalletView ()

@property (nonatomic, weak) CCAsset *asset;
@property (nonatomic, weak) CCCoinData *coinData;
@property (nonatomic, weak) CCWalletData *walletData;

@end

@implementation CCChangeWalletView

- (instancetype)initWithAsset:(CCAsset *)asset walletData:(CCWalletData *)walletData {
    if (self = [super initOptionView]) {
        self.asset = asset;
        self.walletData = walletData;
        CCAccountData *account = [[CCDataManager dataManager] accountWithAccountID:self.walletData.wallet.accountID];
        self.coinData = [account coinDataWithCoinType:walletData.type];
        [self customSet];
    }
    return self;
}

- (void)showTargetView:(UIView *)view space:(CGFloat)space {
    self.edgeInsets = UIEdgeInsetsMake(0, FitScale(10), FitScale(20), FitScale(10));
    [self showOffSetScale:.5 space:space viewWidth:SCREEN_WIDTH-FitScale(10) targetView:view direction:MLMOptionSelectViewBottom];
}


#pragma mark - 默认设置
- (void)customSet {
    self.canEdit = NO;
    self.vhShow = NO;
    self.multiSelect = NO;
    self.maxLine = 3;
    self.optionType = MLMOptionSelectViewTypeArrow;
    
    [self registerClass:[CCChangeWalletCell class] forCellReuseIdentifier:@"CCChangeWalletCell"];

    @weakify(self)
    self.cell = ^UITableViewCell *(NSIndexPath *indexPath) {
        @strongify(self)
        CCWalletData *walletData = self.coinData.wallets[indexPath.row];
        CCAsset *asset = [walletData assetWithToken:self.asset.tokenAddress];
        CCChangeWalletCell *cell = [self dequeueReusableCellWithIdentifier:@"CCChangeWalletCell"];
        [cell bindCellWithWalletData:walletData asset:asset isSelecterd:[walletData isEqual:self.walletData]];
        return cell;
    };
    
    self.optionCellHeight = ^float(NSIndexPath *indexPath) {
        return FitScale(65);
    };
    
    self.selectedOption = ^(NSIndexPath *indexPath) {
        @strongify(self)
        CCWalletData *walletData = self.coinData.wallets[indexPath.row];
        self.walletData = walletData;
        if (self.chooseWallet) {
            self.chooseWallet(walletData);
        }
    };
    
    self.rowNumber = ^NSInteger{
        @strongify(self)
        return self.coinData.wallets.count;
    };
}

@end

@implementation CCChangeWalletCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.nameLab];
        [self.nameLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView.mas_left).offset(FitScale(15));
            make.top.equalTo(self.contentView.mas_top).offset(FitScale(20));
        }];
        
        [self.contentView addSubview:self.typeLab];
        [self.typeLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.nameLab.mas_right).offset(FitScale(15));
            make.centerY.equalTo(self.nameLab.mas_centerY);
            make.right.lessThanOrEqualTo(self.contentView.mas_right).offset(-FitScale(15));
        }];
        
        [self.contentView addSubview:self.addressLab];
        [self.addressLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.nameLab.mas_left);
            make.top.equalTo(self.nameLab.mas_bottom).offset(FitScale(6));
            make.width.mas_equalTo(FitScale(125));
        }];
        
        [self.contentView addSubview:self.balanceLab];
        [self.balanceLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView.mas_right).offset(-FitScale(15));
            make.centerY.equalTo(self.addressLab.mas_centerY);
            make.left.greaterThanOrEqualTo(self.addressLab.mas_right).offset(FitScale(10));
        }];
        
        [self.contentView addSubview:self.lineView];
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.nameLab.mas_left);
            make.right.equalTo(self.balanceLab.mas_right);
            make.bottom.equalTo(self.contentView.mas_bottom);
            make.height.mas_equalTo(.5);
        }];
    }
    return self;
}

- (void)bindCellWithWalletData:(CCWalletData *)walletData asset:(CCAsset *)asset isSelecterd:(BOOL)isSelected {
    self.nameLab.text = walletData.walletName;
    
    if (walletData.importType == CCImportTypeSeed || walletData.importType == CCImportTypeMnemonic) {
        self.typeLab.text = [NSString stringWithFormat:@"HDM44 0/%hd",walletData.wallet.slot];
    } else {
        self.typeLab.text = @"";
    }
    
    self.addressLab.text = walletData.address;
    if (asset) {
        self.balanceLab.text = [NSString stringWithFormat:@"%@:%@%@",Localized(@"Balance"),asset.balance,asset.tokenSynbol];
    } else {
        self.balanceLab.text = @"--";
    }
    
    if (isSelected) {
        self.nameLab.textColor = self.typeLab.textColor = self.addressLab.textColor = self.balanceLab.textColor = CC_BTN_ENABLE_COLOR;
        self.lineView.backgroundColor = CC_BTN_ENABLE_COLOR;
    } else {
        self.typeLab.textColor = self.addressLab.textColor = CC_GRAY_TEXTCOLOR;
        self.nameLab.textColor = self.balanceLab.textColor = CC_BLACK_COLOR;
        self.lineView.backgroundColor = CC_GRAY_LINECOLOR;
    }
}

- (UILabel *)nameLab {
    if (!_nameLab) {
        _nameLab = [[UILabel alloc] init];
        _nameLab.textColor = CC_BLACK_COLOR;
        _nameLab.font = MediumFont(FitScale(13));
    }
    return _nameLab;
}

- (UILabel *)typeLab {
    if (!_typeLab) {
        _typeLab = [[UILabel alloc] init];
        _typeLab.textColor = CC_GRAY_TEXTCOLOR;
        _typeLab.font = MediumFont(FitScale(12));
    }
    return _typeLab;
}

- (UILabel *)addressLab {
    if (!_addressLab) {
        _addressLab = [[UILabel alloc] init];
        _addressLab.textColor = CC_GRAY_TEXTCOLOR;
        _addressLab.font = MediumFont(FitScale(11));
        _addressLab.lineBreakMode = NSLineBreakByTruncatingMiddle;
    }
    return _addressLab;
}

- (UILabel *)balanceLab {
    if (!_balanceLab) {
        _balanceLab = [[UILabel alloc] init];
        _balanceLab.textColor = CC_BLACK_COLOR;
        _balanceLab.font = MediumFont(FitScale(13));
        _balanceLab.lineBreakMode = NSLineBreakByTruncatingMiddle;
    }
    return _balanceLab;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
    }
    return _lineView;
}

@end
