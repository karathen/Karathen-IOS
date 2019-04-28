//
//  KarathenSearchView.m
//  Karathen
//
//  Created by Karathen on 2018/9/3.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCAssetSearchView.h"
@interface CCAssetSearchView () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIButton *searchBtn;

@end


@implementation CCAssetSearchView

- (instancetype)init {
    if (self = [super init]) {
        [self createView];
    }
    return self;
}

- (void)createView {
    [self addSubview:self.searchBtn];
    [self.searchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.right.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(FitScale(30), FitScale(30)));
        make.left.greaterThanOrEqualTo(self.mas_left);
    }];
    
    [self addSubview:self.textField];
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.centerY.equalTo(self.mas_centerY);
        make.right.equalTo(self.searchBtn.mas_left);
        make.top.equalTo(self.mas_top).offset(FitScale(3));
    }];
    
    @weakify(self)
    [self.searchBtn cc_tapHandle:^{
        @strongify(self)
        if (self.textField.isFirstResponder) {
            [self textFieldShouldReturn:self.textField];
        } else {
            [self.textField becomeFirstResponder];
        }
    }];
    
    [self.textField addTarget:self action:@selector(textChange) forControlEvents:UIControlEventEditingChanged];
}

- (void)textChange {
    if (self.delegate && [self.delegate respondsToSelector:@selector(textFieldSearch:keyword:)]) {
        [self.delegate textFieldSearch:self keyword:self.textField.text];
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField.text.length) {
        textField.text = @"";
        [self textChange];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(textFieldBeginEdit:)]) {
        [self.delegate textFieldBeginEdit:self];
    }
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if (self.delegate && [self.delegate respondsToSelector:@selector(textFieldEndEdit:)]) {
        [self.delegate textFieldEndEdit:self];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.textField resignFirstResponder];
    if (self.delegate && [self.delegate respondsToSelector:@selector(textFieldSearch:keyword:)]) {
        [self.delegate textFieldSearch:self keyword:self.textField.text];
    }
    return YES;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
 
    return YES;
}
#pragma mark - get
- (UITextField *)textField {
    if (!_textField) {
        _textField = [[UITextField alloc] init];
        _textField.textColor = CC_BLACK_COLOR;
        _textField.font = MediumFont(FitScale(13));
        _textField.delegate = self;
        _textField.returnKeyType = UIReturnKeySearch;
        _textField.leftViewMode = UITextFieldViewModeAlways;
        _textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, FitScale(10), 0)];
    }
    return _textField;
}

- (UIButton *)searchBtn {
    if (!_searchBtn) {
        _searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_searchBtn setImage:[UIImage imageNamed:@"cc_search_right"] forState:UIControlStateNormal];
    }
    return _searchBtn;
}


@end
