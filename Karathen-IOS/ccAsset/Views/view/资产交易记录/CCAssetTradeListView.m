//
//  CCAssetTradeListView.m
//  ccAsset
//
//  Created by SealWallet on 2018/9/14.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCAssetTradeListView.h"
#import "CCTradeRecordManager.h"
#import "CCTradeRecord+CoreDataClass.h"
#import "CCTradeRecordModel.h"
#import "CCTradeRecordRequest.h"
#import "CCAssetHistoryCell.h"
#import "CCAssetHistoryHeaderView.h"

@interface CCAssetTradeListView ()
<
UITableViewDelegate,
UITableViewDataSource,
CCAssetHistoryHeaderViewDelegate
>

//展示的是否是本地数据
@property (nonatomic, assign) CCAssetHistoryType type;
@property (nonatomic, strong) CCTradeRecordManager *recordManager;
@property (nonatomic, strong) CCTradeRecordRequest *tradeRequest;
@property (nonatomic, weak) CCAsset *asset;
@property (nonatomic, weak) CCWalletData *walletData;

@end

@implementation CCAssetTradeListView

- (instancetype)initWithStyle:(UITableViewStyle)style
                        asset:(CCAsset *)asset
                   walletData:(CCWalletData *)walletData {
    if (self = [super initWithFrame:CGRectZero style:style]) {
        self.asset = asset;
        self.walletData = walletData;
        [self initView];
    }
    return self;
}

#pragma mark - initView
- (void)initView {
    self.delegate = self;
    self.dataSource = self;
    [self registerClassCells:@[[CCAssetHistoryCell class]]];
    [self registerClass:[CCAssetHistoryHeaderView class] forHeaderFooterViewReuseIdentifier:@"CCAssetHistoryHeaderView"];
    
    //获取本地数据
    [self.recordManager requsetLocalData];
    
    self.type = CCAssetHistoryTypeTransfer;
    
    [self addNotify];
}

- (void)addNotify {
    @weakify(self)
    //资产交易记录增加
    [CCNotificationCenter receiveAssetTradeUpdateObserver:self completion:^(NSString *walletAddress, NSString *tokenAddress) {
        @strongify(self)
        if ([self.walletData.address compareWithString:walletAddress]) {
            [self.recordManager requsetLocalData];
            [self reloadData];
        }
    }];
    
    //块高更新
    [CCNotificationCenter receiveBlockHeightRefrshObserver:self completion:^(CCCoinType coinType) {
        @strongify(self)
        if (self.walletData.type == coinType) {
            [self reloadData];
        }
    }];
}

#pragma mark - 资产余额
- (void)queryBlancePrices {
    @weakify(self)
    [self.walletData queryAssetBalance:self.asset completion:^{
        @strongify(self)
        if (self.type == CCAssetHistoryTypeTransfer) {
            if ([self.mj_header isRefreshing]) {
                [self.mj_header endRefreshing];
            }
        }
    }];
}

#pragma mark - 请求相关
- (void)addMjHead {
    @weakify(self)
    CCRefreshNormalHeader *mjHeader = [CCRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self)
        [self loadHead];
    }];
    if (!self.headRefreshColor) {
        self.headRefreshColor = [UIColor whiteColor];
    }
    mjHeader.stateLabel.textColor = self.headRefreshColor;
    mjHeader.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    self.mj_header = mjHeader;
}

- (void)setHeadRefreshColor:(UIColor *)headRefreshColor {
    _headRefreshColor = headRefreshColor;
    CCRefreshNormalHeader *mjHeader = (CCRefreshNormalHeader *)self.mj_header;
    mjHeader.stateLabel.textColor = _headRefreshColor;
}


- (void)changeFooterWithHadMore:(BOOL)hadMore {
    if (self.tradeRequest.dataArray.count) {
        @weakify(self)
        self.mj_footer = [CCRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            @strongify(self)
            [self loadFoot];
        }];
    } else {
        self.mj_footer = nil;
    }
}

- (void)loadHead {
    [self queryBlancePrices];
    if (self.type == CCAssetHistoryTypeAll) {
        @weakify(self)
        [self.tradeRequest headRefreshBlock:^(NSArray *addArray) {
            @strongify(self)
            [self changeFooterWithHadMore:self.tradeRequest.hadMore];
            [self endRefreshWithHadMore:self.tradeRequest.hadMore addArray:addArray];
        }];
    }
}

- (void)loadFoot {
    @weakify(self)
    [self.tradeRequest footRefreshBlock:^(NSArray *addArray) {
        @strongify(self)
        [self endRefreshWithHadMore:self.tradeRequest.hadMore addArray:addArray];
    }];
}


- (void)endRefreshWithHadMore:(BOOL)hadMore addArray:(NSArray *)addArray {
    if ([self.mj_header isRefreshing]) {
        [self.mj_header endRefreshing];
    }
    if (hadMore) {
        [self.mj_footer endRefreshing];
    } else {
        [self.mj_footer endRefreshingWithNoMoreData];
    }
    [self reloadData];
}

#pragma mark - CCAssetHistoryHeaderViewDelegate
- (void)headView:(CCAssetHistoryHeaderView *)headView changeType:(CCAssetHistoryType)type {
    if (type == self.type) {
        return;
    }
    self.type = type;
    [self reloadData];
}

#pragma mark - 数据源切换
- (void)setType:(CCAssetHistoryType)type {
    _type = type;
    if ([self.mj_header isRefreshing]) {
        [self.mj_header endRefreshing];
    }
    if ([self.mj_footer isRefreshing]) {
        [self.mj_footer endRefreshing];
    }
    switch (type) {
        case CCAssetHistoryTypeAll:
        {
            [self addMjHead];
            [self changeFooterWithHadMore:self.tradeRequest.hadMore];
            if (self.tradeRequest.dataArray.count == 0) {
                [self loadHead];
            }
        }
            break;
        case CCAssetHistoryTypeTransfer:
        {
            [self loadHead];
            [self addMjHead];
            self.mj_footer = nil;
        }
            break;
        default:
            break;
    }
}

#pragma mark - tableview代理
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.type == CCAssetHistoryTypeTransfer) {
        return self.recordManager.localData.count;
    } else {
        return self.tradeRequest.dataArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CCAssetHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CCAssetHistoryCell"];
    CCTradeRecordModel *tradeModel;
    NSString *value;
    if (self.type == CCAssetHistoryTypeTransfer) {
        CCTradeRecord *record = self.recordManager.localData[indexPath.row];
        tradeModel = [CCTradeRecordModel recorModelWithRecord:record];
        value = tradeModel.value;
    } else {
        tradeModel = self.tradeRequest.dataArray[indexPath.row];
        
        value = [tradeModel decimalStringWithDecimal:self.asset.tokenDecimal coinType:self.walletData.type];
    }

    [cell bindCellWithModel:tradeModel walletData:self.walletData asset:self.asset value:value];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CCAssetHistoryHeaderView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"CCAssetHistoryHeaderView"];
    header.type = self.type;
    header.delegate = self;
    [header reloadHead];
    return header;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CCTradeRecordModel *tradeModel;
    NSString *value;
    if (self.type == CCAssetHistoryTypeTransfer) {
        CCTradeRecord *record = self.recordManager.localData[indexPath.row];
        tradeModel = [CCTradeRecordModel recorModelWithRecord:record];
        value = tradeModel.value;
    } else {
        tradeModel = self.tradeRequest.dataArray[indexPath.row];
        value = [tradeModel decimalStringWithDecimal:self.asset.tokenDecimal coinType:self.walletData.type];
    }

    if (tradeModel && self.listDelegate && [self.listDelegate respondsToSelector:@selector(tradeListView:tradeDetailModel:value:)]) {
        [self.listDelegate tradeListView:self tradeDetailModel:tradeModel value:value];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return FitScale(55);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return FitScale(40);
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.000001f;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.listDelegate && [self.listDelegate respondsToSelector:@selector(tradeListViewDidScroll:)]) {
        [self.listDelegate tradeListViewDidScroll:self];
    }
}

#pragma mark - get
- (CCTradeRecordRequest *)tradeRequest {
    if (!_tradeRequest) {
        _tradeRequest = [[CCTradeRecordRequest alloc] init];
        _tradeRequest.address = self.walletData.address;
        _tradeRequest.coinType = self.walletData.type;
        _tradeRequest.asset = self.asset;
    }
    return _tradeRequest;
}

- (CCTradeRecordManager *)recordManager {
    if (!_recordManager) {
        _recordManager = [[CCTradeRecordManager alloc] initWithWallet:self.walletData tokenAddress:self.asset.tokenAddress];
    }
    return _recordManager;
}

@end
