//
//  CCSearchView.m
//  ccAsset
//
//  Created by SealWallet on 2018/7/26.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCSearchView.h"
#import "AttributeMaker.h"

@interface CCSearchView () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIButton *cancleBtn;

@end

@implementation CCSearchView

- (instancetype)init {
    if (self = [super init]) {
        [self createView];
    }
    return self;
}

- (NSString *)text {
    return self.textField.text;
}

#pragma mark - createView
- (void)createView {
    [self.textField addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];

    [self addSubview:self.cancleBtn];
    [self.cancleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.right.equalTo(self);
        make.width.mas_equalTo(0);
    }];
    
    [self addSubview:self.textField];
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(self);
        make.right.equalTo(self.cancleBtn.mas_left);
    }];
    
    @weakify(self)
    [self.cancleBtn cc_tapHandle:^{
        @strongify(self)
        [self cancelAction];
    }];
}

#pragma mark - action
- (void)cancelAction {
    [self.textField resignFirstResponder];
    self.textField.text = @"";
    [self.cancleBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(0);
    }];
    [UIView animateWithDuration:.1 animations:^{
        [self layoutIfNeeded];
    }];
    if (self.delegate && [self.delegate respondsToSelector:@selector(cancelSearchView:)]) {
        [self.delegate cancelSearchView:self];
    }
}

#pragma mark - notify
- (void)textFieldDidChange {
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchActionSearchView:)]) {
        [self.delegate searchActionSearchView:self];
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self.cancleBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(FitScale(50));
    }];
    [UIView animateWithDuration:.1 animations:^{
        [self layoutIfNeeded];
    }];
    if (self.delegate && [self.delegate respondsToSelector:@selector(beginSearchView:)]) {
        [self.delegate beginSearchView:self];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchActionSearchView:)]) {
        [self.delegate searchActionSearchView:self];
    }
    return YES;
}

//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//
//    });
//
//    return YES;
//}

#pragma mark - set
- (void)setPlaceholder:(NSString *)placeholder {
    _placeholder = placeholder;
    self.textField.attributedPlaceholder = [AttributeMaker attributeMaker:^(AttributeMaker *maker) {
        maker.text(placeholder)
        .textFont(MediumFont(FitScale(12)))
        .textColor(RGB(0x89888D));
    }];
}

- (void)setCancleTitle:(NSString *)cancleTitle {
    _cancleTitle = cancleTitle;
    [self.cancleBtn setTitle:cancleTitle forState:UIControlStateNormal];
}

#pragma mark - get
- (UIButton *)cancleBtn {
    if (!_cancleBtn) {
        _cancleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancleBtn setTitleColor:CC_BLACK_COLOR forState:UIControlStateNormal];
        _cancleBtn.titleLabel.font = MediumFont(FitScale(13));
    }
    return _cancleBtn;
}

- (UITextField *)textField {
    if (!_textField) {
        _textField = [[UITextField alloc] init];
        _textField.textColor = CC_BLACK_COLOR;
        _textField.backgroundColor = RGB(0xF1F2F4);
        _textField.font = MediumFont(FitScale(13));
        _textField.returnKeyType = UIReturnKeySearch;
        _textField.layer.cornerRadius = FitScale(4);
        _textField.layer.masksToBounds = YES;
        _textField.delegate = self;
        
        UIButton *leftImgView = [UIButton buttonWithType:UIButtonTypeCustom];
        [leftImgView setImage:[UIImage imageNamed:@"cc_search_left"] forState:UIControlStateNormal];
        leftImgView.userInteractionEnabled = NO;
        leftImgView.frame = CGRectMake(0, 0, FitScale(30), FitScale(30));
        _textField.leftViewMode = UITextFieldViewModeAlways;
        _textField.leftView = leftImgView;
    }
    return _textField;
}

@end
