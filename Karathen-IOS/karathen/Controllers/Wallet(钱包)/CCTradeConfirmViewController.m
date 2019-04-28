//
//  CCTradeConfirmViewController.m
//  Karathen
//
//  Created by Karathen on 2018/10/17.
//  Copyright © 2018 raistone. All rights reserved.
//

#import "CCTradeConfirmViewController.h"
#import "CCTradeConfirmView.h"
#import "CCAlertView.h"
#import "CCWalletData+ETH.h"
#import "CCWalletData+NEO.h"
#import "CCWalletData+ONT.h"
#import "CCCoreData+TradeRecord.h"
#import "CCTradeDetailViewController.h"
#import "CCTradeRecordModel.h"
#import "CCTXRemarkRequest.h"
#import "CCETHMonitor.h"
#import "CCNEOMonitor.h"
#import "CCONTMonitor.h"

@interface CCTradeConfirmViewController () <CCTradeConfirmViewDelegate>

@property (nonatomic, strong) CCTradeConfirmView *confirmView;
@property (nonatomic, strong) CCAlertView *alertView;
@property (nonatomic, strong) CCTXRemarkRequest *remarkRequest;

@property (nonatomic, strong) NSString *txId;
@end

@implementation CCTradeConfirmViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = Localized(@"Transfer Confirmation");
    
    [self createView];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (self.isDapp) {
        if (self.backTxHash) {
            self.backTxHash(self.txId);
        }
    }
}

#pragma mark - CCTradeConfirmViewDelegate
- (void)confrimView:(CCTradeConfirmView *)transferView gasPrice:(NSString *)gasPrice gasLimit:(NSString *)gasLimit {
    CCAccountData *accountData = [[CCDataManager dataManager] accountWithAccountID:self.walletData.wallet.accountID];
    BOOL isHardware = accountData.account.walletType == CCWalletTypeHardware;

    if (isHardware) {
        if (![CCBlueTooth blueTooth].blueToothOpen) {
            [MBProgressHUD showMessage:Localized(@"Please turn on the Bluetooth")];
            return;
        }
    }
    
    @weakify(self)
    [self showPassWordMaxLength:isHardware?6:0
                        onlyNum:isHardware
                     completion:^(NSString *text) {
                         @strongify(self)
                         [self transferWithPassword:text gasPrice:gasPrice gasLimit:gasLimit];
                     }];
}

- (void)transferWithPassword:(NSString *)password gasPrice:(NSString *)gasPrice gasLimit:(NSString *)gasLimit {
    self.alertView.message = Localized(@"Transferring");
    [self.alertView showView];
    if (self.isDapp) {
        @weakify(self)
        [CCETHApi transferWalletData:self.walletData passWord:password toAddress:self.toAddress gasPrice:gasPrice gasLimit:gasLimit value:self.value transdata:self.data completion:^(NSString *hashStr, NSString *gasPrice, NSString *gasLimit, NSString *data, BOOL suc, CCWalletError error) {
            @strongify(self)
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.alertView hiddenView];
                if (suc) {
                    self.txId = hashStr;
                    [self.rt_navigationController popViewControllerAnimated:YES complete:nil];
                } else {
                    [MBProgressHUD showMessage:[CCWalletManager messageWithError:error]];
                }
            });
        }];
    } else {
        CCAccountData *accountData = [[CCDataManager dataManager] accountWithAccountID:self.walletData.wallet.accountID];
        if (accountData.account.walletType == CCWalletTypeHardware) {
            [self transferByHardwarePassword:password gasPrice:gasPrice gasLimit:gasLimit];
        } else {
            @weakify(self)
            switch (self.walletData.type) {
                case CCCoinTypeETH:
                {
                    [self.walletData transferETHAsset:self.asset
                                            toAddress:self.toAddress
                                               number:self.value
                                             password:password
                                             gasPrice:gasPrice
                                             gasLimit:nil
                                           completion:^(BOOL suc, CCWalletError error, CCTradeRecordModel *tradeRecord) {
                                               @strongify(self)
                                               [self transferSuc:suc error:error remark:self.remark tradeRecord:tradeRecord];
                                           }];
                }
                    break;
                case CCCoinTypeNEO:
                {
                    [self.walletData transferNEOAsset:self.asset
                                            toAddress:self.toAddress
                                               number:self.value
                                             password:password
                                           completion:^(BOOL suc, CCWalletError error, CCTradeRecordModel *tradeRecord) {
                                               @strongify(self)
                                               [self transferSuc:suc error:error remark:self.remark tradeRecord:tradeRecord];
                                           }];
                }
                    break;
                case CCCoinTypeONT:
                {
                    [self.walletData transferONTAsset:self.asset
                                            toAddress:self.toAddress
                                               number:self.value
                                             password:password
                                           completion:^(BOOL suc, CCWalletError error, CCTradeRecordModel * _Nonnull tradeRecord) {
                                               @strongify(self)
                                               [self transferSuc:suc error:error remark:self.remark tradeRecord:tradeRecord];
                                           }];
                }
                    break;
                default:
                    break;
            }
        }
    }
}

#pragma mark - 硬件转账
- (void)transferByHardwarePassword:(NSString *)password gasPrice:(NSString *)gasPrice gasLimit:(NSString *)gasLimit {
    if ([CCHardwareWallet hardwareWallet].isConnectDevice) {
        [self transferByHardwareAfterConnectPassword:password gasPrice:gasPrice gasLimit:gasLimit];
    } else {
        self.alertView.message = Localized(@"Connecting...");
        @weakify(self)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[CCHardwareWallet hardwareWallet] reConnectDeviceCompletion:^(BOOL success, int errorCode) {
                @strongify(self)
                if (success) {
                    [self transferByHardwareAfterConnectPassword:password gasPrice:gasPrice gasLimit:gasLimit];
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.alertView hiddenView];
                        [MBProgressHUD showMessage:Localized(@"Connection failed")];
                    });
                }
            }];
        });
    }
}

- (void)transferByHardwareAfterConnectPassword:(NSString *)password gasPrice:(NSString *)gasPrice gasLimit:(NSString *)gasLimit {
    self.alertView.message = Localized(@"Set the transaction information");
    @weakify(self)
    switch (self.walletData.type) {
        case CCCoinTypeETH:
        {
            [self.walletData transferHardwareETHAsset:self.asset
                                            toAddress:self.toAddress
                                               number:self.value
                                             password:password
                                             gasPrice:gasPrice
                                             gasLimit:nil
                                              process:^(NSString *message) {
                                                  @strongify(self)
                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                      self.alertView.message = message;
                                                  });
                                              }
                                           completion:^(BOOL suc, CCWalletError error, CCTradeRecordModel *tradeRecord) {
                                               @strongify(self)
                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                   [self.alertView hiddenView];
                                                   [self transferSuc:suc error:error remark:self.remark tradeRecord:tradeRecord];
                                               });
                                           }];
        }
            break;
        case CCCoinTypeNEO:
        {
        }
            break;
        case CCCoinTypeONT:
        {
        }
            break;
        default:
            break;
    }
}

- (void)transferSuc:(BOOL)suc error:(CCWalletError)error remark:(NSString *)remark tradeRecord:(CCTradeRecordModel *)tradeRecord {
    tradeRecord.remark = remark;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (suc) {
            if (remark.length && remark) {
                @weakify(self)
                [self remarkTxId:tradeRecord.txId remark:remark completion:^(BOOL suc) {
                    @strongify(self)
                    [self.alertView hiddenView];
                    if (suc) {
                        [self saveTradeRecord:tradeRecord];
                        [MBProgressHUD showMessage:[CCWalletManager messageWithError:error]];
                    } else {
                        tradeRecord.remark = @"";
                        [self saveTradeRecord:tradeRecord];
                        [MBProgressHUD showMessage:[CCWalletManager messageWithError:CCWalletTradeSucReamrkFail]];
                    }
                }];
            } else {
                [self.alertView hiddenView];
                [MBProgressHUD showMessage:[CCWalletManager messageWithError:error]];
                [self saveTradeRecord:tradeRecord];
            }
        } else {
            [self.alertView hiddenView];
            [MBProgressHUD showMessage:[CCWalletManager messageWithError:error]];
        }
    });
}

#pragma mark - transfer
- (void)saveTradeRecord:(CCTradeRecordModel *)tradeRecord {
    //存储
    CCTradeRecord *record = [[CCCoreData coreData] saveTradeRecord:tradeRecord
                                                     walletAddress:self.walletData.address
                                                      tokenAddress:self.asset.tokenAddress accountID:self.walletData.wallet.accountID
                                                        completion:nil];
    switch (self.walletData.type) {
        case CCCoinTypeETH:
            [[CCETHMonitor monitor] addRecord:record];
            break;
        case CCCoinTypeNEO:
            [[CCNEOMonitor monitor] addRecord:record];
            break;
        case CCCoinTypeONT:
            [[CCONTMonitor monitor] addRecord:record];
            break;
        default:
            break;
    }
    CCTradeDetailViewController *tradeVC = [[CCTradeDetailViewController alloc] init];
    tradeVC.walletData = self.walletData;
    tradeVC.asset = self.asset;
    tradeVC.tradeModel = tradeRecord;
    tradeVC.value = tradeRecord.value;
    @weakify(self)
    [self.rt_navigationController pushViewController:tradeVC animated:YES complete:^(BOOL finished) {
        @strongify(self)
        [self.rt_navigationController removeViewController:self];
    }];
}

#pragma mark - 备注
- (void)remarkTxId:(NSString *)txId remark:(NSString *)remark completion:(void(^)(BOOL suc))completion {
    self.remarkRequest.txId = txId;
    self.remarkRequest.remark = remark?:@"";
    [self.remarkRequest requestCompletion:^(BOOL suc) {
        if (completion) {
            completion(suc);
        }
    }];
}



#pragma mark - createView
- (void)createView {
    [self.view addSubview:self.confirmView];
    [self.confirmView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark - confirmView
- (CCTradeConfirmView *)confirmView {
    if (!_confirmView) {
        if (self.isDapp) {
            _confirmView = [[CCTradeConfirmView alloc] initWithWalletData:self.walletData toAddress:self.toAddress gasPrice:self.gasPrice gasLimit:self.gasLimit toDapp:self.dappUrl value:self.value remark:nil];
        } else {
            _confirmView = [[CCTradeConfirmView alloc] initWithWalletData:self.walletData asset:self.asset toAddress:self.toAddress value:self.value tokenModel:self.tokenModel remark:self.remark];
        }
        _confirmView.confirmDelegate = self;
    }
    return _confirmView;
}

- (CCAlertView *)alertView {
    if (!_alertView) {
        _alertView = [CCAlertView alertViewMessage:nil sureTitle:nil withType:CCAlertViewTypeLoading];
    }
    return _alertView;
}

- (CCTXRemarkRequest *)remarkRequest {
    if (!_remarkRequest) {
        _remarkRequest = [[CCTXRemarkRequest alloc] init];
    }
    return _remarkRequest;
}


@end
