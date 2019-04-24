//
//  CCTradeDetailTableViewCell.m
//  ccAsset
//
//  Created by SealWallet on 2018/8/3.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCTradeDetailTableViewCell.h"

@interface CCTradeDetailTableViewCell ()

@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UILabel *contentLab;
@property (nonatomic, strong) UIImageView *contentImgView;
@property (nonatomic, strong) UIButton *clipBtn;

@end

@implementation CCTradeDetailTableViewCell

- (void)bindCellWithTitle:(NSString *)title content:(NSString *)content image:(NSString *)image color:(UIColor *)color {
    self.titleLab.text = title;
    self.contentLab.text = content;
    [self.contentImgView setImage:image?[UIImage imageNamed:image]:nil];
    self.contentLab.textColor = color?:RGB(0xC6C5CB);
}

#pragma mark - super method
- (void)createView {
    [super createView];
    
    [self.contentView addSubview:self.titleLab];
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(FitScale(17));
        make.top.equalTo(self.contentView.mas_top).offset(FitScale(17));
    }];
    
    [self.contentView addSubview:self.contentImgView];
    [self.contentImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLab.mas_left);
        make.top.equalTo(self.titleLab.mas_bottom).offset(FitScale(7));
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-FitScale(9));
    }];
    
    [self.contentView addSubview:self.contentLab];
    [self.contentLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentImgView.mas_right).offset(FitScale(3));
        make.centerY.equalTo(self.contentImgView.mas_centerY);
    }];
    
    [self.contentView addSubview:self.clipBtn];
    [self.clipBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentLab.mas_centerY);
        make.left.equalTo(self.contentLab.mas_right);
        make.size.mas_equalTo(CGSizeMake(FitScale(26), FitScale(26)));
        make.right.lessThanOrEqualTo(self.contentView.mas_right).offset(-FitScale(20));
    }];
    
    @weakify(self)
    [self.clipBtn cc_tapHandle:^{
        @strongify(self)
        if (self.copyTxid) {
            self.copyTxid();
        }
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

- (UILabel *)contentLab {
    if (!_contentLab) {
        _contentLab = [[UILabel alloc] init];
        _contentLab.font = MediumFont(FitScale(13));
        _contentLab.textColor = RGB(0xC6C5CB);
        _contentLab.lineBreakMode = NSLineBreakByTruncatingMiddle;
    }
    return _contentLab;
}

- (UIImageView *)contentImgView {
    if (!_contentImgView) {
        _contentImgView = [[UIImageView alloc] init];
    }
    return _contentImgView;
}

- (UIButton *)clipBtn {
    if (!_clipBtn) {
        _clipBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_clipBtn setImage:[UIImage imageNamed:@"cc_black_copy"] forState:UIControlStateNormal];
        _clipBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _clipBtn.imageEdgeInsets = UIEdgeInsetsMake(0, FitScale(5), 0, 0);
    }
    return _clipBtn;
}

@end
