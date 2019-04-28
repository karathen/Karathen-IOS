//
//  CCImportHardwareAddressVC.m
//  Karathen
//
//  Created by Karathen on 2018/12/4.
//  Copyright © 2018 raistone. All rights reserved.
//

#import "CCImportHardwareAddressVC.h"
#import "CCWalletNameView.h"

@interface CCImportHardwareAddressVC ()

@property (nonatomic, strong) CCWalletNameView *nameView;
@property (nonatomic, strong) UIButton *createBtn;

@end

@implementation CCImportHardwareAddressVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self languageChange:nil];
    [self createView];
}

#pragma mark - super method
- (void)languageChange:(NSString *)language {
    self.title = Localized(@"Import");
}

#pragma mark - createView
- (void)createView {
    [self.view addSubview:self.nameView];
    [self.nameView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view.mas_top).offset(FitScale(30));
    }];
    
    [self.view addSubview:self.createBtn];
    [self.createBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(FitScale(40));
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.nameView.mas_bottom).offset(FitScale(25));
        make.height.mas_equalTo(FitScale(40));
    }];
    
    NSString *customName = [[CCDataManager dataManager] createWalletName];
    self.nameView.textField.placeholder = customName;
    self.nameView.textField.text = customName;
    
    @weakify(self)
    [self.createBtn cc_tapHandle:^{
        @strongify(self)
        [self createAddress];
    }];
}

#pragma mark - 创建地址
- (void)createAddress {
    [self.view endEditing:YES];
    NSString *accountID = [[CCDataManager dataManager] accountIDWithDeviceName:[CCHardwareWallet hardwareWallet].deviceName];
    CCAccountData *account = [[CCDataManager dataManager] accountWithAccountID:accountID];
    if (account) {
        [MBProgressHUD showMessage:Localized(@"This hardware wallet had existed")];
        return;
    }
    
    @weakify(self)
    [self showPassWordMaxLength:6
                        onlyNum:YES
                     completion:^(NSString *text) {
                         @strongify(self)
                         [self addAddressWithPassWord:text];
                     }];
}

- (void)addAddressWithPassWord:(NSString *)passWord {
    self.createBtn.userInteractionEnabled = NO;
    
    if (![CCBlueTooth blueTooth].blueToothOpen) {
        [MBProgressHUD showMessage:Localized(@"Please turn on the Bluetooth")];
        return;
    }
    [CCAlertView showLoadingMessage:Localized(@"Importing...")];
    if ([CCHardwareWallet hardwareWallet].isConnectDevice) {
        [self verifyPwd:passWord];
    } else {
        @weakify(self)
        [[CCHardwareWallet hardwareWallet] reConnectDeviceCompletion:^(BOOL success, int errorCode) {
            @strongify(self)
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success) {
                    [self verifyPwd:passWord];
                } else {
                    self.createBtn.userInteractionEnabled = YES;
                    [CCAlertView hidenAlertLoading];
                    [MBProgressHUD showMessage:Localized(@"Connection failed")];
                }
            });
        }];
    }
}

- (void)verifyPwd:(NSString *)password {
    NSString *walletName = self.nameView.textField.text;
    @weakify(self)
    [[CCHardwareWallet hardwareWallet] verifyPassword:password completion:^(BOOL suc, int errorCode) {
        @strongify(self)
        if (suc) {
            [self importAddressByHardwareWithName:walletName];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.createBtn.userInteractionEnabled = YES;
                [CCAlertView hidenAlertLoading];
                [MBProgressHUD showMessage:Localized(@"Password incorrect")];
            });
        }
    }];
}

- (void)importAddressByHardwareWithName:(NSString *)walletName {
    [[CCHardwareWallet hardwareWallet] getDeviceAddressCompletion:^(BOOL suc, int errorCode, NSDictionary *addressDic) {
        if (suc) {
            [[CCDataManager dataManager] accountWithDeviceName:[CCHardwareWallet hardwareWallet].deviceName addressDic:addressDic importType:CCImportTypeHardware accountName:walletName passWordInfo:nil completion:^(BOOL suc, CCWalletError error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [CCAlertView hidenAlertLoading];
                    if (!suc) {
                        [MBProgressHUD showMessage:[CCWalletManager messageWithError:error]];
                    }
                });
            }];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [CCAlertView hidenAlertLoading];
            });
            DLog(@"error - %@",[Utils errorCodeToString:errorCode]);
        }
    }];
}


#pragma mark - get
- (CCWalletNameView *)nameView {
    if (!_nameView) {
        _nameView = [[CCWalletNameView alloc] init];
        _nameView.descLab.text = Localized(@"The hardware wallet had existed address,you can import it directly");
    }
    return _nameView;
}

- (UIButton *)createBtn {
    if (!_createBtn) {
        _createBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_createBtn setTitle:Localized(@"Import") forState:UIControlStateNormal];
        [_createBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _createBtn.backgroundColor = CC_BTN_ENABLE_COLOR;
        _createBtn.titleLabel.font = MediumFont(FitScale(15));
        _createBtn.layer.cornerRadius = FitScale(5);
        _createBtn.layer.masksToBounds = YES;
    }
    return _createBtn;
}



@end
