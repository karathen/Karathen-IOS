//
//  CCAsseListCell.m
//  ccAsset
//
//  Created by 孟利明 on 2018/7/27.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCAsseListCell.h"

@interface CCAsseListCell ()

@property (nonatomic, strong) UIImageView *iconImgView;
@property (nonatomic, strong) UILabel *nameLab;
@property (nonatomic, strong) UILabel *detailLab;
@property (nonatomic, strong) UIButton *selectedBtn;

@end

@implementation CCAsseListCell

- (void)bindCellWithAsset:(CCAsset *)asset {
    self.nameLab.text = asset.tokenSynbol;
    self.detailLab.text = asset.tokenName;
    self.balanceLab.text = asset.balanceString;
    if (asset.price.doubleValue == 0) {
        self.priceLab.text = @"--";
    } else {
        self.priceLab.text = [NSString stringWithFormat:@"￥ %@",asset.priceBalanceString];
    }
}

#pragma mark - super method
- (void)createView {
    [super createView];
    
    [self.contentView addSubview:self.iconImgView];
    [self.iconImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(FitScale(14));
        make.centerY.equalTo(self.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(FitScale(35), FitScale(35)));
    }];
    
    [self.contentView addSubview:self.nameLab];
    [self.nameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconImgView.mas_right).offset(FitScale(10));
        make.bottom.equalTo(self.contentView.mas_centerY).offset(-FitScale(3));
    }];
    
    [self.contentView addSubview:self.detailLab];
    [self.detailLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameLab.mas_left);
        make.top.equalTo(self.contentView.mas_centerY).offset(FitScale(3));
    }];
    
    [self.contentView addSubview:self.selectedBtn];
    [self.selectedBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.right.equalTo(self.contentView);
        make.width.mas_equalTo(FitScale(50));
    }];
}


#pragma mark - get
- (UIImageView *)iconImgView {
    if (!_iconImgView) {
        _iconImgView = [[UIImageView alloc] init];
        [_iconImgView setImage:[UIImage imageNamed:@"cc_asset_eth"]];
        _iconImgView.contentMode = UIViewContentModeCenter;
    }
    return _iconImgView;
}

- (UILabel *)nameLab {
    if (!_nameLab) {
        _nameLab = [[UILabel alloc] init];
        _nameLab.textColor = RGB(0x333333);
        _nameLab.font = MediumFont(FitScale(12));
    }
    return _nameLab;
}

- (UILabel *)detailLab {
    if (!_detailLab) {
        _detailLab = [[UILabel alloc] init];
        _detailLab.textColor = RGB(0x90939b);
        _detailLab.font = MediumFont(FitScale(10));
    }
    return _detailLab;
}

- (UIButton *)selectedBtn {
    if (!_selectedBtn) {
        _selectedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_selectedBtn setImage:[UIImage imageNamed:@"cc_addAsset_deSel"] forState:UIControlStateNormal];
        [_selectedBtn setImage:[UIImage imageNamed:@"cc_addAsset_sel"] forState:UIControlStateSelected];
    }
    return _selectedBtn;
}

@end
