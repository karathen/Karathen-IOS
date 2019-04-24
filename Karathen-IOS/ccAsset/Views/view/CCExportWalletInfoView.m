//
//  CCExportWalletInfoView.m
//  ccAsset
//
//  Created by SealWallet on 2018/7/18.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCExportWalletInfoView.h"
#import "AttributeMaker.h"
#import "UIImageTool.h"

@interface CCExportWalletInfoView ()

@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, strong) UILabel *hintLab;
@property (nonatomic, strong) UIImageView *codeImgView;
@property (nonatomic, strong) UIButton *clipBtn;
@property (nonatomic, strong) UIView *cover;

@end

@implementation CCExportWalletInfoView

- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = FitScale(8);
        self.layer.masksToBounds = YES;
        [self createView];
    }
    return self;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleLab.text = title;
}

- (void)setInfo:(NSString *)info {
    _info = info;
    
    UIImage *codeImage = [UIImageTool createQRWithString:info QRSize:CGSizeMake(FitScale(300), FitScale(300))];
    [self.codeImgView setImage:codeImage];
}

#pragma mark - show
- (void)showView {
    [self showViewInView:[UIApplication sharedApplication].keyWindow];
}

- (void)showViewInView:(UIView *)view {
    [self bindData];

    [view addSubview:self.cover];
    [self.cover mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(view);
    }];
    
    [view addSubview:self];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view.mas_left).offset(FitScale(40));
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
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:.2 animations:^{
            self.alpha = 0;
            self.cover.alpha = 0;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
            [self.cover removeFromSuperview];
        }];
    });
}

#pragma mark - createView
- (void)createView {
    [self addSubview:self.titleLab];
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.top.equalTo(self.mas_top).offset(FitScale(20));
    }];

    [self addSubview:self.closeBtn];
    [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.top.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(FitScale(50), FitScale(50)));
    }];
    
    [self addSubview:self.hintLab];
    [self.hintLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(FitScale(25));
        make.centerX.equalTo(self.mas_centerX);
        make.top.equalTo(self.titleLab.mas_bottom).offset(FitScale(15));
    }];
    
    
    
    UIView *privateView = [[UIView alloc] init];
    privateView.backgroundColor = CC_GRAY_BACKCOLOR;
    privateView.layer.cornerRadius = FitScale(5);
    privateView.layer.masksToBounds = YES;
    [self addSubview:privateView];

    [privateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(FitScale(25));
        make.centerX.equalTo(self.mas_centerX);
        make.top.equalTo(self.hintLab.mas_bottom).offset(FitScale(15));
    }];
    
    [privateView addSubview:self.codeImgView];
    [self.codeImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.codeImgView.mas_height);
        make.edges.equalTo(privateView).insets(UIEdgeInsetsMake(FitScale(5), FitScale(5), FitScale(5), FitScale(5)));
    }];
    
    [self addSubview:self.clipBtn];
    [self.clipBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.left.equalTo(privateView.mas_left);
        make.height.mas_equalTo(FitScale(35));
        make.top.equalTo(privateView.mas_bottom).offset(15);
        make.bottom.equalTo(self.mas_bottom).offset(-FitScale(20));
    }];
    
    @weakify(self)
    [self.closeBtn cc_tapHandle:^{
       @strongify(self)
        [self hiddenView];
    }];
    
    
    [self.clipBtn cc_tapHandle:^{
        @strongify(self)
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = self.info;
        self.clipBtn.userInteractionEnabled = NO;
        self.clipBtn.backgroundColor = RGB(0x2a4ad2);
        [self.clipBtn setTitle:Localized(@"Copied") forState:UIControlStateNormal];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.clipBtn.userInteractionEnabled = YES;
            self.clipBtn.backgroundColor = CC_BTN_ENABLE_COLOR;
            [self.clipBtn setTitle:Localized(@"Copy") forState:UIControlStateNormal];
        });
    }];
}

- (void)bindData {
    if (self.hint && self.hint.length) {
        NSString *text = self.hint;
        self.hintLab.attributedText = [AttributeMaker attributeMaker:^(AttributeMaker *maker) {
            NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
            paragraph.lineSpacing = FitScale(2);
            maker.text(text)
            .paragraph(paragraph);
        }];
    }
    [self.clipBtn setTitle:Localized(@"Copy") forState:UIControlStateNormal];
}

#pragma mark - get
- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.textColor = CC_BLACK_COLOR;
        _titleLab.font = MediumFont(FitScale(15));
    }
    return _titleLab;
}

- (UIButton *)closeBtn {
    if (!_closeBtn) {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeBtn setImage:[UIImage imageNamed:@"cc_showview_close"] forState:UIControlStateNormal];
    }
    return _closeBtn;
}

- (UILabel *)hintLab {
    if (!_hintLab) {
        _hintLab = [[UILabel alloc] init];
        _hintLab.textColor = CC_BTN_TITLE_COLOR;
        _hintLab.font = MediumFont(FitScale(12));
        _hintLab.numberOfLines = 0;
    }
    return _hintLab;
}

- (UIImageView *)codeImgView {
    if (!_codeImgView) {
        _codeImgView = [[UIImageView alloc] init];
    }
    return _codeImgView;
}

- (UIButton *)clipBtn {
    if (!_clipBtn) {
        _clipBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_clipBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _clipBtn.titleLabel.font = MediumFont(FitScale(13));
        _clipBtn.layer.cornerRadius = FitScale(5);
        _clipBtn.backgroundColor = CC_BTN_ENABLE_COLOR;
    }
    return _clipBtn;
}

- (UIView *)cover {
    if (!_cover) {
        _cover = [[UIView alloc] init];
        _cover.backgroundColor = [UIColor colorWithWhite:0 alpha:.6];
    }
    return _cover;
}

@end
