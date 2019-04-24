//
//  CCAccountTitleView.m
//  ccAsset
//
//  Created by SealWallet on 2018/11/28.
//  Copyright © 2018 raistone. All rights reserved.
//

#import "CCAccountTitleView.h"

@interface CCAccountTitleView ()

@property (nonatomic, strong) UIImageView *iconImgView;
@property (nonatomic, strong) UILabel *titleLab;

@end


@implementation CCAccountTitleView

- (instancetype)init {
    if (self = [super init]) {
        [self createView];
    }
    return self;
}

- (void)bindWithAccount:(CCAccountData *)accountData {
    NSString *icon = [accountData accountIcon];
    [self.iconImgView setImage:[UIImage imageNamed:icon]];
    
    self.titleLab.text = accountData.account.accountName;
}

#pragma mark - createView
- (void)createView {
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(NAVIGATION_BAR_HEIGHT);
    }];
    
    [self addSubview:self.iconImgView];
    [self.iconImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left);
        make.centerY.equalTo(self.mas_centerY);
    }];
    
    UIImageView *imageV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cc_more_list"]];
    [self addSubview:imageV];
    [imageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mas_centerY);
        make.right.equalTo(self.mas_right);
    }];
    
    
    [self addSubview:self.titleLab];
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconImgView.mas_right).offset(FitScale(8));
        make.top.bottom.equalTo(self);
        make.right.equalTo(imageV.mas_left).offset(FitScale(-8));
    }];
}

#pragma mark - get
- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.textColor = CC_BLACK_COLOR;
        _titleLab.font = BoldFont(FitScale(15));
        _titleLab.lineBreakMode = NSLineBreakByTruncatingMiddle;
    }
    return _titleLab;
}

- (UIImageView *)iconImgView {
    if (!_iconImgView) {
        _iconImgView = [[UIImageView alloc] init];
    }
    return _iconImgView;
}

@end
