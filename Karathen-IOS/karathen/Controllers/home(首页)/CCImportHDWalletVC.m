//
//  CCImportHDWalletVC.m
//  Karathen
//
//  Created by Karathen on 2018/7/16.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCImportHDWalletVC.h"
#import "CCImportWalletView.h"
#import "CCCreateWalletViewController.h"
#import "CCScanQRViewController.h"

@interface CCImportHDWalletVC () <CCImportWalletViewDelegate,CCScanQRViewControllerDelegate>

@property (nonatomic, strong) CCImportWalletView *importView;

@end

@implementation CCImportHDWalletVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = Localized(@"Import Wallet");
    [self createView];
}


#pragma mark - createView
- (void)createView {
    [self.view addSubview:self.importView];
    [self.importView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self setScanItem];
}

#pragma mark - 扫描二维码
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
    scanVC.delegate = self;
    scanVC.ruleType = CCQRCodeRuleTypeNone;
    [self.rt_navigationController pushViewController:scanVC animated:YES complete:nil];
}

#pragma mark - CCScanQRViewControllerDelegate
- (void)scanVC:(CCScanQRViewController *)scanVC result:(NSString *)result {
    [self.rt_navigationController popViewControllerAnimated:YES complete:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.importView changeWalletInfo:result];
    });
}


#pragma mark - CCImportWalletViewDelegate
- (void)createActionImportView:(CCImportWalletView *)importView {
    CCCreateWalletViewController *createVC = [[CCCreateWalletViewController alloc] init];
    createVC.walletType = self.walletType;
    @weakify(self)
    [self.rt_navigationController pushViewController:createVC animated:YES complete:^(BOOL finished) {
       @strongify(self)
        [self.rt_navigationController removeViewController:self];
    }];
}



#pragma mark - get
- (CCImportWalletView *)importView {
    if (!_importView) {
        _importView = [[CCImportWalletView alloc] initWithWalletType:self.walletType];
        _importView.importDelegate = self;
    }
    return _importView;
}

@end
