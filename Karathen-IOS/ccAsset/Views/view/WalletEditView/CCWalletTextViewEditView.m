//
//  CCWalletTextViewEditView.m
//  ccAsset
//
//  Created by SealWallet on 2018/7/17.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCWalletTextViewEditView.h"
#import "UITextView+MLMTextView.h"

@interface CCWalletTextViewEditView () <UITextViewDelegate>

@property (nonatomic, strong) CCTextView *textView;

@end

@implementation CCWalletTextViewEditView

- (NSString *)text {
    return self.textView.text;
}


#pragma mark - createView
- (void)createView {
    [super createView];
    [self addSubview:self.textView];
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.descLab.mas_left).offset(-4);
        make.right.equalTo(self.lineView.mas_right);
        make.top.equalTo(self.titleLab.mas_bottom).offset(FitScale(2.5));
        make.bottom.lessThanOrEqualTo(self.mas_bottom);
        make.height.mas_equalTo(FitScale(90));
    }];
    
    @weakify(self)
    _textView.textDidChange = ^(NSString *text) {
        @strongify(self)
        if (self.delegate && [self.delegate respondsToSelector:@selector(textChangeInfoView:)]) {
            [self.delegate textChangeInfoView:self];
        }
    };
}

#pragma mark - UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView {
    if (!self.descLab.hidden) {
        self.descLab.hidden = YES;
        self.descLab.numberOfLines = 1;
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (self.textView.text.length) {
        self.descLab.hidden = YES;
        self.descLab.numberOfLines = 1;
    } else {
        self.descLab.hidden = NO;
        self.descLab.numberOfLines = 0;
    }
}

#pragma mark - get
- (CCTextView *)textView {
    if (!_textView) {
        _textView = [[CCTextView alloc] init];
        _textView.font = MediumFont(FitScale(14));
        _textView.textColor = CC_BLACK_COLOR;
        _textView.backgroundColor = [UIColor clearColor];
        _textView.delegate = self;
    }
    return _textView;
}

@end
