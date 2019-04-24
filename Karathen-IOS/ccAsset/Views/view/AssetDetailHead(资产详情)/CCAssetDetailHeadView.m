//
//  CCAssetDetailHeadView.m
//  ccAsset
//
//  Created by SealWallet on 2018/7/23.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCAssetDetailHeadView.h"
#import "CCGradientView.h"

@interface CCAssetDetailHeadView ()

@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) CCGradientView *bottomView;
@property (nonatomic, strong) UILabel *balanceLab;
@property (nonatomic, strong) UILabel *priceLab;
@property (nonatomic, strong) UIButton *transferBtn;
@property (nonatomic, strong) UIButton *receiveBtn;

@end

@implementation CCAssetDetailHeadView

- (instancetype)init {
    if (self = [super init]) {
        [self createView];
    }
    return self;
}

- (void)reloadHead {
    [self.transferBtn setTitle:[NSString stringWithFormat:@"%@",Localized(@"Transfer")] forState:UIControlStateNormal];
    
    [self.receiveBtn setTitle:[NSString stringWithFormat:@"%@",Localized(@"Receive")] forState:UIControlStateNormal];

}

- (void)reloadDataWithAsset:(CCAsset *)asset {
    self.balanceLab.text = [CCWalletData balanceStringWithAsset:asset];
    NSString *unit = [[CCCurrencyUnit currentCurrencyUnit] isEqualToString:CCCurrencyUnitCNY]?@"￥":@"$";
    self.priceLab.text = [NSString stringWithFormat:@"≈%@ %@",unit,[CCWalletData priceBalanceStringWithAsset:asset]];
}

- (void)changeBackWithOffset:(CGPoint)offset {
    self.backView.frame = CGRectMake(0, offset.y, SCREEN_WIDTH, self.cc_height-offset.y);
}

#pragma mark - createView
- (void)createView {
    self.layer.zPosition = -1;
    [self addSubview:self.backView];
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).insets(UIEdgeInsetsMake(0, 0, FitScale(3), 0));
    }];
    
    [self addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.top.equalTo(self.backView.mas_bottom);
    }];
    
    [self addSubview:self.balanceLab];
    [self.balanceLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.top.equalTo(self.mas_top).offset(FitScale(34));
        make.left.greaterThanOrEqualTo(self.mas_left).offset(FitScale(20));
    }];
    
    [self addSubview:self.priceLab];
    [self.priceLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.top.equalTo(self.balanceLab.mas_bottom).offset(FitScale(16));
        make.left.greaterThanOrEqualTo(self.mas_left).offset(FitScale(20));
    }];
    
    [self addSubview:self.receiveBtn];
    [self.receiveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left);
        make.bottom.equalTo(self.backView.mas_bottom);
        make.height.mas_equalTo(FitScale(50));
    }];
    
    [self addSubview:self.transferBtn];
    [self.transferBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.receiveBtn.mas_right);
        make.right.equalTo(self.mas_right);
        make.bottom.equalTo(self.receiveBtn.mas_bottom);
        make.size.equalTo(self.receiveBtn);
    }];
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = [UIColor whiteColor];
    [self addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.centerY.equalTo(self.transferBtn.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(1, FitScale(28)));
    }];
    
    @weakify(self)
    [self.transferBtn cc_tapHandle:^{
        @strongify(self)
        if (self.delegate && [self.delegate respondsToSelector:@selector(transferHeadView:)]) {
            [self.delegate transferHeadView:self];
        }
    }];
    
    [self.receiveBtn cc_tapHandle:^{
        @strongify(self)
        if (self.delegate && [self.delegate respondsToSelector:@selector(receiveHeadView:)]) {
            [self.delegate receiveHeadView:self];
        }
    }];
    
    [self reloadHead];
}

#pragma mark - get
- (UIView *)backView {
    if (!_backView) {
        _backView = [[UIView alloc] init];
        _backView.backgroundColor = CC_BTN_ENABLE_COLOR;
    }
    return _backView;
}

- (CCGradientView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[CCGradientView alloc] init];
        _bottomView.backgroundColor = [UIColor whiteColor];
        _bottomView.colors = @[(__bridge id)RGB_ALPHA(0x7886F7, .5).CGColor,(__bridge id)RGB_ALPHA(0x7886F7, 0).CGColor];
        _bottomView.startPoint = CGPointMake(0.5, 0);
        _bottomView.endPoint = CGPointMake(0.5, 1);
        _bottomView.locations = @[@.2];
        [_bottomView drawGradient];
    }
    return _bottomView;
}

- (UILabel *)balanceLab {
    if (!_balanceLab) {
        _balanceLab = [[UILabel alloc] init];
        _balanceLab.textColor = [UIColor whiteColor];
        _balanceLab.font = BoldFont(FitScale(29));
    }
    return _balanceLab;
}

- (UILabel *)priceLab {
    if (!_priceLab) {
        _priceLab = [[UILabel alloc] init];
        _priceLab.textColor = [UIColor whiteColor];
        _priceLab.font = MediumFont(FitScale(17));
    }
    return _priceLab;
}

- (UIButton *)transferBtn {
    if (!_transferBtn) {
        _transferBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_transferBtn setImage:[UIImage imageNamed:@"cc_wallet_transfer"] forState:UIControlStateNormal];
        [_transferBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _transferBtn.titleLabel.font = MediumFont(FitScale(15));
        _transferBtn.backgroundColor = RGB(0x7886F7);
        [_transferBtn setImageEdgeInsets:UIEdgeInsetsMake(0, FitScale(-3), 0, 0)];
        [_transferBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, FitScale(3), 0, 0)];
    }
    return _transferBtn;
}

- (UIButton *)receiveBtn {
    if (!_receiveBtn) {
        _receiveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_receiveBtn setImage:[UIImage imageNamed:@"cc_wallet_receive"] forState:UIControlStateNormal];
        [_receiveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _receiveBtn.titleLabel.font = MediumFont(FitScale(15));
        _receiveBtn.backgroundColor = RGB(0x7886F7);
        [_receiveBtn setImageEdgeInsets:UIEdgeInsetsMake(0, FitScale(-3), 0, 0)];
        [_receiveBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, FitScale(3), 0, 0)];
    }
    return _receiveBtn;
}

@end
