//
//  CCWallteAssetBallanceCell.m
//  Karathen
//
//  Created by Karathen on 2018/7/20.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCWallteAssetBallanceCell.h"

@interface CCWallteAssetBallanceCell ()

@property (nonatomic, strong) UIImageView *iconImgView;
@property (nonatomic, strong) UILabel *nameLab;
@property (nonatomic, strong) UILabel *detailLab;
@property (nonatomic, strong) UILabel *priceLab;
@property (nonatomic, strong) UILabel *balanceLab;
@property (nonatomic, strong) UIButton *expandBtn;
@property (nonatomic, weak) CCAsset *asset;

@end

@implementation CCWallteAssetBallanceCell

- (void)bindCellWithAsset:(CCAsset *)asset walletData:(CCWalletData *)walletData {
    self.asset = asset;
    self.nameLab.text = asset.tokenSynbol;
    self.detailLab.text = asset.tokenName;
    self.balanceLab.text = [CCWalletData balanceStringWithAsset:asset];
    if ([[CCCurrencyUnit currentCurrencyUnit] isEqualToString:CCCurrencyUnitCNY]) {
        if (asset.price.doubleValue == 0) {
            self.priceLab.text = @"--";
        } else {
            self.priceLab.text = [NSString stringWithFormat:@"￥ %@",[CCWalletData priceBalanceStringWithAsset:asset]];
        }
    } else {
        if (asset.priceUSD.doubleValue == 0) {
            self.priceLab.text = @"--";
        } else {
            self.priceLab.text = [NSString stringWithFormat:@"$ %@",[CCWalletData priceBalanceStringWithAsset:asset]];
        }
    }

    [walletData bindImageView:self.iconImgView asset:asset];
}

#pragma mark - super method
- (void)createView {
    [super createView];
    
    [self.contentView addSubview:self.iconImgView];
    [self.iconImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(FitScale(14));
        make.centerY.equalTo(self.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(FitScale(18), FitScale(18)));
    }];
    
    [self.contentView addSubview:self.nameLab];
    [self.nameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconImgView.mas_right).offset(FitScale(15));
        make.bottom.equalTo(self.contentView.mas_centerY).offset(-FitScale(3));
        make.width.mas_greaterThanOrEqualTo(FitScale(40));
    }];
    
    [self.contentView addSubview:self.detailLab];
    [self.detailLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameLab.mas_left);
        make.top.equalTo(self.contentView.mas_centerY).offset(FitScale(3));
        make.width.mas_greaterThanOrEqualTo(FitScale(40));
    }];
    
    [self.contentView addSubview:self.expandBtn];
    [self.expandBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.top.bottom.equalTo(self.contentView);
        make.width.mas_equalTo(FitScale(30));
    }];
    
    [self.contentView addSubview:self.balanceLab];
    [self.balanceLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.expandBtn.mas_left);
        make.bottom.equalTo(self.nameLab.mas_bottom);
        make.left.greaterThanOrEqualTo(self.nameLab.mas_right).offset(FitScale(10));
    }];
    
    [self.contentView addSubview:self.priceLab];
    [self.priceLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.balanceLab.mas_right);
        make.top.equalTo(self.detailLab.mas_top);
        make.left.greaterThanOrEqualTo(self.detailLab.mas_right).offset(FitScale(10));
    }];
    
    [self.balanceLab setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.priceLab setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];

    @weakify(self)
    [self.expandBtn cc_tapHandle:^{
        @strongify(self)
        if (self.showAssetDetail) {
            self.showAssetDetail(self.asset,self.expandBtn);
        }
    }];

}


#pragma mark - get
- (UIImageView *)iconImgView {
    if (!_iconImgView) {
        _iconImgView = [[UIImageView alloc] init];
        _iconImgView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _iconImgView;
}

- (UILabel *)nameLab {
    if (!_nameLab) {
        _nameLab = [[UILabel alloc] init];
        _nameLab.textColor = CC_BLACK_COLOR;
        _nameLab.font = MediumFont(FitScale(14));
        _nameLab.lineBreakMode = NSLineBreakByTruncatingMiddle;
    }
    return _nameLab;
}

- (UILabel *)detailLab {
    if (!_detailLab) {
        _detailLab = [[UILabel alloc] init];
        _detailLab.textColor = RGB(0x90939b);
        _detailLab.font = MediumFont(FitScale(11));
        _detailLab.lineBreakMode = NSLineBreakByTruncatingMiddle;
    }
    return _detailLab;
}

- (UILabel *)balanceLab {
    if (!_balanceLab) {
        _balanceLab = [[UILabel alloc] init];
        _balanceLab.textColor = CC_BLACK_COLOR;
        _balanceLab.font = MediumFont(FitScale(14));
    }
    return _balanceLab;
}

- (UILabel *)priceLab {
    if (!_priceLab) {
        _priceLab = [[UILabel alloc] init];
        _priceLab.textColor = RGB(0x90939b);
        _priceLab.font = MediumFont(FitScale(12));
    }
    return _priceLab;
}

- (UIButton *)expandBtn {
    if (!_expandBtn) {
        _expandBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_expandBtn setImage:[UIImage imageNamed:@"cc_more_h_point"] forState:UIControlStateNormal];
    }
    return _expandBtn;
}

@end
