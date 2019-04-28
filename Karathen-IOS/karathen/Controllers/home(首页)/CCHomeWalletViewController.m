//
//  CCHomeWalletViewController.m
//  Karathen
//
//  Created by Karathen on 2018/7/10.
//  Copyright © 2018年 Karathen. All rights reserved.
//

#import "CCHomeWalletViewController.h"
#import "CCCreateWalletViewController.h"
#import "CCImportHDWalletVC.h"
#import "CCHomeWalletView.h"
#import "CCHardwareListVC.h"

@interface CCHomeWalletViewController () <CCHomeWalletViewDelegate>

@property (nonatomic, strong) CCHomeWalletView *walletView;

@property (nonatomic, strong) UIButton *createBtn;
@property (nonatomic, strong) UIButton *importBtn;

@property (nonatomic, assign) CCWalletType walletType;

@end

@implementation CCHomeWalletViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = Localized(@"Karathen");
    
    [self createView];
    [self walletTypeChangeWithView:self.walletView];
}


#pragma mark - CCHomeWalletViewDelegate
- (void)walletTypeChangeWithView:(CCHomeWalletView *)walletView {
    switch (walletView.walletType) {
        case CCWalletTypePhone:
        {
            self.importBtn.hidden = NO;
            [self.createBtn setTitle:Localized(@"Create Wallet") forState:UIControlStateNormal];
            [self.importBtn setTitle:Localized(@"Import Wallet") forState:UIControlStateNormal];
        }
            break;
        case CCWalletTypeHardware:
        {
            [self.createBtn setTitle:Localized(@"Connect device") forState:UIControlStateNormal];
            self.importBtn.hidden = YES;
        }
            break;
        default:
            break;
    }
}


#pragma mark - method
//创建
- (void)createAction {
    CCWalletType walletType = self.walletView.walletType;
    switch (walletType) {
        case CCWalletTypePhone:
        {
            CCCreateWalletViewController *createVC = [[CCCreateWalletViewController alloc] init];
            createVC.walletType = walletType;
            [self.rt_navigationController pushViewController:createVC animated:YES complete:nil];
        }
            break;
        case CCWalletTypeHardware:
        {
            if ([CCBlueTooth blueTooth].blueToothOpen) {
                CCHardwareListVC *listVC = [[CCHardwareListVC alloc] init];
                [self.rt_navigationController pushViewController:listVC animated:YES complete:nil];
            } else {
                [CCAlertView showAlertWithMessage:Localized(@"Please turn on the Bluetooth")];
            }
        }
            break;
        default:
            break;
    }

}

//导入
- (void)importAction {
    CCWalletType walletType = self.walletView.walletType;
    switch (walletType) {
        case CCWalletTypePhone:
        {
            CCImportHDWalletVC *importVC = [[CCImportHDWalletVC alloc] init];
            [self.rt_navigationController pushViewController:importVC animated:YES complete:nil];
        }
            break;
        default:
            break;
    }
}

#pragma mark - CCHomeWalletViewDelegate
- (void)walletTypeChange:(CCWalletType)walletType {
    self.walletType = walletType;
}

#pragma mark - createView
- (void)createView {
    if (self.presentingViewController) {
        [self addNotify];
        [self rightItem];
    }
    
    [self.view addSubview:self.importBtn];
    [self.importBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom).offset(FitScale(-80));
        make.left.equalTo(self.view.mas_left).offset(FitScale(40));
        make.centerX.equalTo(self.view.mas_centerX);
        make.height.mas_equalTo(FitScale(40));
    }];
    
    [self.view addSubview:self.createBtn];
    [self.createBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.importBtn.mas_left);
        make.right.equalTo(self.importBtn.mas_right);
        make.height.equalTo(self.importBtn.mas_height);
        make.bottom.equalTo(self.importBtn.mas_top);
    }];
    
    [self.view addSubview:self.walletView];
    [self.walletView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.view);
        make.bottom.equalTo(self.createBtn.mas_top);
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

- (void)addNotify {
    @weakify(self)
    [CCNotificationCenter receiveAccountChangeObserver:self completion:^(BOOL add, NSString *accountID) {
        @strongify(self)
        dispatch_async(dispatch_get_main_queue(), ^{
            if (add) {
                if ([CCDataManager dataManager].accounts.count > 1) {
                    [self dismissAction];
                }
            }
        });
    }];
}

- (void)rightItem {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:@"cc_nav_close"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(dismissAction) forControlEvents:UIControlEventTouchUpInside];
    btn.frame = CGRectMake(0, 0, FitScale(60), NAVIGATION_BAR_HEIGHT);
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    btn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, FitScale(10));
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = item;
}

- (void)dismissAction {
    [self.rt_navigationController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - get
- (UIButton *)createBtn {
    if (!_createBtn) {
        _createBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _createBtn.backgroundColor = CC_MAIN_COLOR;
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
        [_importBtn setTitleColor:CC_MAIN_COLOR forState:UIControlStateNormal];
        _importBtn.titleLabel.font = MediumFont(FitScale(14));
    }
    return _importBtn;
}

- (CCHomeWalletView *)walletView {
    if (!_walletView) {
        _walletView = [[CCHomeWalletView alloc] init];
        _walletView.delegate = self;
    }
    return _walletView;
}


@end
