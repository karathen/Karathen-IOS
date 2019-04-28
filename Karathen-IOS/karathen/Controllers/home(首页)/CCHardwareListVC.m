//
//  CCHardwareListVC.m
//  karathen
//
//  Created by MengLiMing on 2018/11/29.
//  Copyright © 2018 raistone. All rights reserved.
//

#import "CCHardwareListVC.h"
#import "CCHardwareListView.h"
#import "NSData+Extend.h"
#import "CCCreateWalletViewController.h"

@interface CCHardwareListVC () <CCHardwareListViewDelegate>

@property (nonatomic, strong) CCHardwareListView *listView;
@property (nonatomic, strong) CCAlertView *alertView;

@end

@implementation CCHardwareListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = Localized(@"Device list");
    [self createView];
    
    if ([CCHardwareWallet hardwareWallet].isConnectDevice) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.alertView.message = Localized(@"Checking if the wallet had been imported");
            [self.alertView showView];
        });
        @weakify(self)
        [[CCHardwareWallet hardwareWallet] disconnectDeviceCompletion:^(BOOL success, int errorCode) {
            @strongify(self)
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.alertView hiddenView];
            });
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                [self.listView scannerHardware];
            });
        }];
    } else {
        [self.listView scannerHardware];
    }
}

#pragma mark - createView
- (void)createView {
    [self.view addSubview:self.listView];
    [self.listView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.bounds = CGRectMake(0, 0, FitScale(40), NAVIGATION_BAR_HEIGHT);
    [btn setImage:[UIImage imageNamed:@"cc_nav_reload"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(scannerHardware) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *scanItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = scanItem;
}

- (void)scannerHardware {
    [self.listView scannerHardware];
}

#pragma mark - CCHardwareListView
- (void)connectDeviceSuccess:(NSInteger)saveDevice deviceName:(NSString *)deviceName {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.alertView.message = Localized(@"Checking if the wallet had been imported");
        [self.alertView showView];
    });
    @weakify(self)
    [[CCHardwareWallet hardwareWallet] getETHDeviceAddressWithSlot:0 showScreen:NO deviceWaiting:^{
        @strongify(self)
        self.alertView.message = Localized(@"Press button to confirm address");
    } completion:^(BOOL suc, int errorCode, NSString *address) {
        @strongify(self)
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.alertView hiddenView];
            if (suc) {
                [self gotoNextWithWalletHadAddress:YES];
            } else {
                [self gotoNextWithWalletHadAddress:NO];
            }
        });
    }];
}

- (void)gotoNextWithWalletHadAddress:(BOOL)address {
    ///如果有地址，直接导入
    if (address) {
        UIViewController *importVC = [[NSClassFromString(@"CCImportHardwareAddressVC") alloc] init];
        [self.rt_navigationController pushViewController:importVC animated:YES complete:nil];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            CCCreateWalletViewController *createVC = [[CCCreateWalletViewController alloc] init];
            createVC.walletType = CCWalletTypeHardware;
            [self.rt_navigationController pushViewController:createVC animated:YES complete:nil];
        });
    }
}

#pragma mark - get
- (CCHardwareListView *)listView {
    if (!_listView) {
        _listView = [[CCHardwareListView alloc] init];
        _listView.hardwareDelegate = self;
    }
    return _listView;
}

- (CCAlertView *)alertView {
    if (!_alertView) {
        _alertView = [CCAlertView alertViewMessage:nil sureTitle:nil withType:CCAlertViewTypeLoading];
    }
    return _alertView;
}

@end
