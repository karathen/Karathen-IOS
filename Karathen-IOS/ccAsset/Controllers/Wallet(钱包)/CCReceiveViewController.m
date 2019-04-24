//
//  CCReceiveViewController.m
//  ccAsset
//
//  Created by SealWallet on 2018/7/23.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCReceiveViewController.h"

#import "UIImageTool.h"
#import "CCQRCodeRule.h"


@interface CCReceiveViewController ()

@property (nonatomic, strong) UILabel *nameLab;
@property (nonatomic, strong) UIImageView *codeView;
@property (nonatomic, strong) UILabel *addressLab;
@property (nonatomic, strong) UIButton *clipBtn;

@end

@implementation CCReceiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self createView];
    [self languageChange:nil];
}

#pragma mark - 生成二维码
- (UIImage *)createCodeImg {
    return [UIImageTool createQRWithString:[self codeString] QRSize:CGSizeMake(FitScale(344), FitScale(344))];
}

- (NSString *)codeString {
    return [CCQRCodeRule receiveQRCodeWithWallet:self.walletData asset:self.asset];
}

#pragma mark - super method
- (void)languageChange:(NSString *)language {
    self.title = Localized(@"Receive");
    
    if (self.asset) {
        self.nameLab.text = [NSString stringWithFormat:@"%@ - %@",[CCDataManager coinKeyWithType:self.walletData.type],self.asset.tokenSynbol];
    } else {
        self.nameLab.text = self.walletData.walletName;
    }
    [self.clipBtn setTitle:Localized(@"Copy the Wallet Address") forState:UIControlStateNormal];
}


#pragma mark - createView
- (void)createView {
    [self.view addSubview:self.nameLab];
    [self.nameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(FitScale(58));
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    
    [self.view addSubview:self.codeView];
    [self.codeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.nameLab.mas_bottom).offset(FitScale(26));
        make.size.mas_equalTo(CGSizeMake(FitScale(172), FitScale(172)));
    }];

    [self.view addSubview:self.addressLab];
    [self.addressLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.codeView.mas_bottom).offset(FitScale(20));
        make.centerX.equalTo(self.view.mas_centerX);
        make.left.greaterThanOrEqualTo(self.view.mas_left).offset(FitScale(10));
    }];

    [self.view addSubview:self.clipBtn];
    [self.clipBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.addressLab.mas_bottom).offset(FitScale(30));
        make.left.equalTo(self.view.mas_left).offset(FitScale(40));
        make.centerX.equalTo(self.view.mas_centerX);
        make.height.mas_equalTo(FitScale(40));
    }];
    
    [self bindWalletData];
    
    @weakify(self)
    [self.clipBtn cc_tapHandle:^{
        @strongify(self)
        [self copyAction];
    }];
    
}

- (void)bindWalletData {
    [self.codeView setImage:[self createCodeImg]];
    self.addressLab.text = self.walletData.address;
}


#pragma mark - copyAction
- (void)copyAction {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = self.walletData.address;
    self.clipBtn.userInteractionEnabled = NO;
    self.clipBtn.backgroundColor = RGB(0x2a4ad2);
    [self.clipBtn setTitle:Localized(@"Copied") forState:UIControlStateNormal];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.clipBtn.userInteractionEnabled = YES;
        self.clipBtn.backgroundColor = CC_BTN_ENABLE_COLOR;
        [self.clipBtn setTitle:Localized(@"Copy the Wallet Address") forState:UIControlStateNormal];
    });
}

#pragma mark - get
- (UILabel *)nameLab {
    if (!_nameLab) {
        _nameLab = [[UILabel alloc] init];
        _nameLab.textColor = CC_BLACK_COLOR;
        _nameLab.font = BoldFont(FitScale(14));
    }
    return _nameLab;
}

- (UIImageView *)codeView {
    if (!_codeView) {
        _codeView = [[UIImageView alloc] init];
    }
    return _codeView;
}

- (UILabel *)addressLab {
    if (!_addressLab) {
        _addressLab = [[UILabel alloc] init];
        _addressLab.textColor = CC_GRAY_TEXTCOLOR;
        _addressLab.font = MediumFont(FitScale(13));
        _addressLab.lineBreakMode = NSLineBreakByTruncatingMiddle;
    }
    return _addressLab;
}

- (UIButton *)clipBtn {
    if (!_clipBtn) {
        _clipBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _clipBtn.backgroundColor = CC_BTN_ENABLE_COLOR;
        _clipBtn.titleLabel.font = MediumFont(FitScale(14));
        [_clipBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _clipBtn.layer.cornerRadius = FitScale(5);
        _clipBtn.layer.masksToBounds = YES;
    }
    return _clipBtn;
}

@end
