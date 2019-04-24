//
//  CCWalletEditView.m
//  ccAsset
//
//  Created by SealWallet on 2018/7/17.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCWalletEditView.h"

@interface CCWalletEditView ()


@end

@implementation CCWalletEditView

#pragma mark - init
- (instancetype)init {
    return [self initWithTitle:nil placeholder:nil];
}

- (instancetype)initWithTitle:(NSString *)title placeholder:(NSString *)placeHolder {
    if (self = [super init]) {
        self.title = title;
        self.placeholder = placeHolder;
        [self createView];
    }
    return self;
}

#pragma mark - createView
- (void)createView {
    [self addSubview:self.lineView];
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(FitScale(14));
        make.bottom.equalTo(self.mas_bottom);
        make.right.equalTo(self.mas_right).offset(-FitScale(10));
    }];
    
    [self addSubview:self.titleLab];
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(FitScale(17));
        make.top.equalTo(self.mas_top).offset(FitScale(19));
        make.right.lessThanOrEqualTo(self.lineView.mas_right);
    }];
    
    [self addSubview:self.descLab];
    [self.descLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLab.mas_left);
        make.top.equalTo(self.titleLab.mas_bottom).offset(FitScale(10));
        make.bottom.lessThanOrEqualTo(self.mas_bottom).offset(-FitScale(10));
        make.right.lessThanOrEqualTo(self.lineView.mas_right);
    }];


}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleLab.text = title;
}

- (void)setPlaceholder:(NSString *)placeholder {
    _placeholder = placeholder;
    self.descLab.text = placeholder;
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

- (UILabel *)descLab {
    if (!_descLab) {
        _descLab = [[UILabel alloc] init];
        _descLab.font = MediumFont(FitScale(14));
        _descLab.textColor = RGB(0xc6c5cb);
        _descLab.numberOfLines = 0;
    }
    return _descLab;
}

- (UIImageView *)lineView {
    if (!_lineView) {
        _lineView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cc_cell_line"]];
    }
    return _lineView;
}

@end
