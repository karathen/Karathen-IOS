//
//  CCHardwareListVC.m
//  ccAsset
//
//  Created by SealWallet on 2018/11/29.
//  Copyright © 2018 raistone. All rights reserved.
//

#import "CCHardwareListVC.h"
#import "CCHardwareListView.h"
#import "NSData+Extend.h"
#import "CCCreateWalletViewController.h"

@interface CCHardwareListVC () <CCHardwareListViewDelegate>

@property (nonatomic, strong) CCHardwareListView *listView;

@end

@implementation CCHardwareListVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = Localized(@"Device list");
    [self createView];
    
    if ([CCHardwareWallet hardwareWallet].isConnectDevice) {
        [self connectDeviceSuccess:0 deviceName:nil];
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
        [CCAlertView showLoadingMessage:Localized(@"Checking if the wallet had been imported")];
    });
    @weakify(self)
    [[CCHardwareWallet hardwareWallet] getETHDeviceAddressWithSlot:0 showScreen:NO completion:^(BOOL suc, int errorCode, NSString *address) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [CCAlertView hidenAlertLoading];
            @strongify(self)
            DLog(@"error - %@",[Utils errorCodeToString:errorCode]);
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

@end
