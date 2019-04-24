//
//  CCWalletListCell.m
//  ccAsset
//
//  Created by SealWallet on 2018/7/19.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCWalletListCell.h"

@interface CCWalletListCell ()

@property (nonatomic, strong) UILabel *userNameLab;
@property (nonatomic, strong) UILabel *addressLab;

@end

@implementation CCWalletListCell

- (void)bindCellWithWallet:(CCWalletData *)wallet {
    self.userNameLab.text = wallet.walletName;
    self.addressLab.text = wallet.address;
}

#pragma mark - super method
- (void)createView {
    [super createView];
    
    [self.contentView addSubview:self.userNameLab];
    [self.userNameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(FitScale(17));
        make.top.equalTo(self.contentView.mas_top).offset(FitScale(15));
        make.right.lessThanOrEqualTo(self.contentView.mas_right).offset(-FitScale(10));
    }];
    
    [self.contentView addSubview:self.addressLab];
    [self.addressLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.userNameLab.mas_left);
        make.top.equalTo(self.userNameLab.mas_bottom).offset(FitScale(6));
        make.right.lessThanOrEqualTo(self.contentView.mas_right).offset(-FitScale(10));
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-FitScale(12));
    }];
}

#pragma mark - get
- (UILabel *)userNameLab {
    if (!_userNameLab) {
        _userNameLab = [[UILabel alloc] init];
        _userNameLab.textColor = CC_BLACK_COLOR;
        _userNameLab.font = MediumFont(FitScale(13));
    }
    return _userNameLab;
}

- (UILabel *)addressLab {
    if (!_addressLab) {
        _addressLab = [[UILabel alloc] init];
        _addressLab.textColor = CC_GRAY_TEXTCOLOR;
        _addressLab.font = MediumFont(FitScale(12));
    }
    return _addressLab;
}

@end
