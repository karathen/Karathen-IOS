//
//  CCSubLBXScanViewController.m
//  Karathen
//
//  Created by Karathen on 2018/8/1.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCSubLBXScanViewController.h"
#import "CCSubLBXScanViewController+ScanQR.h"

@interface CCSubLBXScanViewController ()

@property (nonatomic, strong) UILabel *hintLab;
@property (nonatomic, strong) UIView *centerView;
@property (nonatomic, strong) UIButton *flashBtn;

@property (nonatomic, strong) UIImageView *lineView;

@end

@implementation CCSubLBXScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.isNeedScanImage = YES;
    self.isOpenInterestRect = YES;
    [self createView];
}

#pragma mark - languageChange
- (void)languageChange {
    self.hintLab.text = Localized(@"Align camera to the QR Code");
}


#pragma mark - addAnimation


#pragma mark - createView
- (void)createView {
    self.centerView.frame = [self centerViewRectWithStyle:self.style withViewFrame:self.qRScanView];
    [self.qRScanView addSubview:self.centerView];
    
    [self.qRScanView addSubview:self.hintLab];
    [self.hintLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.centerView.mas_centerX);
        make.bottom.equalTo(self.centerView.mas_top).offset(-FitScale(20));
    }];
    
    [self.qRScanView addSubview:self.flashBtn];
    [self.flashBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.centerView.mas_bottom).offset(FitScale(20));
        make.centerX.equalTo(self.centerView.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(FitScale(45), FitScale(45)));
    }];
    
    [self.centerView addSubview:self.lineView];
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.centerView);
    }];
    
    @weakify(self)
    [self.flashBtn cc_tapHandle:^{
        @strongify(self)
        self.flashBtn.selected = !self.flashBtn.selected;
        [self openOrCloseFlash];
    }];
    
    [self.lineView.layer addAnimation:[self lineAnimationWithReveres:NO] forKey:nil];
}

#pragma mark - 动画类型
- (CABasicAnimation *)lineAnimationWithReveres:(BOOL)reverses {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    animation.fromValue = @0;
    animation.toValue = @(self.centerView.cc_height);
    animation.autoreverses = reverses;
    animation.removedOnCompletion = NO;
    animation.duration = 2;
    animation.repeatCount = NSIntegerMax;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    return animation;
}


#pragma mark - get
- (UIView *)centerView {
    if (!_centerView) {
        _centerView = [[UIView alloc] init];
        _centerView.backgroundColor = [UIColor clearColor];
        _centerView.clipsToBounds = YES;
    }
    return _centerView;
}

- (UILabel *)hintLab {
    if (!_hintLab) {
        _hintLab = [[UILabel alloc] init];
        _hintLab.textColor = [UIColor whiteColor];
        _hintLab.font = MediumFont(16);
    }
    return _hintLab;
}

- (UIButton *)flashBtn {
    if (!_flashBtn) {
        _flashBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_flashBtn setImage:[UIImage imageNamed:@"cc_scan_flash_off"] forState:UIControlStateNormal];
        [_flashBtn setImage:[UIImage imageNamed:@"cc_scan_flash_on"] forState:UIControlStateSelected];
    }
    return _flashBtn;
}

- (UIImageView *)lineView {
    if (!_lineView) {
        _lineView = [[UIImageView alloc] init];
        _lineView.image = [UIImage imageNamed:@"cc_scan_ani_grid"];
    }
    return _lineView;
}

@end
