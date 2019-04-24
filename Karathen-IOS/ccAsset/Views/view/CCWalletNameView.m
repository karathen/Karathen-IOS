//
//  CCWalletNameView.m
//  ccAsset
//
//  Created by SealWallet on 2018/9/4.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCWalletNameView.h"

@interface CCWalletNameView ()

@property (nonatomic, strong) UIImageView *lineView;

@end

@implementation CCWalletNameView

- (instancetype)init {
    if (self = [super init]) {
        [self createView];
    }
    return self;
}

#pragma mark - createView
- (void)createView {
    [self addSubview:self.textField];
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(FitScale(20));
        make.centerX.equalTo(self.mas_centerX);
        make.top.equalTo(self.mas_top);
        make.height.mas_equalTo(FitScale(35));
    }];
    
    [self addSubview:self.lineView];
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(FitScale(20));
        make.centerX.equalTo(self.mas_centerX);
        make.top.equalTo(self.textField.mas_bottom);
    }];
    
    [self addSubview:self.descLab];
    [self.descLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(FitScale(20));
        make.centerX.equalTo(self.mas_centerX);
        make.top.equalTo(self.lineView.mas_bottom).offset(FitScale(15));
        make.bottom.equalTo(self.mas_bottom).offset(-FitScale(15));
    }];
}

#pragma mark - get
- (UITextField *)textField {
    if (!_textField) {
        _textField = [[UITextField alloc] init];
        _textField.textColor = CC_BLACK_COLOR;
        _textField.font = MediumFont(FitScale(14));
    }
    return _textField;
}

- (UIImageView *)lineView {
    if (!_lineView) {
        _lineView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cc_cell_line"]];
    }
    return _lineView;
}

- (UILabel *)descLab {
    if (!_descLab) {
        _descLab = [[UILabel alloc] init];
        _descLab.textColor = CC_GRAY_TEXTCOLOR;
        _descLab.font = MediumFont(FitScale(12));
        _descLab.text = Localized(@"Meaningful names could help you manage assets better");
    }
    return _descLab;
}

@end
