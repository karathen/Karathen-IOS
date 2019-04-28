//
//  CCCreateWalletViewController.m
//  Karathen
//
//  Created by Karathen on 2018/7/12.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCCreateWalletViewController.h"
#import "CCBackUpMnemonicViewController.h"

#import "CCWalletTextFieldEditView.h"
#import "CCImportHDWalletVC.h"

@interface CCCreateWalletViewController () <CCWalletEditViewDelegate>

//
@property (nonatomic, strong) CCWalletTextFieldEditView *nameView;
@property (nonatomic, strong) CCWalletTextFieldEditView *pwdView;
@property (nonatomic, strong) CCWalletTextFieldEditView *resetPwdView;
@property (nonatomic, strong) CCWalletTextFieldEditView *pwdInfoView;
//
@property (nonatomic, strong) UIButton *createBtn;
@property (nonatomic, strong) UIButton *importBtn;


@end

@implementation CCCreateWalletViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createView];
    [self languageChange:nil];
    
    [self btnStatusChange];
}

#pragma mark - super method
- (void)languageChange:(NSString *)language {
    self.title = Localized(@"Create Wallet");

    self.nameView.title = self.titles[0];
    self.nameView.placeholder = self.descs[0];
    
    self.pwdView.title = self.titles[1];
    self.pwdView.placeholder = self.descs[1];
    
    self.resetPwdView.title = self.titles[2];
    self.resetPwdView.placeholder = self.descs[2];
    
    self.pwdInfoView.title = self.titles[3];
    self.pwdInfoView.placeholder = self.descs[3];
    
    
    [self.createBtn setTitle:Localized(@"Create Wallet") forState:UIControlStateNormal];
    [self.importBtn setTitle:Localized(@"Import Wallet") forState:UIControlStateNormal];
    
}

#pragma mark - 检测是否可以创建
- (void)btnStatusChange {
    BOOL judge = [self judgeComplete];
    if (judge) {
        self.createBtn.userInteractionEnabled = YES;
        self.createBtn.backgroundColor = CC_BTN_ENABLE_COLOR;
    } else {
        self.createBtn.userInteractionEnabled = NO;
        self.createBtn.backgroundColor = CC_BTN_DISABLE_COLOR;
    }
}

- (BOOL)judgeComplete {
    NSString *name = self.nameView.text;
    name = [name deleteSpace];
    if (name.length == 0) {
        return NO;
    }
    if (self.pwdView.textField.text.length == 0) {
        return NO;
    }
    if (![self.resetPwdView.text isEqualToString:self.pwdView.text]) {
        return NO;
    }
    return YES;
}

#pragma mark - tap action
- (void)createAction {
    [self.view endEditing:YES];
    
    if (self.pwdView.text.length < 6) {
        [MBProgressHUD showMessage:self.pwdView.placeholder];
        return;
    }
    
    if (self.walletType == CCWalletTypePhone) {
        [self gotoBackUpVCWithMnemonic:[CCWalletManager randomMnemonic]];
    } else {
        if ([CCHardwareWallet hardwareWallet].isConnectDevice) {
            [self createHardware];
        } else {
            [CCAlertView showLoadingMessage:Localized(@"Connecting...")];
            @weakify(self)
            [[CCHardwareWallet hardwareWallet] reConnectDeviceCompletion:^(BOOL success, int errorCode) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    @strongify(self)
                    [CCAlertView hidenAlertLoading];
                    if (success) {
                        [self createHardware];
                    } else {
                        [MBProgressHUD showMessage:Localized(@"Connection failed")];
                    }
                });
            }];
        }
    }
}

- (void)createHardware {
    [CCAlertView showLoadingMessage:Localized(@"Creating mnemonics")];
    @weakify(self)
    [[CCHardwareWallet hardwareWallet] generateSeedCompletion:^(BOOL success, int errorCode, NSString *mnemnoic) {
        @strongify(self)
        dispatch_async(dispatch_get_main_queue(), ^{
            [CCAlertView hidenAlertLoading];
            if (success) {
                [self gotoBackUpVCWithMnemonic:mnemnoic];
            } else {
                DLog(@"error - %@",[Utils errorCodeToString:errorCode]);
            }
        });
    }];
}


- (void)gotoBackUpVCWithMnemonic:(NSString *)mnemonic {
    CCBackUpMnemonicViewController *backupVC = [[CCBackUpMnemonicViewController alloc] init];
    backupVC.pinWord = self.pwdView.text;
    backupVC.pwdInfo = self.pwdInfoView.text;
    backupVC.walletName = self.nameView.text;
    backupVC.mnemonic = mnemonic;
    backupVC.walletType = self.walletType;
    [self.rt_navigationController pushViewController:backupVC animated:YES complete:nil];
}

- (void)importAction {
    [self.view endEditing:YES];
    CCImportHDWalletVC *importVC = [[CCImportHDWalletVC alloc] init];
    importVC.walletType = self.walletType;
    @weakify(self)
    [self.rt_navigationController pushViewController:importVC animated:YES complete:^(BOOL finished) {
        @strongify(self)
        [self.rt_navigationController removeViewController:self];
    }];
}

#pragma mark - createView
- (void)createView {
    [self.contentView addSubview:self.nameView];
    [self.nameView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left);
        make.top.equalTo(self.contentView.mas_top).offset(FitScale(6));
        make.centerX.equalTo(self.contentView.mas_centerX);
    }];
    
    [self.contentView addSubview:self.pwdView];
    [self.pwdView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left);
        make.top.equalTo(self.nameView.mas_bottom);
        make.centerX.equalTo(self.contentView.mas_centerX);
    }];
    
    [self.contentView addSubview:self.resetPwdView];
    [self.resetPwdView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left);
        make.top.equalTo(self.pwdView.mas_bottom);
        make.centerX.equalTo(self.contentView.mas_centerX);
    }];
    
    [self.contentView addSubview:self.pwdInfoView];
    [self.pwdInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left);
        make.top.equalTo(self.resetPwdView.mas_bottom);
        make.centerX.equalTo(self.contentView.mas_centerX);
    }];
    
    [self.contentView addSubview:self.createBtn];
    [self.createBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(FitScale(39));
        make.centerX.equalTo(self.contentView.mas_centerX);
        make.height.mas_equalTo(FitScale(40));
        make.top.equalTo(self.pwdInfoView.mas_bottom).offset(FitScale(30));
    }];
    
    [self.contentView addSubview:self.importBtn];
    [self.importBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.createBtn);
        make.top.equalTo(self.createBtn.mas_bottom);
        make.height.equalTo(self.createBtn.mas_height);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-FitScale(30));
    }];
    
    @weakify(self)
    [self.createBtn cc_tapHandle:^{
        @strongify(self)
        [self createAction];
    }];
    
    [self.importBtn cc_tapHandle:^{
       @strongify(self)
        [self importAction];
    }];
}

#pragma mark - 数据源
- (NSArray *)titles {
    return @[Localized(@"Wallet name"),Localized(@"Set password"),Localized(@"Confirm password"),Localized(@"Prompt message")];
}

- (NSArray *)descs {
    if (self.walletType == CCWalletTypeHardware) {
        return @[Localized(@"Please input wallet name"),Localized(@"Please enter 6-digital number password"),Localized(@"Confirm password"),Localized(@"Please input prompt message")];
    } else {
        return @[Localized(@"Please input wallet name"),Localized(@"Please enter the password with at least 6 numbers"),Localized(@"Confirm password"),Localized(@"Please input prompt message")];
    }
}

#pragma mark - CCWalletEditViewDelegate
- (void)textChangeInfoView:(CCWalletTextFieldEditView *)infoView {
    [self btnStatusChange];
}

#pragma mark - get
- (CCWalletTextFieldEditView *)nameView {
    if (!_nameView) {
        _nameView = [[CCWalletTextFieldEditView alloc] init];
        _nameView.delegate = self;
    }
    return _nameView;
}

- (CCWalletTextFieldEditView *)pwdView {
    if (!_pwdView) {
        _pwdView = [[CCWalletTextFieldEditView alloc] init];
        _pwdView.textField.secureTextEntry = YES;
        _pwdView.delegate = self;
        if (self.walletType == CCWalletTypeHardware) {
            _pwdView.textField.keyboardType = UIKeyboardTypeNumberPad;
            _pwdView.textField.maxLength = 6;
        }
    }
    return _pwdView;
}

- (CCWalletTextFieldEditView *)resetPwdView {
    if (!_resetPwdView) {
        _resetPwdView = [[CCWalletTextFieldEditView alloc] init];
        _resetPwdView.textField.secureTextEntry = YES;
        _resetPwdView.delegate = self;
        if (self.walletType == CCWalletTypeHardware) {
            _resetPwdView.textField.keyboardType = UIKeyboardTypeNumberPad;
            _resetPwdView.textField.maxLength = 6;
        }
    }
    return _resetPwdView;
}

- (CCWalletTextFieldEditView *)pwdInfoView {
    if (!_pwdInfoView) {
        _pwdInfoView = [[CCWalletTextFieldEditView alloc] init];
        _pwdInfoView.delegate = self;
    }
    return _pwdInfoView;
}

- (UIButton *)createBtn {
    if (!_createBtn) {
        _createBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _createBtn.backgroundColor = CC_BTN_ENABLE_COLOR;
        _createBtn.layer.cornerRadius = FitScale(5);
        _createBtn.layer.masksToBounds = YES;
        [_createBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _createBtn.titleLabel.font = MediumFont(FitScale(14));
    }
    return _createBtn;
}

- (UIButton *)importBtn {
    if (!_importBtn) {
        _importBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _importBtn.backgroundColor = [UIColor clearColor];
        [_importBtn setTitleColor:CC_BTN_TITLE_COLOR forState:UIControlStateNormal];
        _importBtn.titleLabel.font = MediumFont(FitScale(14));
    }
    return _importBtn;
}

@end
