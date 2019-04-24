//
//  CCWalletTextFieldEditView.m
//  ccAsset
//
//  Created by SealWallet on 2018/7/12.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCWalletTextFieldEditView.h"

@interface CCWalletTextFieldEditView ()

@property (nonatomic, strong) NumberTF *textField;

@end

@implementation CCWalletTextFieldEditView

- (NSString *)text {
    return [self.textField.text deleteSpace];
}

- (void)setText:(NSString *)text {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.textField.text = text;
        [self editBegin];
    });
}

- (void)clearText {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.textField.text = @"";
        if (self.textField.isFirstResponder) {
            self.descLab.hidden = YES;
            self.descLab.numberOfLines = 1;
        } else {
            self.descLab.hidden = NO;
            self.descLab.numberOfLines = 0;
        }
    });
}

#pragma mark - createView
- (void)createView {
    [super createView];
    [self addSubview:self.textField];
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.descLab.mas_left);
        make.right.equalTo(self.lineView.mas_right);
        make.top.equalTo(self.titleLab.mas_bottom);
        make.bottom.lessThanOrEqualTo(self.mas_bottom);
        make.height.mas_equalTo(FitScale(35));
    }];
    
    @weakify(self)
    _textField.showBegin = ^{
        @strongify(self)
        [self editBegin];
    };
    
    _textField.showEnd = ^{
        @strongify(self)
        [self editEnd];
    };

    _textField.backText = ^(NSString *text) {
        @strongify(self)
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.delegate && [self.delegate respondsToSelector:@selector(textChangeInfoView:)]) {
                [self.delegate textChangeInfoView:self];
            }
        });
    };
}

- (void)editBegin {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self.descLab.hidden) {
            self.descLab.hidden = YES;
            self.descLab.numberOfLines = 1;
        }
    });
}

- (void)editEnd {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.textField.text.length) {
            self.descLab.hidden = YES;
            self.descLab.numberOfLines = 1;
        } else {
            self.descLab.hidden = NO;
            self.descLab.numberOfLines = 0;
        }
    });
}

#pragma mark - get
- (NumberTF *)textField {
    if (!_textField) {
        _textField = [[NumberTF alloc] init];
        _textField.onlyNum = NO;
        _textField.font = MediumFont(FitScale(14));
        _textField.textColor = CC_BLACK_COLOR;
    }
    return  _textField;
}

@end
