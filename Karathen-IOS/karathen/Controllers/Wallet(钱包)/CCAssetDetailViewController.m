//
//  KarathenDetailViewController.m
//  Karathen
//
//  Created by Karathen on 2018/7/23.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCAssetDetailViewController.h"
#import "CCReceiveViewController.h"
#import "CCTransferViewController.h"
#import "CCTradeDetailViewController.h"

#import "CCAssetTradeListView.h"
#import "CCAssetDetailHeadView.h"

@interface CCAssetDetailViewController ()
<
CCAssetDetailHeadViewDelegate,
CCAssetTradeListViewDelegate
>

@property (nonatomic, strong) CCAssetTradeListView *tableView;
@property (nonatomic, strong) CCAssetDetailHeadView *headView;

@end

@implementation CCAssetDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = [NSString stringWithFormat:@"%@ - %@",[CCDataManager coinKeyWithType:self.wallet.type],self.asset.tokenSynbol];
    [self createView];

    [self addNotify];
}

#pragma mark - addNotify
- (void)addNotify {
    @weakify(self)
    //钱包余额
    [CCNotificationCenter receiveWalletBalanceChangeObserver:self completion:^(NSString *walletAddress) {
        @strongify(self)
        if ([self.wallet.address compareWithString:walletAddress]) {
            [self.headView reloadDataWithAsset:self.asset];
        }
    }];
}

#pragma mark - super method
- (void)languageChange:(NSString *)language {
    [self.headView reloadHead];
    [self.tableView reloadData];
}

#pragma mark - createView
- (void)createView {
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    self.headView.frame = CGRectMake(0, 0, SCREEN_WIDTH, FitScale(192));
    self.tableView.tableHeaderView = self.headView;

    [self.headView reloadDataWithAsset:self.asset];
}

#pragma mark - CCAssetDetailHeadViewDelegate
- (void)transferHeadView:(CCAssetDetailHeadView *)headView {
    CCTransferViewController *transferVC = [[CCTransferViewController alloc] init];
    transferVC.asset = self.asset;
    transferVC.walletData = self.wallet;
    [self.rt_navigationController pushViewController:transferVC animated:YES complete:nil];
}

- (void)receiveHeadView:(CCAssetDetailHeadView *)headView {
    CCReceiveViewController *receiveVC = [[CCReceiveViewController alloc] init];
    receiveVC.walletData = self.wallet;
    receiveVC.asset = self.asset;
    [self.rt_navigationController pushViewController:receiveVC animated:YES complete:nil];
}

#pragma mark - CCAssetTradeListViewDelegate
- (void)tradeListView:(CCAssetTradeListView *)listView tradeDetailModel:(CCTradeRecordModel *)tradeModel value:(NSString *)value {
    CCTradeDetailViewController *vc = [[CCTradeDetailViewController alloc] init];
    vc.tradeModel = tradeModel;
    vc.walletData = self.wallet;
    vc.value = value;
    vc.asset = self.asset;
    [self.rt_navigationController pushViewController:vc animated:YES complete:nil];
}

- (void)tradeListViewDidScroll:(CCAssetTradeListView *)listView {
    [self.headView changeBackWithOffset:listView.contentOffset];
}

#pragma mark - get
- (CCAssetTradeListView *)tableView {
    if (!_tableView) {
        _tableView = [[CCAssetTradeListView alloc] initWithStyle:UITableViewStyleGrouped asset:self.asset walletData:self.wallet];
        _tableView.listDelegate = self;
    }
    return _tableView;
}

- (CCAssetDetailHeadView *)headView {
    if (!_headView) {
        _headView = [[CCAssetDetailHeadView alloc] init];
        _headView.delegate = self;
    }
    return _headView;
}


@end
