//
//  CCVerifyMnemonicViewController.m
//  ccAsset
//
//  Created by SealWallet on 2018/7/16.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCVerifyMnemonicViewController.h"

#import "CCBackUpMnemonicView.h"
#import "AttributeMaker.h"
#import "CCAlertView.h"
#import "CCContentHintView.h"

@interface CCVerifyMnemonicViewController () <CCBackUpMnemonicViewDelegate,CCContentHintViewDelegate>

@property (nonatomic, strong) UILabel *descLab;
@property (nonatomic, strong) CCBackUpMnemonicView *orderView;
@property (nonatomic, strong) CCBackUpMnemonicView *disOrderView;
@property (nonatomic, strong) UIButton *verifyBtn;

@property (nonatomic, strong) CCAlertView *alertView;

@property (nonatomic, strong) CCContentHintView *skipView;
@property (nonatomic, strong) UIButton *skipBtn;

@end

@implementation CCVerifyMnemonicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createView];
    [self languageChange:nil];
}

#pragma mark - super method
- (void)languageChange:(NSString *)language {
    self.title = Localized(@"Verify Mnemonic Phrase");
    [self.skipBtn setTitle:Localized(@"Skip") forState:UIControlStateNormal];
    self.descLab.attributedText = [AttributeMaker attributeMaker:^(AttributeMaker *maker) {
        NSString *text = Localized(@"Please select Mnemonic Phrase in the correct order");
        NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
        paragraph.lineSpacing = FitScale(5);
        paragraph.alignment = NSTextAlignmentCenter;
        maker.text(text)
        .paragraph(paragraph);
    }];
    
    [self.verifyBtn setTitle:Localized(@"Verifying") forState:UIControlStateNormal];
    
    if (self.walletType != CCWalletTypeHardware) {
        [self rightItemSet];
    }
}

- (void)rightItemSet {
    [self.skipBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(FitScale(40), 24));
    }];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    space.width = FitScale(20);
    UIBarButtonItem *skipItem = [[UIBarButtonItem alloc] initWithCustomView:self.skipBtn];
    self.navigationItem.rightBarButtonItems = @[space,skipItem];
    @weakify(self)
    [self.skipBtn cc_tapHandle:^{
        @strongify(self)
        [self skipAction];
    }];
}

#pragma mark - 跳过
- (void)skipAction {
    [self.skipView showView];
}

#pragma mark - createView
- (void)createView {
    [self.contentView addSubview:self.descLab];
    [self.descLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView.mas_centerX);
        make.left.equalTo(self.contentView.mas_left).offset(FitScale(24));
        make.top.equalTo(self.contentView.mas_top).offset(FitScale(22));
    }];
    
    [self.contentView addSubview:self.orderView];
    [self.orderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView.mas_centerX);
        make.top.equalTo(self.descLab.mas_bottom).offset(FitScale(20));
        make.size.mas_equalTo(self.orderView.viewSize);
    }];
    
    [self.contentView addSubview:self.disOrderView];
    [self.disOrderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView.mas_centerX);
        make.top.equalTo(self.orderView.mas_bottom);
        make.size.mas_equalTo(self.disOrderView.viewSize);
    }];
    
    [self.contentView addSubview:self.verifyBtn];
    [self.verifyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView.mas_centerX);
        make.top.equalTo(self.disOrderView.mas_bottom).offset(FitScale(41));
        make.left.equalTo(self.contentView.mas_left).offset(FitScale(39));
        make.height.mas_equalTo(FitScale(42));
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-FitScale(40));
    }];
    
    [self.contentView layoutIfNeeded];
    @weakify(self)
    [self.verifyBtn cc_tapHandle:^{
        @strongify(self)
        [self verifyAction];
    }];
}

#pragma mark - action
- (void)verifyAction {
    if ([self.orderView verifyMnemonic]) {
        [self importWalletWithVerify:YES];
    } else {
        self.alertView.type = CCAlertViewTypeTextAlert;
        self.alertView.message = Localized(@"Please import your mnemonic words in order");
        self.alertView.sureTitle = Localized(@"OK");
        [self.alertView showView];
    }
}

- (void)importWalletWithVerify:(BOOL)verify {
    if (self.isImport) {
        if (self.walletType == CCWalletTypeHardware) {
            self.alertView.type = CCAlertViewTypeLoading;
            self.alertView.message = Localized(@"Connetction failed,now is being reconnected");
            [self.alertView showView];
            if ([CCHardwareWallet hardwareWallet].isConnectDevice) {
                [self importHardwareByMnemonic];
            } else {
                @weakify(self)
                [[CCHardwareWallet hardwareWallet] reConnectDeviceCompletion:^(BOOL success, int errorCode) {
                    @strongify(self)
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.alertView hiddenView];
                        if (success) {
                            [self importHardwareByMnemonic];
                        }
                    });
                    
                }];
            }
        } else {
            self.alertView.type = CCAlertViewTypeLoading;
            self.alertView.message = Localized(@"Creating wallet...");
            [self.alertView showView];
            [[CCDataManager dataManager] accountWithMnemonic:self.mnemonic walletType:CCWalletTypePhone importType:CCImportTypeSeed passWord:self.pinWord passWordInfo:self.pwdInfo accountName:self.walletName verifyMnemonic:verify completion:^(BOOL suc, CCWalletError error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.alertView hiddenView];
                    if (!suc) {
                        [MBProgressHUD showMessage:[CCWalletManager messageWithError:error]];
                    }
                });
            }];
        }
    } else {
        [self.accountData backUp];
        [self.rt_navigationController deleteFrontVC];
        [self.rt_navigationController popViewControllerAnimated:YES complete:nil];
    }
}

- (void)importHardwareByMnemonic {
    self.alertView.type = CCAlertViewTypeLoading;
    self.alertView.message = Localized(@"Importing...");
    [self.alertView showView];
    //初始化
    [[CCHardwareWallet hardwareWallet] formatDeviceCompletion:^(BOOL success, int errorCode) {
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.alertView.message = Localized(@"Setting password");
            });
            //设置密码
            [[CCHardwareWallet hardwareWallet] initPassword:self.pinWord completion:^(BOOL suc, int errorCode) {
                if (success) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.alertView.message = Localized(@"Writting mnemonics");
                    });
                    //写入助记词
                    [[CCHardwareWallet hardwareWallet] importSeedWithMnemonic:self.mnemonic completion:^(BOOL success, int errorCode) {
                        if (success) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                self.alertView.message = Localized(@"Getting address");
                            });
                            //获取地址
                            [[CCHardwareWallet hardwareWallet] getDeviceAddressCompletion:^(BOOL suc, int errorCode, NSDictionary *addressDic) {
                                if (suc) {
                                    [[CCDataManager dataManager] accountWithDeviceName:[CCHardwareWallet hardwareWallet].deviceName addressDic:addressDic importType:CCImportTypeSeed accountName:self.walletName passWordInfo:self.pwdInfo completion:^(BOOL suc, CCWalletError error) {
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            [self.alertView hiddenView];
                                            if (!suc) {
                                                [MBProgressHUD showMessage:[CCWalletManager messageWithError:error]];
                                            }
                                        });
                                    }];
                                } else {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [self.alertView hiddenView];
                                    });
                                }
                            }];
                        } else {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.alertView hiddenView];
                            });
                        }
                    }];
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.alertView hiddenView];
                    });
                }
            }];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.alertView hiddenView];
            });
        }
    }];

}

#pragma mark - CCBackUpMnemonicViewDelegate
- (void)backupView:(CCBackUpMnemonicView *)backupView selectModel:(CCBackUpMnemonicModel *)model {
    if (backupView.type == CCBackUpMnemonicTypeCancle) {
        [self.disOrderView selectedChangeModel:model];
    } else if (backupView.type == CCBackUpMnemonicTypeVerify) {
        [self.orderView addOrCancelModel:model];
    }
}


#pragma mark - CCContentHintViewDelegate
- (void)hintViewConfirm:(CCContentHintView *)hintView {
    [self importWalletWithVerify:NO];
}

#pragma mark - get
- (UILabel *)descLab {
    if (!_descLab) {
        _descLab = [[UILabel alloc] init];
        _descLab.textColor = CC_GRAY_TEXTCOLOR;
        _descLab.font = MediumFont(13);
        _descLab.numberOfLines = 0;
    }
    return _descLab;
}

- (CCBackUpMnemonicView *)orderView {
    if (!_orderView) {
        _orderView = [CCBackUpMnemonicView backupViewWithMnemonic:self.mnemonic viewWidth:SCREEN_WIDTH - FitScale(54) viewType:CCBackUpMnemonicTypeCancle];
        _orderView.backgroundColor = CC_GRAY_BACKCOLOR;
        _orderView.layer.cornerRadius = FitScale(8);
        _orderView.backupDelegate = self;
    }
    return _orderView;
}

- (CCBackUpMnemonicView *)disOrderView {
    if (!_disOrderView) {
        _disOrderView = [CCBackUpMnemonicView backupViewWithMnemonic:self.mnemonic viewWidth:SCREEN_WIDTH - FitScale(54) viewType:CCBackUpMnemonicTypeVerify];
        _disOrderView.backgroundColor = [UIColor clearColor];
        _disOrderView.backupDelegate = self;
    }
    return _disOrderView;
}

- (UIButton *)verifyBtn {
    if (!_verifyBtn) {
        _verifyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _verifyBtn.backgroundColor = CC_BTN_ENABLE_COLOR;
        _verifyBtn.titleLabel.font = MediumFont(FitScale(14));
        [_verifyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _verifyBtn.layer.cornerRadius = FitScale(5);
        _verifyBtn.layer.masksToBounds = YES;

    }
    return _verifyBtn;
}

- (CCAlertView *)alertView {
    if (!_alertView) {
        _alertView = [CCAlertView alertViewMessage:nil sureTitle:nil withType:CCAlertViewTypeTextAlert];
    }
    return _alertView;
}

- (UIButton *)skipBtn {
    if (!_skipBtn) {
        _skipBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _skipBtn.backgroundColor = CC_BTN_ENABLE_COLOR;
        [_skipBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _skipBtn.titleLabel.font = MediumFont(FitScale(13));
        _skipBtn.layer.cornerRadius = FitScale(3);
        _skipBtn.layer.masksToBounds = YES;
    }
    return _skipBtn;
}

- (CCContentHintView *)skipView {
    if (!_skipView) {
        _skipView = [CCContentHintView hintViewWithTitle:Localized(@"Skip") content:Localized(@"Skip Backup Mnemonic")];
        _skipView.delegate = self;
    }
    return _skipView;
}

@end
