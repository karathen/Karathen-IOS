//
//  CCErc721HistoryViewController.m
//  Karathen
//
//  Created by Karathen on 2018/9/14.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCErc721HistoryViewController.h"
#import "CCTradeDetailViewController.h"
#import "CCAssetTradeListView.h"

@interface CCErc721HistoryViewController () <CCAssetTradeListViewDelegate>

@property (nonatomic, strong) CCAssetTradeListView *tableView;

@end

@implementation CCErc721HistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = [NSString stringWithFormat:Localized(@"Transaction Records"),self.asset.tokenSynbol];
    [self createView];
}

#pragma mark - createView
- (void)createView {
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    self.tableView.headRefreshColor = CC_BLACK_COLOR;
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

#pragma mark - get
- (CCAssetTradeListView *)tableView {
    if (!_tableView) {
        _tableView = [[CCAssetTradeListView alloc] initWithStyle:UITableViewStyleGrouped asset:self.asset walletData:self.wallet];
        _tableView.listDelegate = self;
    }
    return _tableView;
}

@end
