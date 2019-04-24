//
//  CCWallet_RootViewController.m
//  ccAsset
//
//  Created by SealWallet on 2018/7/9.
//  Copyright © 2018年 SealWallet. All rights reserved.
//

#import "CCWallet_RootViewController.h"
#import "CCScanQRViewController.h"
#import "CCReceiveViewController.h"

#import "CCAssetDetailViewController.h"
#import "CCAddAssetViewController.h"
#import "CCTransferViewController.h"
#import "CCCoinAddressManageVC.h"

#import "CCAccountTitleView.h"
#import "CCWalletInfoHeadView.h"
#import "CCAddAssetHeaderView.h"
#import "CCWallteAssetBallanceCell.h"
#import "CCTableView.h"
#import "UIImageTool.h"
#import "CCCoreData+Asset.h"
#import <IQKeyboardManager/IQKeyboardManager.h>
#import "CCAssetFilterView.h"
#import "CCAssetDetailView.h"
#import "CCClaimGasViewController.h"
#import "CCErc721ListViewController.h"

@interface CCWallet_RootViewController ()
<
UITableViewDelegate,
UITableViewDataSource,
CCWalletInfoHeadViewDelegate,
CCAddAssetHeaderViewDelegate,
CCScanQRViewControllerDelegate
>

@property (nonatomic, strong) CCTableView *tableView;
@property (nonatomic, strong) CCWalletInfoHeadView *headView;
@property (nonatomic, strong) CCAccountTitleView *titleView;
@property (nonatomic, strong) CCAssetFilterView *filterView;

@property (nonatomic, strong) NSString *keyWord;
@property (nonatomic, strong) NSArray *filterArray;

@property (nonatomic, strong) CCAssetDetailView *assetDetailView;

@end

@implementation CCWallet_RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self dealFilterArray];
    
    [self navSet];
    
    [self createView];
    
    [self languageChange:nil];
    [self addObserver];
    
    [self queryAssetHold];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.headView reloadHeader];
    IQKeyboardManager *manager = [IQKeyboardManager sharedManager];
    manager.enable = NO;
    manager.shouldResignOnTouchOutside = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    IQKeyboardManager *manager = [IQKeyboardManager sharedManager];
    manager.enable = YES;
    manager.shouldResignOnTouchOutside = YES;
}

- (CCAccountData *)currentAccount {
    return [CCDataManager dataManager].activeAccount;
}

- (CCCoinData *)currentCoinData {
    return [self currentAccount].activeCoin;
}

- (CCWalletData *)currentWallet {
    return [self currentCoinData].activeWallet;
}


#pragma mark - 导航栏
- (void)navSet {
    [self.navigationController.navigationBar setBackgroundImage:[UIImageTool createImageWithColor:[UIColor whiteColor] andSize:CGSizeMake(1, 1)] forBarMetrics:UIBarMetricsDefault];
    [self receiveCodeItem];
    [self setTitleView];
    
    //扫描二维码
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.bounds = CGRectMake(0, 0, FitScale(60), NAVIGATION_BAR_HEIGHT);
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    btn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, FitScale(10));
    [btn setImage:[UIImage imageNamed:@"cc_scan_qr_item"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(scanAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
}

- (void)scanAction {
    if (![self currentCoinData]) {
        return;
    }
    CCScanQRViewController *scanVC = [[CCScanQRViewController alloc] init];
    scanVC.walletData = self.currentWallet;
    scanVC.ruleType = CCQRCodeRuleTypeReceive;
    scanVC.delegate = self;
    [self.rt_navigationController pushViewController:scanVC animated:YES complete:nil];
}

#pragma mark - 收款二维码
- (void)receiveCodeItem {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.bounds = CGRectMake(0, 0, FitScale(60), NAVIGATION_BAR_HEIGHT);
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    btn.imageEdgeInsets = UIEdgeInsetsMake(0, FitScale(10), 0, 0);
    [btn setImage:[UIImage imageNamed:@"cc_receive_qrcode_item"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(receiveCodeAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
}

- (void)receiveCodeAction {
    if (![self currentCoinData]) {
        return;
    }
    CCReceiveViewController *receiveVC = [[CCReceiveViewController alloc] init];
    receiveVC.walletData = self.currentWallet;
    [self.rt_navigationController pushViewController:receiveVC animated:YES complete:nil];
}

#pragma mark - setTitle
- (void)setTitleView {
    self.navigationItem.titleView = self.titleView;
    [self.titleView bindWithAccount:[self currentAccount]];
    
    @weakify(self)
    [self.titleView cc_tapHandle:^{
        @strongify(self)
        [self walletManagerAction];
    }];
}

#pragma mark - 钱包管理
- (void)walletManagerAction {
    UIViewController *vc = [[NSClassFromString(@"CCAccountManageVC") alloc] init];
    [self.rt_navigationController pushViewController:vc animated:YES complete:nil];
}


#pragma mark - 地址管理
- (void)coinManagerAction {
    if (![self currentCoinData]) {
        return;
    }
    CCCoinAddressManageVC *addressVC = [[CCCoinAddressManageVC alloc] init];
    addressVC.coinData = [self currentCoinData];
    [self.rt_navigationController pushViewController:addressVC animated:YES complete:nil];
}


#pragma mark - CCScanQRViewControllerDelegate
- (void)scanVC:(CCScanQRViewController *)scanVC tradeToAddress:(NSString *)toAddress asset:(CCAsset *)asset {
    if (toAddress) {
        if (!asset) {
            asset = [self currentWallet].assets.firstObject;
        }
        CCTransferViewController *transferVC = [[CCTransferViewController alloc] init];
        transferVC.toAddress = toAddress;
        transferVC.asset = asset;
        transferVC.walletData = self.currentWallet;
        [self.rt_navigationController pushViewController:transferVC animated:YES complete:nil];
    }
}


#pragma mark - 查询余额
- (void)queryBalancePriceWithAsset:(NSArray *)assets {
    @weakify(self)
    [self.currentWallet queryBalanceWithAsset:assets completion:^{
        @strongify(self)
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView.mj_header endRefreshing];
            [self.headView reloadData];
            [self.tableView reloadData];
        });
    }];
}

#pragma mark - 查询地址下的资产
- (void)queryAssetHold {
    @weakify(self)
    [self.currentWallet queryAssetHoldingCompletion:^{
        @strongify(self)
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.headView reloadData];
            [self.tableView reloadData];
        });
    } noContain:^(NSArray<CCAsset *> *assets) {
        @strongify(self)
        [self queryBalancePriceWithAsset:assets];
    }];
}

#pragma mark - 筛选数组
- (void)dealFilterArray {
    CCWalletData *walletData = self.currentWallet;
    if (!walletData.wallet.filterType && !walletData.wallet.isHideNoBalance && !self.keyWord) {
        self.filterArray = [walletData.assets mutableCopy];
    } else {
        NSArray *resultArray = [[CCCoreData coreData] searchAssetsWithWallet:self.currentWallet keyWord:self.keyWord isHiddenNoBalance:walletData.wallet.isHideNoBalance filterType:walletData.wallet.filterType walletAddress:walletData.address];
        self.filterArray = resultArray;
    }
}

#pragma mark - 通知
- (void)addObserver {
    @weakify(self)
    //链默认地址切换
    [CCNotificationCenter receiveSelectWalletChangeObserver:self completion:^(CCCoinType coinType, NSString *accountID) {
        @strongify(self)
        if (coinType == [self currentCoinData].coin.coinType && [accountID compareWithString:[self currentCoinData].coin.accountID]) {
            [self dealFilterArray];
            [self queryAssetHold];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.headView reloadHeader];
                [self.tableView reloadData];
            });
        }
    }];
    
    [CCNotificationCenter receiveAccountNameChangeObserver:self completion:^(NSString *accountID) {
        @strongify(self)
        if ([[self currentAccount].account.accountID compareWithString:accountID]) {
            [self.titleView bindWithAccount:[self currentAccount]];
        }
    }];
    
    [CCNotificationCenter receiveActiveAccountChangeObserver:self completion:^{
        @strongify(self)
        [self dealFilterArray];
        [self queryAssetHold];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.titleView bindWithAccount:[self currentAccount]];
            [self.headView reloadHeader];
            [self.tableView reloadData];
        });
    }];
    
    //筛选条件更改
    [CCNotificationCenter receiveWalletFilterChangeObserver:self completion:^(NSString *walletAddress) {
        @strongify(self)
        if ([walletAddress compareWithString:[self currentWallet].address]) {
            [self dealFilterArray];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
    }];
    
    [CCNotificationCenter receiveWalletHideNoBalanceChangeObserver:self completion:^(NSString *walletAddress) {
        @strongify(self)
        if ([walletAddress compareWithString:[self currentWallet].address]) {
            [self dealFilterArray];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
    }];
    
    //资产变化
    [CCNotificationCenter receiveAssetChangeObserver:self completion:^(NSString *address) {
        @strongify(self)
        if ([address compareWithString:[self currentWallet].address]) {
            [self dealFilterArray];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
    }];
    
    //货币种类
    [CCNotificationCenter receiveCurrencyUnitChangeObserver:self completion:^(NSString *currentUnit) {
        @strongify(self)
        [self.currentWallet changeCurrencyUnit];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self.headView reloadData];
        });
    }];
    
    //钱包余额
    [CCNotificationCenter receiveWalletBalanceChangeObserver:self completion:^(NSString *walletAddress) {
        @strongify(self)
        if ([self.currentWallet.address compareWithString:walletAddress]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                [self.headView reloadData];
            });
        }
    }];
    
    //钱包名称
    [CCNotificationCenter receiveWalletNameChangeObserver:self completion:^(NSString *walletAddress) {
        @strongify(self)
        if ([self.currentWallet.address compareWithString:walletAddress]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.headView reloadData];
            });
        }
    }];
    
    //链管理
    [CCNotificationCenter receiveCoinManageObserver:self completion:^{
        @strongify(self)
        dispatch_async(dispatch_get_main_queue(), ^{
            [self dealFilterArray];
            [self.tableView reloadData];
            [self.headView reloadData];
        });
    }];
}

#pragma mark - super method
- (void)languageChange:(NSString *)language {
    [self.tableView reloadData];
}

#pragma mark - createView
- (void)createView {
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    self.headView.frame = CGRectMake(0, 0, SCREEN_WIDTH, FitScale(184));
    self.tableView.tableHeaderView = self.headView;
    
    @weakify(self)
    self.tableView.mj_header = [CCRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self)
        [self queryAssetHold];
    }];
}

#pragma mark - CCAddAssetHeaderViewDelegate
- (void)addAssetHeadView:(CCAddAssetHeaderView *)headView {
    if ([self currentCoinData].wallets.count == 0) {
        return;
    }
    CCAddAssetViewController *addVC = [[CCAddAssetViewController alloc] init];
    addVC.wallet = [self currentWallet];
    [self.rt_navigationController pushViewController:addVC animated:YES complete:nil];
}

- (void)moreActionHeadView:(CCAddAssetHeaderView *)headView showView:(UIView *)showView {
    if ([self currentCoinData].wallets.count == 0) {
        return;
    }
    self.filterView.walletData = self.currentWallet;
    [self.filterView showTargetView:showView];
}

- (void)searchActionHeadView:(CCAddAssetHeaderView *)headView keyWord:(NSString *)keyWord {
    self.keyWord = keyWord;
    [self dealFilterArray];
    [self.tableView reloadData];
}


#pragma mark - createCoinData
- (void)createCoinData {
    CCAccountData *account = [self currentAccount];
    BOOL isHardware = account.account.walletType == CCWalletTypeHardware;
    @weakify(self)
    [self showPassWordMaxLength:isHardware?6:0
                        onlyNum:isHardware
                     completion:^(NSString *text) {
                         @strongify(self)
                         [self addWalletWithPassWord:text];
                     }];
}

- (void)addWalletWithPassWord:(NSString *)password {
    CCAccountData *account = [self currentAccount];
    @weakify(self)
    [account createCoinWithCoinData:account.activeCoin passWord:password completion:^(BOOL suc, CCWalletError error) {
        @strongify(self)
        if (suc) {
            [self dealFilterArray];
            [self queryAssetHold];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.headView reloadHeader];
                [self.tableView reloadData];
            });
        } else {
            [MBProgressHUD showMessage:[CCWalletManager messageWithError:error]];
        }
    }];
}


#pragma mark - CCWalletInfoHeadViewDelegate
- (void)headView:(CCWalletInfoHeadView *)headView didSelectedAtIndex:(NSInteger)index {
    if (self.currentCoinData.wallets.count) {
        [self coinManagerAction];
    } else {
        //添加
        [self createCoinData];
    }
}

- (void)headView:(CCWalletInfoHeadView *)headView changeToIndex:(NSInteger)index {
    [self dealFilterArray];
    [self.tableView reloadData];
}

- (void)headView:(CCWalletInfoHeadView *)headView endAtIndex:(NSInteger)index {
    [self queryAssetHold];
}

- (void)headView:(CCWalletInfoHeadView *)headView extractGasWithWallet:(CCWalletData *)walletData {
    CCClaimGasViewController *gasVC = [[CCClaimGasViewController alloc] init];
    gasVC.walletData = walletData;
    [self.rt_navigationController pushViewController:gasVC animated:YES complete:nil];
}

#pragma mark - tableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filterArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CCWallteAssetBallanceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CCWallteAssetBallanceCell"];
    [cell bindCellWithAsset:self.filterArray[indexPath.row] walletData:self.currentWallet];
    @weakify(self)
    cell.showAssetDetail = ^(CCAsset *asset, UIButton *button) {
        @strongify(self)
        self.assetDetailView.asset = asset;
        [self.assetDetailView showTargetView:button];
    };
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if ([self currentCoinData]) {
        CCAddAssetHeaderView *headview = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"CCAddAssetHeaderView"];
        headview.delegate = self;
        [headview reloadHead];
        return headview;
    } else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([self currentCoinData]) {
        return FitScale(30);
    } else {
        return .00001f;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return FitScale(62);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CCAsset *asset = self.filterArray[indexPath.row];
    if ([asset.tokenType compareWithString:CCAseet_ETH_ERC721]) {
        CCErc721ListViewController *listVC = [[CCErc721ListViewController alloc] init];
        listVC.asset = asset;
        listVC.wallet = self.currentWallet;
        [self.rt_navigationController pushViewController:listVC animated:YES complete:nil];
    } else {
        CCAssetDetailViewController *assetVC = [[CCAssetDetailViewController alloc] init];
        assetVC.asset = asset;
        assetVC.wallet = self.currentWallet;
        [self.rt_navigationController pushViewController:assetVC animated:YES complete:nil];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    @weakify(self)
    UITableViewRowAction *deleAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:Localized(@"Delete") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        @strongify(self)
        [self deleteAsset:indexPath];
    }];
    CCAsset *asset = self.filterArray[indexPath.row];
    if (asset.notDelete) {
        deleAction.backgroundColor = [UIColor grayColor];
    } else {
        deleAction.backgroundColor = [UIColor redColor];
    }
    return @[deleAction];
}

#pragma mark - 删除
- (void)deleteAsset:(NSIndexPath *)indexPath {
    CCAsset *asset = self.filterArray[indexPath.row];
    if (!asset.notDelete) {
        [self.currentWallet deleteAsset:asset];
    }
}



#pragma mark - get
- (CCTableView *)tableView {
    if (!_tableView) {
        _tableView = [[CCTableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClassCells:@[[CCWallteAssetBallanceCell class]]];
        [_tableView registerClass:[CCAddAssetHeaderView class] forHeaderFooterViewReuseIdentifier:@"CCAddAssetHeaderView"];
    }
    return _tableView;
}

- (CCWalletInfoHeadView *)headView {
    if (!_headView) {
        _headView = [[CCWalletInfoHeadView alloc] init];
        _headView.delegate = self;
    }
    return _headView;
}


- (CCAssetFilterView *)filterView {
    if (!_filterView) {
        _filterView = [[CCAssetFilterView alloc] init];
    }
    return _filterView;
}

- (CCAssetDetailView *)assetDetailView {
    if (!_assetDetailView) {
        _assetDetailView = [[CCAssetDetailView alloc] init];
    }
    return _assetDetailView;
}

- (CCAccountTitleView *)titleView {
    if (!_titleView) {
        _titleView = [[CCAccountTitleView alloc] init];
    }
    return _titleView;
}

@end
