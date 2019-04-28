//
//  CCAccountManageVC.m
//  Karathen
//
//  Created by Karathen on 2018/11/27.
//  Copyright © 2018 raistone. All rights reserved.
//

#import "CCAccountManageVC.h"
#import "CCAccountListView.h"
#import "CCAlertView.h"
#import "CCResetPasswordViewController.h"
#import "CCCoinManageViewController.h"
#import "CCBackUpMnemonicViewController.h"

@interface CCAccountManageVC () <CCAccountListViewDelegate>

@property (nonatomic, strong) CCAccountListView *accountView;
@property (nonatomic, strong) CCAlertView *alertView;

@end

@implementation CCAccountManageVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = Localized(@"Wallet management");
    [self createView];
}

#pragma mark - createView
- (void)createView {
    [self.view addSubview:self.accountView];
    [self.accountView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark - CCAccountListViewDelegate
- (void)addNewWallet {
    UIViewController *vc = [[NSClassFromString(@"CCHomeWalletViewController") alloc] init];
    CCNavigationController *nav = [[CCNavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)changeWalletNameWithAccount:(CCAccountData *)account {
    @weakify(self)
    [self inputAlertWithTitle:Localized(@"Change wallet name")
                      message:nil
                  placeholder:nil
              secureTextEntry:NO
                 keyboardType:UIKeyboardTypeDefault
                  destructive:NO
                    minLength:1
                    maxLength:0 
                   completion:^(NSString *text) {
                       @strongify(self)
                       [self changeAccount:account name:text];
                   }];
}

- (void)changeAccount:(CCAccountData *)accountData name:(NSString *)accountName {
    accountName = [accountName deleteSpace];
    if (!accountName.length) {
        [CCAlertView showAlertWithMessage:Localized(@"Wallet Name Can't be empety")];
        return;
    }
    [accountData changeName:accountName];
}

- (void)changeWalletPwdWithAccount:(CCAccountData *)account {
    CCResetPasswordViewController *changeVC = [[CCResetPasswordViewController alloc] init];
    changeVC.accountData = account;
    [self.rt_navigationController pushViewController:changeVC animated:YES complete:nil];
}

- (void)showWalletPwdInfoWithAccount:(CCAccountData *)account {
    NSString *passwordInfo = account.account.passwordInfo;
    [CCAlertView showAlertWithMessage:(passwordInfo.length == 0)?Localized(@"None"):passwordInfo];
}

- (void)walletCoinManagerWithAccount:(CCAccountData *)account {
    CCCoinManageViewController *coinVC = [[CCCoinManageViewController alloc] init];
    coinVC.account = account;
    [self.rt_navigationController pushViewController:coinVC animated:YES complete:nil];
}

- (void)walletBackUpWithAccount:(CCAccountData *)account {
    BOOL isHardware = account.account.walletType == CCWalletTypeHardware;
    @weakify(self)
    [self showPassWordMaxLength:isHardware?6:0
                        onlyNum:isHardware
                     completion:^(NSString *text) {
                         @strongify(self)
                         [self backUpWalletWithPwd:text account:account];
                     }];
}

- (void)backUpWalletWithPwd:(NSString *)password account:(CCAccountData *)account {
    if (account.account.importType != CCImportTypeSeed && account.account.importType != CCImportTypeMnemonic) {
        return;
    }
    self.alertView = [CCAlertView showLoadingMessage:Localized(@"Loading...")];
    @weakify(self)
    [[CCDataManager dataManager] walletInfoWithAccountID:account.account.accountID password:password completion:^(NSString *walletInfo) {
        @strongify(self)
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.alertView hiddenView];
            if (!walletInfo) {
                [MBProgressHUD showMessage:[CCWalletManager messageWithError:CCWalletErrorPWD]];
                return;
            }
            CCBackUpMnemonicViewController *backUpVC = [[CCBackUpMnemonicViewController alloc] init];
            backUpVC.mnemonic = walletInfo;
            backUpVC.type = CCBackUpMnemonicVCBackUp;
            backUpVC.accountData = account;
            [self.rt_navigationController pushViewController:backUpVC animated:YES complete:nil];
        });
    }];

}

- (void)deleteWalletWithAccount:(CCAccountData *)account {
    if (account.account.walletType == CCWalletTypeHardware) {
        @weakify(self)
        [self messageAlertTitle:Localized(@"Confirm delete this hardware wallet?") message:nil cancel:Localized(@"Cancel") sureTitle:Localized(@"Confirm") destructive:YES alertAction:^(NSInteger index) {
            @strongify(self)
            if (index == 1) {
                [self deleteWalletWithPwd:nil account:account];
            }
        }];
    } else {
        @weakify(self)
        [self showPassWordMaxLength:0 onlyNum:NO completion:^(NSString *text) {
            @strongify(self)
            [self deleteWalletWithPwd:text account:account];
        }];
    }
}

- (void)deleteHardwareWithAccount:(CCAccountData *)account {
    self.alertView = [CCAlertView showLoadingMessage:Localized(@"Deleting wallet...")];
    @weakify(self)
    [[CCDataManager dataManager] deleteAccount:account completion:^(BOOL suc, CCWalletError error) {
        @strongify(self)
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.alertView hiddenView];
            if (!suc) {
                [MBProgressHUD showMessage:[CCWalletManager messageWithError:error]];
            }
        });
    }];
}


- (void)deleteWalletWithPwd:(NSString *)password account:(CCAccountData *)account {
    self.alertView = [CCAlertView showLoadingMessage:Localized(@"Deleting wallet...")];
    @weakify(self)
    [[CCDataManager dataManager] deleteAccount:account passWord:password completion:^(BOOL suc, CCWalletError error) {
        @strongify(self)
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.alertView hiddenView];
            if (!suc) {
                [MBProgressHUD showMessage:[CCWalletManager messageWithError:error]];
            }
        });
    }];
}


#pragma mark - get
- (CCAccountListView *)accountView {
    if (!_accountView) {
        _accountView = [[CCAccountListView alloc] init];
        _accountView.accountDelegate = self;
    }
    return _accountView;
}

@end
