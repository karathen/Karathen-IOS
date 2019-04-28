//
//  CCWalletInfoCell.m
//  Karathen
//
//  Created by Karathen on 2018/7/17.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCWalletInfoCell.h"

@interface CCWalletInfoCell ()

@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UILabel *detailLab;

@end

@implementation CCWalletInfoCell

- (void)bindCellTitle:(NSString *)title withDetail:(NSString *)detail {
    self.titleLab.text = title;
    self.detailLab.text = detail;
}

#pragma mark - super method
- (void)createView {
    [super createView];
    
    [self.contentView addSubview:self.titleLab];
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(FitScale(17));
        make.top.equalTo(self.contentView.mas_top).offset(FitScale(20));
    }];
    
    [self.contentView addSubview:self.detailLab];
    [self.detailLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLab.mas_left);
        make.top.equalTo(self.titleLab.mas_bottom).offset(FitScale(7));
        make.right.lessThanOrEqualTo(self.contentView.mas_right).offset(-FitScale(17));
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-FitScale(10));
    }];
}

#pragma mark - get
- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.font = MediumFont(FitScale(14));
        _titleLab.textColor = CC_BLACK_COLOR;
    }
    return _titleLab;
}

- (UILabel *)detailLab {
    if (!_detailLab) {
        _detailLab = [[UILabel alloc] init];
        _detailLab.font = MediumFont(FitScale(13));
        _detailLab.textColor = RGB(0xC6C5CB);
        _detailLab.numberOfLines = 0;
    }
    return _detailLab;
}

@end
