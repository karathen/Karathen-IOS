//
//  CCContentHintView.m
//  Karathen
//
//  Created by Karathen on 2018/7/16.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCContentHintView.h"

#import "AttributeMaker.h"

@interface CCContentHintView ()

@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UILabel *contenLab;
@property (nonatomic, strong) UIButton *sureBtn;
@property (nonatomic, strong) UIButton *cancelBtn;

@property (nonatomic, strong) UIView *cover;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *content;

@end

@implementation CCContentHintView

+ (CCContentHintView *)hintViewWithTitle:(NSString *)title content:(NSString *)content {
    CCContentHintView *hintView = [[CCContentHintView alloc] init];
    hintView.title = title;
    hintView.content = content;
    [hintView createView];
    return hintView;
}

#pragma mark - show/hidden
- (void)showView {
    [self showViewInView:[UIApplication sharedApplication].keyWindow];
}

- (void)showViewInView:(UIView *)view {
    [view addSubview:self.cover];
    [self.cover mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(view);
    }];
    
    [view addSubview:self];
    [self mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(view.mas_centerX);
        make.top.equalTo(view.mas_bottom);
        make.left.equalTo(view.mas_left).offset(FitScale(40));
    }];
    
    [view layoutIfNeeded];
    [self mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(view.mas_centerX);
        make.top.equalTo(view.mas_top).offset(FitScale(135) + STATUS_AND_NAVIGATION_HEIGHT);
        make.left.equalTo(view.mas_left).offset(FitScale(40));
    }];
    
    self.cover.alpha = 0;
    
    [UIView animateWithDuration:.3 delay:0 usingSpringWithDamping:.8 initialSpringVelocity:10 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [view layoutIfNeeded];
        self.cover.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)hiddenView {
    [self mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.superview.mas_centerX);
        make.top.equalTo(self.superview.mas_bottom);
        make.left.equalTo(self.superview.mas_left).offset(FitScale(40));
    }];
    
    [UIView animateWithDuration:.3 animations:^{
        [self.superview layoutIfNeeded];
        self.cover.alpha = 0;
    } completion:^(BOOL finished) {
        [self.cover removeFromSuperview];
        [self removeFromSuperview];
    }];
    
}

#pragma mark - createView
- (void)createView {
    self.backgroundColor = [UIColor whiteColor];
    
    [self addSubview:self.titleLab];
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(FitScale(21));
        make.centerX.equalTo(self.mas_centerX);
    }];
    
    [self addSubview:self.contenLab];
    [self.contenLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.top.equalTo(self.titleLab.mas_bottom).offset(FitScale(20));
        make.left.equalTo(self.mas_left).offset(FitScale(35));
    }];
    
    [self addSubview:self.cancelBtn];
    [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contenLab.mas_bottom).offset(FitScale(27));
        make.left.equalTo(self.mas_left);
        make.bottom.equalTo(self.mas_bottom);
        make.height.mas_equalTo(FitScale(45));
    }];
    
    [self addSubview:self.sureBtn];
    [self.sureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.cancelBtn.mas_right);
        make.top.equalTo(self.cancelBtn.mas_top);
        make.size.equalTo(self.cancelBtn);
        make.right.equalTo(self.mas_right);
    }];
    
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = [UIColor whiteColor];
    [self addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.centerY.equalTo(self.sureBtn.mas_centerY);
        make.top.equalTo(self.sureBtn.mas_top).offset(FitScale(10));
        make.width.mas_equalTo(1);
    }];
    
    self.layer.cornerRadius = FitScale(8);
    self.layer.masksToBounds = YES;
    
    @weakify(self)
    [self.sureBtn cc_tapHandle:^{
        @strongify(self)
        [self hiddenView];
        if (self.delegate && [self.delegate respondsToSelector:@selector(hintViewConfirm:)]) {
            [self.delegate hintViewConfirm:self];
        }
    }];
    
    [self.cancelBtn cc_tapHandle:^{
        @strongify(self)
        [self hiddenView];
        if (self.delegate && [self.delegate respondsToSelector:@selector(hintViewCancel:)]) {
            [self.delegate hintViewCancel:self];
        }
    }];
    
    [self bindData];
}

- (void)bindData {
    self.titleLab.text = self.title;
    
    @weakify(self)
    self.contenLab.attributedText = [AttributeMaker attributeMaker:^(AttributeMaker *maker) {
        @strongify(self)
        NSString *text = self.content;
        NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
        paragraph.lineSpacing = FitScale(9);
        paragraph.alignment = NSTextAlignmentCenter;
        maker.text(text)
        .paragraph(paragraph);
    }];
    
    [self.sureBtn setTitle:Localized(@"Yes") forState:UIControlStateNormal];
    [self.cancelBtn setTitle:Localized(@"Cancel") forState:UIControlStateNormal];
}

- (void)changeTitle:(NSString *)title content:(NSString *)content {
    self.title = title;
    self.content = content;
    [self bindData];
}

#pragma mark - get
- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.textColor = CC_BTN_TITLE_COLOR;
        _titleLab.font = BoldFont(FitScale(18));
    }
    return _titleLab;
}

- (UILabel *)contenLab {
    if (!_contenLab) {
        _contenLab = [[UILabel alloc] init];
        _contenLab.textColor = CC_BLACK_COLOR;
        _contenLab.font = MediumFont(FitScale(13));
        _contenLab.numberOfLines = 0;
    }
    return _contenLab;
}

- (UIButton *)sureBtn {
    if (!_sureBtn) {
        _sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _sureBtn.backgroundColor = CC_BTN_ENABLE_COLOR;
        _sureBtn.titleLabel.font = MediumFont(FitScale(16));
        [_sureBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    return _sureBtn;
}

- (UIButton *)cancelBtn {
    if (!_cancelBtn) {
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelBtn.backgroundColor = CC_BTN_ENABLE_COLOR;
        _cancelBtn.titleLabel.font = MediumFont(FitScale(16));
        [_cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    return _cancelBtn;
}

- (UIView *)cover {
    if (!_cover) {
        _cover = [[UIView alloc] init];
        _cover.backgroundColor = [UIColor colorWithWhite:0 alpha:.6];
    }
    return _cover;
}

@end
