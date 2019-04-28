//
//  CCTransferViewController.m
//  Karathen
//
//  Created by Karathen on 2018/7/23.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCTransferViewController.h"
#import "CCTradeConfirmViewController.h"

#import "CCTransferView.h"
#import "CCScanQRViewController.h"


@interface CCTransferViewController () <CCScanQRViewControllerDelegate, CCTransferViewDelegate>

@property (nonatomic, strong) CCTransferView *transferView;

@end

@implementation CCTransferViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = Localized(@"Transfer");

    [self createView];
    [self languageChange:nil];
    [self setScanItem];
}

#pragma mark - 扫描
- (void)setScanItem {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.bounds = CGRectMake(0, 0, FitScale(60), NAVIGATION_BAR_HEIGHT);
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    btn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, FitScale(10));
    [btn setImage:[UIImage imageNamed:@"cc_scan_qr_item"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(scanAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
}

- (void)scanAction {
    CCScanQRViewController *scanVC = [[CCScanQRViewController alloc] init];
    scanVC.walletData = self.walletData;
    scanVC.delegate = self;
    scanVC.asset = self.asset;
    scanVC.ruleType = CCQRCodeRuleTypeReceive;
    [self.rt_navigationController pushViewController:scanVC animated:YES complete:nil];
}

#pragma mark - CCScanQRViewControllerDelegate
- (void)scanVC:(CCScanQRViewController *)scanVC tradeToAddress:(NSString *)toAddress asset:(CCAsset *)asset {
    [self.rt_navigationController popViewControllerAnimated:YES complete:nil];
    if (asset) {
        if (![asset isEqual:self.asset]) {
            [MBProgressHUD showMessage:Localized(@"Receipt asset does not match with transferred asset,please check again")];
            return;
        }
    }
    self.toAddress = toAddress;
    [self.transferView changeToAddress:toAddress];
}



#pragma mark - createView
- (void)createView {
    [self.view addSubview:self.transferView];
    [self.transferView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark - CCTransferViewDelegate
- (void)transferView:(CCTransferView *)transferView remark:(NSString *)remark toAddress:(NSString *)toAddress number:(NSString *)number  {
    if (number.doubleValue == 0) {
        CCAccountData *account = [[CCDataManager dataManager] accountWithAccountID:self.walletData.wallet.accountID];
        if (account.account.walletType == CCWalletTypeHardware) {
            [MBProgressHUD showMessage:Localized(@"Transfer amount cannot be 0")];
            return;
        }
    }
    CCTradeConfirmViewController *confirmVC = [[CCTradeConfirmViewController alloc] init];
    confirmVC.isDapp = NO;
    confirmVC.remark = remark;
    confirmVC.toAddress = toAddress;
    confirmVC.value = number.length==0?@"0":number;
    confirmVC.walletData = self.walletData;
    confirmVC.tokenModel = self.tokenModel;
    confirmVC.asset = self.asset;
    [self.rt_navigationController pushViewController:confirmVC animated:YES complete:nil];
}


#pragma mark - get
- (CCTransferView *)transferView {
    if (!_transferView) {
        _transferView  = [[CCTransferView alloc] initWithAsset:self.asset walletData:self.walletData toAddress:self.toAddress];
        [_transferView bindTokenModel:self.tokenModel];
        _transferView.transferDelegate = self;
    }
    return _transferView;
}

@end
