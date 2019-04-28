//
//  CCAddAddressViewController.m
//  Karathen
//
//  Created by Karathen on 2018/9/4.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCAddAddressViewController.h"
#import "CCWalletNameView.h"

@interface CCAddAddressViewController ()

@property (nonatomic, strong) CCWalletNameView *nameView;
@property (nonatomic, strong) UIButton *createBtn;

@end

@implementation CCAddAddressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self languageChange:nil];
    [self createView];
}

#pragma mark - super method
- (void)languageChange:(NSString *)language {
    self.title = [NSString stringWithFormat:Localized(@"Create New Address"),[CCDataManager coinKeyWithType:self.coinData.coin.coinType]];
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
    
    NSString *customName = [self.coinData createWalletName];
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
    
    CCAccountData *account = [[CCDataManager dataManager] accountWithAccountID:self.coinData.coin.accountID];
    BOOL isHardware = account.account.walletType == CCWalletTypeHardware;
    @weakify(self)
    [self showPassWordMaxLength:isHardware?6:0
                        onlyNum:isHardware
                     completion:^(NSString *text) {
                         @strongify(self)
                         [self addAddressWithPassWord:text];
                     }];
}

- (void)addAddressWithPassWord:(NSString *)passWord {
    self.createBtn.userInteractionEnabled = NO;
 
    CCAccountData *accountData = [[CCDataManager dataManager] accountWithAccountID:self.coinData.coin.accountID];
    if (accountData.account.walletType == CCWalletTypeHardware) {
        if (![CCBlueTooth blueTooth].blueToothOpen) {
            [MBProgressHUD showMessage:Localized(@"Please turn on the Bluetooth")];
            return;
        }
        [CCAlertView showLoadingMessage:Localized(@"Creating address...")];
        if ([CCHardwareWallet hardwareWallet].isConnectDevice) {
            [self addAddressByHardwareWithPassword:passWord];
        } else {
            @weakify(self)
            [[CCHardwareWallet hardwareWallet] reConnectDeviceCompletion:^(BOOL success, int errorCode) {
                @strongify(self)
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (success) {
                        [self addAddressByHardwareWithPassword:passWord];
                    } else {
                        [CCAlertView hidenAlertLoading];
                        self.createBtn.userInteractionEnabled = YES;
                        [MBProgressHUD showMessage:Localized(@"Connection failed")];
                    }
                });
            }];
        }
    } else {
        [self addAddressByPhoneWithPassword:passWord];
    }
}

- (void)addAddressByHardwareWithPassword:(NSString *)password {
    NSString *walletName = self.nameView.textField.text;
    @weakify(self)
    [[CCHardwareWallet hardwareWallet] verifyPassword:password completion:^(BOOL suc, int errorCode) {
        @strongify(self)
        if (suc) {
            [self addAddressByHardwareWithName:walletName];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.createBtn.userInteractionEnabled = YES;
                [CCAlertView hidenAlertLoading];
                [MBProgressHUD showMessage:Localized(@"Password incorrect")];
            });
        }
    }];
}

- (void)addAddressByHardwareWithName:(NSString *)name {
    CCAccountData *accountData = [[CCDataManager dataManager] accountWithAccountID:self.coinData.coin.accountID];
    CCWalletData *walletData = self.coinData.wallets.lastObject;
    int slot = walletData.wallet.slot+1;
    
    [[CCHardwareWallet hardwareWallet] getDeviceAddressCoins:@[@(self.coinData.coin.coinType)] slot:slot completion:^(BOOL suc, int errorCode, NSDictionary *addressDic) {
        if (suc) {
            NSString *key = [CCDataManager coinKeyWithType:self.coinData.coin.coinType];
            NSString *address = [addressDic objectForKey:key];
            
            [self.coinData saveWalletWithAddress:address walletName:name importType:accountData.account.importType slot:slot completion:^(BOOL suc, CCWalletError error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [CCAlertView hidenAlertLoading];
                    self.createBtn.userInteractionEnabled = YES;
                    if (suc) {
                        [self.rt_navigationController popViewControllerAnimated:YES complete:nil];
                    } else {
                        [MBProgressHUD showMessage:[CCWalletManager messageWithError:error]];
                    }
                });
            }];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [CCAlertView hidenAlertLoading];
                self.createBtn.userInteractionEnabled = YES;
            });
        }
    }];
}


- (void)addAddressByPhoneWithPassword:(NSString *)password {
    CCAccountData *accountData = [[CCDataManager dataManager] accountWithAccountID:self.coinData.coin.accountID];
    [CCAlertView showLoadingMessage:Localized(@"Creating address...")];
    @weakify(self)
    [self.coinData createHDAddressWithWalletName:self.nameView.textField.text passWord:password importType:accountData.account.importType completion:^(BOOL suc, CCWalletError error) {
        @strongify(self)
        dispatch_async(dispatch_get_main_queue(), ^{
            [CCAlertView hidenAlertLoading];
            self.createBtn.userInteractionEnabled = YES;
            if (suc) {
                [self.rt_navigationController popViewControllerAnimated:YES complete:nil];
            } else {
                [MBProgressHUD showMessage:[CCWalletManager messageWithError:error]];
            }
        });
    }];
}



#pragma mark - get
- (CCWalletNameView *)nameView {
    if (!_nameView) {
        _nameView = [[CCWalletNameView alloc] init];
    }
    return _nameView;
}

- (UIButton *)createBtn {
    if (!_createBtn) {
        _createBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_createBtn setTitle:Localized(@"Create") forState:UIControlStateNormal];
        [_createBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _createBtn.backgroundColor = CC_BTN_ENABLE_COLOR;
        _createBtn.titleLabel.font = MediumFont(FitScale(15));
        _createBtn.layer.cornerRadius = FitScale(5);
        _createBtn.layer.masksToBounds = YES;
    }
    return _createBtn;
}

@end
