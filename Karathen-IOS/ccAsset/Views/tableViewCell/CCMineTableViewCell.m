//
//  CCMineTableViewCell.m
//  ccAsset
//
//  Created by SealWallet on 2018/9/6.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCMineTableViewCell.h"

@interface CCMineTableViewCell ()

@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UIImageView *moreImgView;
@property (nonatomic, strong) UIImageView *iconImgView;

@end


@implementation CCMineTableViewCell

- (void)bindCellWithTitle:(NSString *)title icon:(NSString *)icon {
    self.titleLab.text = title;
    [self.iconImgView setImage:[UIImage imageNamed:icon]];
}

#pragma mark - super method
- (void)createView {
    [super createView];
    
    [self.contentView addSubview:self.iconImgView];
    [self.iconImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(FitScale(17));
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
    
    [self.contentView addSubview:self.moreImgView];
    [self.moreImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).offset(-FitScale(18));
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
    
    [self.contentView addSubview:self.titleLab];
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconImgView.mas_right).offset(FitScale(14));
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.top.equalTo(self.contentView.mas_top).offset(FitScale(20));
        make.right.lessThanOrEqualTo(self.moreImgView.mas_left).offset(-FitScale(10));
    }];
}

#pragma mark - get
- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.font = MediumFont(FitScale(13));
        _titleLab.textColor = CC_BLACK_COLOR;
    }
    return _titleLab;
}

- (UIImageView *)iconImgView {
    if (!_iconImgView) {
        _iconImgView = [[UIImageView alloc] init];
    }
    return _iconImgView;
}

- (UIImageView *)moreImgView {
    if (!_moreImgView) {
        _moreImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cc_cell_more"]];
    }
    return _moreImgView;
}


@end
