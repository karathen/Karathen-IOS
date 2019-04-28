//
//  CCAlertView.m
//  Karathen
//
//  Created by Karathen on 2018/7/16.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCAlertView.h"

@interface CCAlertView ()

@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UILabel *bottomBtn;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;

@property (nonatomic, strong) UIView *cover;

@end

@implementation CCAlertView

+ (CCAlertView *)alertViewMessage:(NSString *)message sureTitle:(NSString *)sureTitle withType:(CCAlertViewType)type {
    CCAlertView *view = [[CCAlertView alloc] init];
    view.type = type;
    view.message = message;
    view.sureTitle = sureTitle;
    [view createView];
    return view;
}

+ (void)showAlertWithMessage:(NSString *)message {
    CCAlertView *alertView = [CCAlertView alertViewMessage:message sureTitle:Localized(@"OK") withType:CCAlertViewTypeTextAlert];
    [alertView showView];
}


+ (CCAlertView *)showLoadingMessage:(NSString *)message inView:(UIView *)view {
    CCAlertView *alertView = [CCAlertView alertViewMessage:message sureTitle:nil withType:CCAlertViewTypeLoading];
    if (view) {
        [alertView showViewInView:view];
    } else {
        [alertView showView];
    }
    return alertView;
}

+ (CCAlertView *)showLoadingMessage:(NSString *)message {
    return [CCAlertView showLoadingMessage:message inView:nil];
}

+ (void)hidenAlertLoadingForView:(UIView *)view {
    CCAlertView *alertView = [self alertForView:view];
    if (alertView != nil) {
        [alertView hiddenView];
    }
}

+ (void)hidenAlertLoading {
    [self hidenAlertLoadingForView:[UIApplication sharedApplication].keyWindow];
}

+ (CCAlertView *)alertForView:(UIView *)view {
    NSEnumerator *subviewsEnum = [view.subviews reverseObjectEnumerator];
    for (UIView *subview in subviewsEnum) {
        if ([subview isKindOfClass:self]) {
            CCAlertView *hud = (CCAlertView *)subview;
            if (hud.type == CCAlertViewTypeLoading) {
                return hud;
            }
        }
    }
    return nil;
}

#pragma mark - show
- (void)showView {
    [self showViewInView:[UIApplication sharedApplication].keyWindow];
}

- (void)showViewInView:(UIView *)view {
    if (self.type == CCAlertViewTypeLoading) {
        [self.activityView startAnimating];
    }
    [view addSubview:self.cover];
    [self.cover mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(view);
    }];
    
    [view addSubview:self];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view.mas_left).offset(FitScale(60));
        make.center.equalTo(view);
    }];
    
    [view layoutIfNeeded];
    
    self.transform = CGAffineTransformMakeScale(.6, .6);
    self.alpha = 0;
    self.cover.alpha = 0;
    [UIView animateWithDuration:.2 animations:^{
        self.alpha = 1;
        self.cover.alpha = 1;
        self.transform = CGAffineTransformIdentity;
    }];
}

- (void)hiddenView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(alertViewDidHidden:)]) {
        [self.delegate alertViewDidHidden:self];
    }

    if (self.type == CCAlertViewTypeLoading) {
        [self.activityView stopAnimating];
    }
    [UIView animateWithDuration:.2 animations:^{
        self.alpha = 0;
        self.cover.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        [self.cover removeFromSuperview];
    }];
}

#pragma mark - createView
- (void)createView {
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = FitScale(8);
    self.layer.masksToBounds = YES;
    
    switch (self.type) {
        case CCAlertViewTypeTextAlert:
        {
            [self addSubview:self.titleLab];
            [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.mas_centerX);
                make.top.equalTo(self.mas_top).offset(FitScale(25));
                make.left.greaterThanOrEqualTo(self.mas_left).offset(FitScale(15));
            }];
            
            [self addSubview:self.lineView];
            [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.equalTo(self);
                make.top.equalTo(self.titleLab.mas_bottom).offset(FitScale(15));
                make.height.mas_equalTo(1);
            }];
        
            [self addSubview:self.bottomBtn];
            [self.bottomBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.lineView.mas_bottom);
                make.left.right.bottom.equalTo(self);
                make.height.mas_greaterThanOrEqualTo(FitScale(40));
            }];
            
            @weakify(self)
            [self.bottomBtn cc_tapHandle:^{
                @strongify(self)
                [self hiddenView];
                if (self.sureAction) {
                    self.sureAction();
                }
            }];
        }
            break;
        case CCAlertViewTypeLoading:
        {
            [self addSubview:self.activityView];
            [self.activityView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.mas_centerX);
                make.top.equalTo(self.mas_top).offset(FitScale(15));
                make.size.mas_equalTo(CGSizeMake(FitScale(30), FitScale(30)));
            }];
            
            [self addSubview:self.lineView];
            [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.equalTo(self);
                make.top.equalTo(self.activityView.mas_bottom).offset(FitScale(15));
                make.height.mas_equalTo(1);
            }];

            [self addSubview:self.bottomBtn];
            [self.bottomBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.lineView.mas_bottom);
                make.left.right.bottom.equalTo(self);
                make.height.mas_greaterThanOrEqualTo(FitScale(40));
            }];
        }
            break;
        default:
            break;
    }
}

#pragma mark - set
- (void)setMessage:(NSString *)message {
    _message = message;
    switch (self.type) {
        case CCAlertViewTypeTextAlert:
        {
            self.titleLab.text = self.message;
        }
            break;
        case CCAlertViewTypeLoading:
        {
            self.bottomBtn.text = self.message;
            self.bottomBtn.textColor = [UIColor blackColor];
        }
            break;
        default:
            break;
    }
}

- (void)setSureTitle:(NSString *)sureTitle {
    _sureTitle = sureTitle;
    switch (self.type) {
        case CCAlertViewTypeTextAlert:
        {
            self.bottomBtn.text = self.sureTitle;
            self.bottomBtn.textColor = CC_BTN_TITLE_COLOR;
        }
            break;
        case CCAlertViewTypeLoading:
        {
        }
            break;
        default:
            break;
    }
}

- (void)setType:(CCAlertViewType)type {
    if (_type == type) {
        return;
    }
    _type = type;
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self createView];
}


#pragma mark - get
- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.textColor = [UIColor blackColor];
        _titleLab.font = MediumFont(FitScale(14));
        _titleLab.textAlignment = NSTextAlignmentCenter;
        _titleLab.numberOfLines = 0;
    }
    return _titleLab;
}

- (UILabel *)bottomBtn {
    if (!_bottomBtn) {
        _bottomBtn = [[UILabel alloc] init];
        _bottomBtn.font = MediumFont(FitScale(14));
        _bottomBtn.textAlignment = NSTextAlignmentCenter;
    }
    return _bottomBtn;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = RGB(0xE7EAEA);
    }
    return _lineView;
}

- (UIActivityIndicatorView *)activityView {
    if (!_activityView) {
        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _activityView.color = RGB_COLOR(151, 152, 153);
    }
    return _activityView;
}

- (UIView *)cover {
    if (!_cover) {
        _cover = [[UIView alloc] init];
        _cover.backgroundColor = [UIColor colorWithWhite:0 alpha:.5];
    }
    return _cover;
}

@end
