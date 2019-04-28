//
//  CCDappViewController.m
//  Karathen
//
//  Created by Karathen on 2018/10/25.
//  Copyright © 2018 raistone. All rights reserved.
//

#import "CCDappViewController.h"
#import "CCDAppBrowserWKVC.h"
#import "CCWalletOptionView.h"

@interface CCDappViewController ()

@property (nonatomic, strong) CCDAppBrowserWKVC *webVC;
@property (nonatomic, strong) UILabel *addressLab;
@property (nonatomic, weak) CCWalletData *walletData;
@property (nonatomic, strong) CCWalletOptionView *optionView;

@end

@implementation CCDappViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.rt_disableInteractivePop = NO;

    [self setNav];
    [self createView];
}

#pragma mark - createView
- (void)createView {
    self.webVC.walletData = self.walletData;
    self.webVC.webUrl = self.url;
    [self.view addSubview:self.webVC.view];
    [self addChildViewController:self.webVC];
    [self.webVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark - 更改地址
- (void)showChangeWallet {
    [self.optionView showTargetView:self.addressLab space:0];
}

- (void)changeWalletData:(CCWalletData *)walletData {
    self.walletData = walletData;
    self.addressLab.text = self.walletData.address;
    [self.webVC changeWalletData:walletData];
}

#pragma mark - setNav
- (void)setNav {
    self.navigationItem.leftBarButtonItems = @[[self goBackItem],[self reloadItem]];
    self.navigationItem.rightBarButtonItem = [self closeItem];
    self.navigationItem.titleView = [self titleView];
}

- (UIBarButtonItem *)goBackItem {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.bounds = CGRectMake(0, 0, FitScale(40), NAVIGATION_BAR_HEIGHT);
    [btn setImage:[UIImage imageNamed:@"cc_nav_back"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(gotoBack) forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:btn];
}

- (UIBarButtonItem *)reloadItem {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.bounds = CGRectMake(0, 0, FitScale(40), NAVIGATION_BAR_HEIGHT);
    [btn setImage:[UIImage imageNamed:@"cc_nav_reload"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(reloadAction) forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:btn];
}

- (UIBarButtonItem *)closeItem {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.bounds = CGRectMake(0, 0, FitScale(40), NAVIGATION_BAR_HEIGHT);
    [btn setImage:[UIImage imageNamed:@"cc_nav_close"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:btn];
}

- (UIView *)titleView {
    UIView *titleView = [[UIView alloc] init];
    [titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(NAVIGATION_BAR_HEIGHT);
    }];
    
    [titleView addSubview:self.addressLab];
    [self.addressLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(titleView);
        make.width.mas_equalTo(FitScale(80));
        make.height.mas_equalTo(NAVIGATION_BAR_HEIGHT);
    }];
    
    UIImageView *imageV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cc_more_arrow"]];
    [titleView addSubview:imageV];
    [imageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.addressLab.mas_centerY);
        make.left.equalTo(self.addressLab.mas_right).offset(FitScale(5));
        make.right.equalTo(titleView.mas_right);
    }];
    self.addressLab.text = self.walletData.address;
    
    @weakify(self)
    [titleView cc_tapHandle:^{
        @strongify(self)
        [self showChangeWallet];
    }];
    return titleView;
}

#pragma mark - action
- (void)gotoBack {
    if (self.webVC.webView.canGoBack) {
        [self.webVC.webView goBack];
    } else {
        [self closeAction];
    }
}

- (void)reloadAction {
    [self.webVC reloadWeb];
}

- (void)closeAction {
    [self.rt_navigationController popViewControllerAnimated:YES complete:nil];
}


#pragma mark - get
- (CCDAppBrowserWKVC *)webVC {
    if (!_webVC) {
        _webVC = [[CCDAppBrowserWKVC alloc] init];
    }
    return _webVC;
}

- (UILabel *)addressLab {
    if (!_addressLab) {
        _addressLab = [[UILabel alloc] init];
        _addressLab.textColor = CC_BLACK_COLOR;
        _addressLab.font = MediumFont(FitScale(14));
        _addressLab.lineBreakMode = NSLineBreakByTruncatingMiddle;
    }
    return _addressLab;
}

- (CCWalletData *)walletData {
    if (!_walletData) {
        CCAccountData *accountData = [CCDataManager dataManager].activeAccount;
        CCCoinData *coinData = [accountData coinDataWithCoinType:CCCoinTypeETH];
        _walletData = coinData.activeWallet;
    }
    return _walletData;
}

- (CCWalletOptionView *)optionView {
    if (!_optionView) {
        _optionView = [[CCWalletOptionView alloc] initWithCoinType:CCCoinTypeETH walletData:self.walletData];
        @weakify(self)
        _optionView.chooseWallet = ^(CCWalletData *walletData) {
            @strongify(self)
            [self changeWalletData:walletData];
        };
    }
    return _optionView;
}

@end
