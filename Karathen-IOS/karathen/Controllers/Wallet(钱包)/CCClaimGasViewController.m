//
//  CCClaimGasViewController.m
//  Karathen
//
//  Created by Karathen on 2018/9/11.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCClaimGasViewController.h"
#import "CCNEOApi.h"
#import "CCONTApi.h"
#import "CCWalletEditView.h"
#import "CCAlertView.h"

@interface CCClaimGasViewController ()

@property (nonatomic, strong) CCWalletEditView *addressView;
@property (nonatomic, strong) CCWalletEditView *claimView;
@property (nonatomic, strong) CCWalletEditView *unClaimView;
@property (nonatomic, strong) CCAlertView *alertView;
@property (nonatomic, strong) UIButton *claimBtn;
@property (nonatomic, strong) UILabel *descLab;

@end

@implementation CCClaimGasViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createView];
    [self languageChange:nil];
    
    [self requestClaimData];
}

#pragma mark - createView
- (void)createView {
    [self.contentView addSubview:self.addressView];
    [self.addressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left);
        make.centerX.equalTo(self.contentView.mas_centerX);
        make.top.equalTo(self.contentView.mas_top).offset(FitScale(6));
    }];
    
    [self.contentView addSubview:self.claimView];
    [self.claimView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left);
        make.centerX.equalTo(self.contentView.mas_centerX);
        make.top.equalTo(self.addressView.mas_bottom);
    }];
    
    [self.contentView addSubview:self.unClaimView];
    [self.unClaimView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left);
        make.centerX.equalTo(self.contentView.mas_centerX);
        make.top.equalTo(self.claimView.mas_bottom);
    }];
    
    [self.contentView addSubview:self.claimBtn];
    [self.claimBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(FitScale(40));
        make.centerX.equalTo(self.contentView.mas_centerX);
        make.height.mas_equalTo(FitScale(40));
        make.top.equalTo(self.unClaimView.mas_bottom).offset(FitScale(30));
    }];
    
    [self.contentView addSubview:self.descLab];
    [self.descLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.claimBtn);
        make.top.equalTo(self.claimBtn.mas_bottom).offset(FitScale(20));
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-FitScale(20));
    }];
    
    self.addressView.title = self.walletData.walletName;
    self.addressView.placeholder = self.walletData.address;
    
    @weakify(self)
    [self.claimBtn cc_tapHandle:^{
        @strongify(self)
        [self claimAction];
    }];
}

#pragma mark - 提取
- (void)claimAction {
    CCAccountData *account = [[CCDataManager dataManager] accountWithAccountID:self.walletData.wallet.accountID];
    BOOL isHardware = account.account.walletType == CCWalletTypeHardware;
    @weakify(self)
    [self showPassWordMaxLength:isHardware?6:0
                        onlyNum:isHardware
                     completion:^(NSString *text) {
                         @strongify(self)
                         [self claimGasWithPassword:text];
                     }];
}

- (void)claimGasWithPassword:(NSString *)password {
    NSString *symbol = [self.walletData claimSymbol];
    self.alertView.message = [NSString stringWithFormat:Localized(@"Claiming Symbol"),symbol];
    [self.alertView showView];
    @weakify(self)
    if (self.walletData.type == CCCoinTypeNEO) {
        [[CCNEOApi manager] claimGasWalletData:self.walletData password:password completion:^(BOOL suc, CCWalletError error) {
            @strongify(self)
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.alertView hiddenView];
                [MBProgressHUD showMessage:[CCWalletManager messageWithError:error]];
                if (suc) {
                    [self.rt_navigationController popViewControllerAnimated:YES complete:nil];
                }
            });
        }];
    } else if (self.walletData.type == CCCoinTypeONT) {
        NSString *amount = self.claimView.placeholder;
        if (amount.doubleValue == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.alertView hiddenView];
                [MBProgressHUD showMessage:[CCWalletManager messageWithError:CCWalletClaimGasFail]];
            });
        } else {
            [[CCONTApi manager] claimWalletData:self.walletData password:password amount:amount completion:^(BOOL suc, CCWalletError error) {
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
    }
}


#pragma mark - loadData
- (void)requestClaimData {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    @weakify(self)
    if (self.walletData.type == CCCoinTypeNEO) {
        [[CCNEOApi manager] getGasWithAddress:self.walletData.address completion:^(BOOL suc, NSString *allGas, NSString *claimedGas, NSString *unClaimedGas) {
            @strongify(self)
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (suc) {
                self.claimView.placeholder = claimedGas;
                self.unClaimView.placeholder = unClaimedGas;
            }
        }];
    } else if (self.walletData.type == CCCoinTypeONT) {
        [[CCONTApi manager] getONGWithAddress:self.walletData.address completion:^(BOOL suc, NSString *claimedONG, NSString *unClaimedONG) {
            @strongify(self)
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (suc) {
                self.claimView.placeholder = claimedONG;
                self.unClaimView.placeholder = unClaimedONG;
            }
        }];
    }
}



#pragma mark - super method
- (void)languageChange:(NSString *)language {
    NSString *symbol = [self.walletData claimSymbol];
    self.title = [NSString stringWithFormat:Localized(@"Claim Symbol"),symbol];
    self.claimView.title = [NSString stringWithFormat:Localized(@"Claimed Symbol"),symbol];
    self.unClaimView.title = [NSString stringWithFormat:Localized(@"Unclaimed Symbol"),symbol];
    [self.claimBtn setTitle:Localized(@"Claim") forState:UIControlStateNormal];
    
    if (self.walletData.type == CCCoinTypeONT) {
        self.descLab.text = Localized(@"ONT ClaimGas hint");
    }
}

#pragma mark - get
- (CCWalletEditView *)addressView {
    if (!_addressView) {
        _addressView = [[CCWalletEditView alloc] init];
        _addressView.descLab.textColor = CC_BLACK_COLOR;
    }
    return _addressView;
}

- (CCWalletEditView *)claimView {
    if (!_claimView) {
        _claimView = [[CCWalletEditView alloc] init];
        _claimView.descLab.textColor = CC_BLACK_COLOR;
        _claimView.placeholder = @"0";
    }
    return _claimView;
}

- (CCWalletEditView *)unClaimView {
    if (!_unClaimView) {
        _unClaimView = [[CCWalletEditView alloc] init];
        _unClaimView.descLab.textColor = CC_BLACK_COLOR;
        _unClaimView.placeholder = @"0";
    }
    return _unClaimView;
}

- (UIButton *)claimBtn {
    if (!_claimBtn) {
        _claimBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _claimBtn.backgroundColor = CC_MAIN_COLOR;
        _claimBtn.layer.cornerRadius = FitScale(5);
        _claimBtn.layer.masksToBounds = YES;
        [_claimBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _claimBtn.titleLabel.font = MediumFont(FitScale(14));
    }
    return _claimBtn;
}

- (CCAlertView *)alertView {
    if (!_alertView) {
        _alertView = [CCAlertView alertViewMessage:nil sureTitle:nil withType:CCAlertViewTypeLoading];
    }
    return _alertView;
}

- (UILabel *)descLab {
    if (!_descLab) {
        _descLab = [[UILabel alloc] init];
        _descLab.textColor = CC_GRAY_TEXTCOLOR;
        _descLab.font = MediumFont(FitScale(12));
        _descLab.numberOfLines = 0;
    }
    return _descLab;
}

@end
