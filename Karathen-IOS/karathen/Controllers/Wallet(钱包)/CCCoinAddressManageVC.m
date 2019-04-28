//
//  CCCoinAddressManageVC.m
//  Karathen
//
//  Created by Karathen on 2018/8/31.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCCoinAddressManageVC.h"
#import "CCCoinAddressView.h"
#import "CCAddAddressViewController.h"
#import "CCExportWalletInfoView.h"
#import "CCBackUpMnemonicViewController.h"
#import "CCWebViewController.h"
#import "CCAlertView.h"
#import "CCClaimGasViewController.h"

@interface CCCoinAddressManageVC () <CCCoinAddressViewDelegate>

@property (nonatomic, strong) CCCoinAddressView *tableView;
@property (nonatomic, strong) CCExportWalletInfoView *exportView;
@property (nonatomic, strong) CCAlertView *alertView;

@end

@implementation CCCoinAddressManageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self languageChange:nil];
    [self createView];
    if (self.coinData.importType == CCImportTypeSeed || self.coinData.importType == CCImportTypeMnemonic || self.coinData.importType == CCImportTypeHardware) {
        [self moreRightItem];
    }
    [self addNofity];
}

#pragma mark - super method
- (void)languageChange:(NSString *)language {
    self.title = Localized(@"Address Management");
}

#pragma mark - addNofity
- (void)addNofity {
    @weakify(self)
    [CCNotificationCenter receiveWalletAddressChangeObserver:self completion:^(CCCoinType coinType) {
        @strongify(self)
        if (self.coinData.coin.coinType == coinType) {
            [self reloadData];
        }
    }];
    
    //钱包名称
    [CCNotificationCenter receiveWalletNameChangeObserver:self completion:^(NSString *walletAddress) {
        @strongify(self)
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
}

#pragma mark - reloadData
- (void)reloadData {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}


#pragma mark - moreRightItem
- (void)moreRightItem {
    UIButton *add = [UIButton buttonWithType:UIButtonTypeCustom];
    add.frame = CGRectMake(0, 0, FitScale(60), NAVIGATION_BAR_HEIGHT);
    add.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    add.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, FitScale(10));
    [add setTitleColor:CC_BLACK_COLOR forState:UIControlStateNormal];
    [add setImage:[UIImage imageNamed:@"cc_addAddress"] forState:UIControlStateNormal];
    [add addTarget:self action:@selector(addAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithCustomView:add];

    self.navigationItem.rightBarButtonItem = addItem;
}

#pragma mark - 添加
- (void)addAction {
    CCAddAddressViewController *addVc = [[CCAddAddressViewController alloc] init];
    addVc.coinData = self.coinData;
    [self.rt_navigationController pushViewController:addVc animated:YES complete:nil];
}


#pragma mark - 导出keystore
- (void)exportKeystore:(CCWalletData *)walletData password:(NSString *)password {
    self.alertView.message = Localized(@"Exporting...");
    [self.alertView showView];
    
    @weakify(self)
    [walletData exportKeystore:password completion:^(BOOL suc, NSString *keystore, CCWalletError error) {
        @strongify(self)
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.alertView hiddenView];
            if (suc) {
                self.exportView.title = Localized(@"Export keystore");
                self.exportView.hint = [NSString stringWithFormat:Localized(@"Warning Export"),Localized(@"Keystore")];
                self.exportView.info = keystore;
                [self.exportView showView];
            } else {
                [MBProgressHUD showMessage:[CCWalletManager messageWithError:error]];
            }
        });
    }];
}

#pragma mark - 导出私钥
- (void)exportPrivateKey:(CCWalletData *)walletData password:(NSString *)password {
    [CCAlertView showLoadingMessage:Localized(@"Exporting...")];
    @weakify(self)
    [walletData exportPrivateKey:password completion:^(BOOL suc, NSString *privateKey, CCWalletError error) {
        @strongify(self)
        dispatch_async(dispatch_get_main_queue(), ^{
            [CCAlertView hidenAlertLoading];
            if (suc) {
                self.exportView.title = Localized(@"Export Private Key");
                self.exportView.hint = [NSString stringWithFormat:Localized(@"Warning Export"),Localized(@"Private key")];
                self.exportView.info = privateKey;
                [self.exportView showView];
            } else {
                [MBProgressHUD showMessage:[CCWalletManager messageWithError:error]];
            }
        });
    }];
}

#pragma mark - 导出WIF
- (void)exportWIF:(CCWalletData *)walletData password:(NSString *)password {
    [CCAlertView showLoadingMessage:Localized(@"Exporting...")];
    @weakify(self)
    [walletData exportWIF:password completion:^(BOOL suc, NSString *wif, CCWalletError error) {
        @strongify(self)
        dispatch_async(dispatch_get_main_queue(), ^{
            [CCAlertView hidenAlertLoading];
            if (suc) {
                self.exportView.title = Localized(@"Export WIF");
                self.exportView.hint = [NSString stringWithFormat:Localized(@"Warning Export"),Localized(@"WIF")];
                self.exportView.info = wif;
                [self.exportView showView];
            } else {
                [MBProgressHUD showMessage:[CCWalletManager messageWithError:error]];
            }
        });
    }];
}

#pragma mark - CCCoinAddressViewDelegate
- (void)manageExportKeystore:(CCWalletData *)walletData {    
    @weakify(self)
    [self showPassWordMaxLength:0 onlyNum:NO completion:^(NSString *text) {
        @strongify(self)
        [self exportKeystore:walletData password:text];
    }];
}

- (void)manageExportPrivateKey:(CCWalletData *)walletData {
    @weakify(self)
    [self showPassWordMaxLength:0 onlyNum:NO completion:^(NSString *text) {
        @strongify(self)
        [self exportPrivateKey:walletData password:text];
    }];
}

- (void)manageExportWIF:(CCWalletData *)walletData {
    @weakify(self)
    [self showPassWordMaxLength:0 onlyNum:NO completion:^(NSString *text) {
        @strongify(self)
        [self exportWIF:walletData password:text];
    }];
}

- (void)manageEnterTheExplorer:(CCWalletData *)walletData {
    CCWebViewController *webVC = [[CCWebViewController alloc] init];
    webVC.webUrl = [walletData addressExplorer];
    webVC.title = @"Address Information";
    [self.rt_navigationController pushViewController:webVC animated:YES complete:nil];
}


- (void)manageChangeName:(CCWalletData *)walletData {
    @weakify(self)
    [self inputAlertWithTitle:Localized(@"Change address name")
                      message:nil
                  placeholder:nil
              secureTextEntry:NO
                 keyboardType:UIKeyboardTypeDefault
                  destructive:NO
                    minLength:1
                    maxLength:0
                   completion:^(NSString *text) {
                       @strongify(self)
                       [self changeWallet:walletData withName:text];
                   }];
}

- (void)changeWallet:(CCWalletData *)walletData withName:(NSString *)walletName {
    walletName = [walletName deleteSpace];
    if (!walletName.length) {
        [CCAlertView showAlertWithMessage:Localized(@"Address Name Can't be empety")];
        return;
    }
    [walletData changeWalletName:walletName];
}

- (void)manageClaimGas:(CCWalletData *)walletData {
    CCClaimGasViewController *gasVC = [[CCClaimGasViewController alloc] init];
    gasVC.walletData = walletData;
    [self.rt_navigationController pushViewController:gasVC animated:YES complete:nil];
}

#pragma mark - createView
- (void)createView {
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark - tableView
- (CCCoinAddressView *)tableView {
    if (!_tableView) {
        _tableView = [[CCCoinAddressView alloc] initWithCoinData:self.coinData];
        _tableView.addressDelegate = self;
    }
    return _tableView;
}

- (CCExportWalletInfoView *)exportView {
    if (!_exportView) {
        _exportView = [[CCExportWalletInfoView alloc] init];
    }
    return _exportView;
}

- (CCAlertView *)alertView {
    if (!_alertView) {
        _alertView = [CCAlertView alertViewMessage:nil sureTitle:nil withType:CCAlertViewTypeLoading];
    }
    return _alertView;
}

@end
