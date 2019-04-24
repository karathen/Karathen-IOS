//
//  CCResetPasswordViewController.m
//  ccAsset
//
//  Created by SealWallet on 2018/7/17.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCResetPasswordViewController.h"

#import "CCWalletTextFieldEditView.h"
#import "CCAlertView.h"

@interface CCResetPasswordViewController () <CCWalletEditViewDelegate>

@property (nonatomic, strong) CCWalletTextFieldEditView *oldPwView;
@property (nonatomic, strong) CCWalletTextFieldEditView *passwordView;
@property (nonatomic, strong) CCWalletTextFieldEditView *resetView;

@property (nonatomic, strong) UIButton *confirmBtn;
//加载框
@property (nonatomic, strong) CCAlertView *alertView;

@end

@implementation CCResetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createView];
    [self languageChange:nil];
    [self btnStatusChange];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[CCHardwareWallet hardwareWallet] bindHardwareAccount];
}

#pragma mark - super method
- (void)languageChange:(NSString *)language {
    self.title = Localized(@"Reset password");
    
    self.oldPwView.title = self.titles[0];
    self.oldPwView.placeholder = self.descs[0];
    
    self.passwordView.title = self.titles[1];
    self.passwordView.placeholder = self.descs[1];
    
    self.resetView.title = self.titles[2];
    self.resetView.placeholder = self.descs[2];
    
    [self.confirmBtn setTitle:Localized(@"Confirm") forState:UIControlStateNormal];
}

#pragma mark - 检测是否可以创建
- (void)btnStatusChange {
    BOOL judge = [self judgeComplete];
    if (judge) {
        self.confirmBtn.userInteractionEnabled = YES;
        self.confirmBtn.backgroundColor = CC_BTN_ENABLE_COLOR;
    } else {
        self.confirmBtn.userInteractionEnabled = NO;
        self.confirmBtn.backgroundColor = CC_BTN_DISABLE_COLOR;
    }
}


- (BOOL)judgeComplete {
    if (!self.oldPwView.text.length) {
        return NO;
    }
    if (![self.resetView.text isEqualToString:self.passwordView.text]) {
        return NO;
    }

    return YES;
}

#pragma mark - createView
- (void)createView {
    [self.contentView addSubview:self.oldPwView];
    [self.oldPwView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left);
        make.top.equalTo(self.contentView.mas_top).offset(FitScale(6));
        make.centerX.equalTo(self.contentView.mas_centerX);
    }];
    
    [self.contentView addSubview:self.passwordView];
    [self.passwordView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left);
        make.top.equalTo(self.oldPwView.mas_bottom);
        make.centerX.equalTo(self.contentView.mas_centerX);
    }];
    
    
    [self.contentView addSubview:self.resetView];
    [self.resetView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left);
        make.top.equalTo(self.passwordView.mas_bottom);
        make.centerX.equalTo(self.contentView.mas_centerX);
    }];
    

    [self.contentView addSubview:self.confirmBtn];
    [self.confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(FitScale(39));
        make.centerX.equalTo(self.contentView.mas_centerX);
        make.height.mas_equalTo(FitScale(40));
        make.top.equalTo(self.resetView.mas_bottom).offset(FitScale(30));
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-FitScale(30));
    }];
    
    @weakify(self)
    [self.confirmBtn cc_tapHandle:^{
        @strongify(self)
        [self confirmAction];
    }];
}

#pragma mark - action
- (void)confirmAction {
    [self.view endEditing:YES];
    if (self.passwordView.text.length < 6) {
        [MBProgressHUD showMessage:self.passwordView.placeholder];
        return;
    }
    if ([self.oldPwView.text isEqualToString:self.passwordView.text]) {
        self.alertView.type = CCAlertViewTypeTextAlert;
        self.alertView.message = Localized(@"New password should not be same as old password");
        self.alertView.sureTitle = Localized(@"OK");
        [self.alertView showView];
        return;
    }
    
    if (self.accountData.account.walletType == CCWalletTypeHardware) {
        [self reserHardwarePwd];
    } else {
        [self resetPhonePwd];
    }
}

- (void)resetPhonePwd {
    self.alertView.type = CCAlertViewTypeLoading;
    self.alertView.message = Localized(@"Resetting...");
    [self.alertView showView];
    
    @weakify(self)
    [[CCDataManager dataManager] resetPassWord:self.passwordView.text oldPassWord:self.oldPwView.text accountID:self.accountData.account.accountID completion:^(BOOL suc, CCWalletError error) {
        @strongify(self)
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.alertView hiddenView];
            [MBProgressHUD showMessage:[CCWalletManager messageWithError:error]];
            if (suc) {
                [self.rt_navigationController popViewControllerAnimated:YES complete:nil];
            }
        });
    }];
}

- (void)reserHardwarePwd {
    [[CCHardwareWallet hardwareWallet] changeDeviceWithAccount:self.accountData];
    
    self.alertView.type = CCAlertViewTypeLoading;
    self.alertView.message = Localized(@"Connecting...");
    [self.alertView showView];
    if ([CCHardwareWallet hardwareWallet].isConnectDevice) {
        [self changeHardwarePwd];
    } else {
        @weakify(self)
        [[CCHardwareWallet hardwareWallet] reConnectDeviceCompletion:^(BOOL success, int errorCode) {
            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self)
                if (success) {
                    [self changeHardwarePwd];
                } else {
                    [self.alertView hiddenView];
                }
            });
        }];
    }
}

- (void)changeHardwarePwd {
    self.alertView.message = Localized(@"Changing password");
    @weakify(self)
    [[CCHardwareWallet hardwareWallet] changePassword:self.passwordView.text oldPassWord:self.oldPwView.text completion:^(BOOL suc, int errorCode) {
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self)
            [self.alertView hiddenView];
            if (suc) {
                [self.rt_navigationController popViewControllerAnimated:YES complete:nil];
            } else {
                [MBProgressHUD showMessage:Localized(@"Change password failed")];
            }
        });
    }];
}




#pragma mark - 数据源
- (NSArray *)titles {
    return @[Localized(@"Old password"),Localized(@"New password"),Localized(@"Confirm password")];
}

- (NSArray *)descs {
    return @[Localized(@"Please enter the old password"),
             self.accountData.account.walletType==CCWalletTypeHardware?Localized(@"Please enter 6-digital number password"):Localized(@"Please enter the password with at least 6 numbers"),
             Localized(@"Confirm password")];
}

#pragma mark - CCWalletEditViewDelegate
- (void)textChangeInfoView:(CCWalletTextFieldEditView *)infoView {
    [self btnStatusChange];
}

#pragma mark - get
- (CCWalletTextFieldEditView *)oldPwView {
    if (!_oldPwView) {
        _oldPwView = [[CCWalletTextFieldEditView alloc] init];
        _oldPwView.textField.secureTextEntry = YES;
        if (self.accountData.account.walletType == CCWalletTypeHardware) {
            _oldPwView.textField.keyboardType = UIKeyboardTypeNumberPad;
            _oldPwView.textField.maxLength = 6;
        }
        _oldPwView.delegate = self;
    }
    return _oldPwView;
}

- (CCWalletTextFieldEditView *)passwordView {
    if (!_passwordView) {
        _passwordView = [[CCWalletTextFieldEditView alloc] init];
        _passwordView.textField.secureTextEntry = YES;
        if (self.accountData.account.walletType == CCWalletTypeHardware) {
            _passwordView.textField.keyboardType = UIKeyboardTypeNumberPad;
            _passwordView.textField.maxLength = 6;
        }
        _passwordView.delegate = self;
    }
    return _passwordView;
}

- (CCWalletTextFieldEditView *)resetView {
    if (!_resetView) {
        _resetView = [[CCWalletTextFieldEditView alloc] init];
        _resetView.textField.secureTextEntry = YES;
        if (self.accountData.account.walletType == CCWalletTypeHardware) {
            _resetView.textField.keyboardType = UIKeyboardTypeNumberPad;
            _resetView.textField.maxLength = 6;
        }
        _resetView.delegate = self;
    }
    return _resetView;
}

- (UIButton *)confirmBtn {
    if (!_confirmBtn) {
        _confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _confirmBtn.backgroundColor = CC_BTN_ENABLE_COLOR;
        _confirmBtn.layer.cornerRadius = FitScale(5);
        _confirmBtn.layer.masksToBounds = YES;
        [_confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _confirmBtn.titleLabel.font = MediumFont(FitScale(14));
    }
    return _confirmBtn;
}

- (CCAlertView *)alertView {
    if (!_alertView) {
        _alertView = [CCAlertView alertViewMessage:nil sureTitle:nil withType:CCAlertViewTypeTextAlert];
    }
    return _alertView;
}

@end
