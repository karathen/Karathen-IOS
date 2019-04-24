//
//  CCErc721ListViewController.m
//  ccAsset
//
//  Created by SealWallet on 2018/9/13.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCErc721ListViewController.h"
#import "CCReceiveViewController.h"
#import "CCErc721ListView.h"
#import "CCErc721HistoryViewController.h"
#import "CCTransferViewController.h"

@class CCErc721TokenInfoModel;

@interface CCErc721ListViewController () <CCErc721ListViewDelegate>

@property (nonatomic, strong) UIButton *codeBtn;
@property (nonatomic, strong) UIButton *historyBtn;
@property (nonatomic, strong) CCErc721ListView *listView;

@end

@implementation CCErc721ListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = [NSString stringWithFormat:@"%@ - %@",[CCDataManager coinKeyWithType:self.wallet.type],self.asset.tokenSynbol];

    [self createView];
    [self setRightItems];
}

#pragma mark - createView
- (void)createView {
    [self.view addSubview:self.listView];
    [self.listView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark - setRightIitems
- (void)setRightItems {
    UIButton *codeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [codeBtn setImage:[UIImage imageNamed:@"cc_721_qrcode_item"] forState:UIControlStateNormal];
    codeBtn.frame = CGRectMake(0, 0, 40, NAVIGATION_BAR_HEIGHT);
    [codeBtn setTitleColor:CC_BLACK_COLOR forState:UIControlStateNormal];
    [codeBtn addTarget:self action:@selector(codeAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *codeItem = [[UIBarButtonItem alloc] initWithCustomView:codeBtn];
    
    UIButton *historyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [historyBtn setImage:[UIImage imageNamed:@"cc_history_item"] forState:UIControlStateNormal];
    historyBtn.frame = CGRectMake(0, 0, 40, NAVIGATION_BAR_HEIGHT);
    historyBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    historyBtn.imageEdgeInsets = UIEdgeInsetsMake(0, FitScale(5), 0, 0);
    [historyBtn setTitleColor:CC_BLACK_COLOR forState:UIControlStateNormal];
    [historyBtn addTarget:self action:@selector(historyAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *historyItem = [[UIBarButtonItem alloc] initWithCustomView:historyBtn];
    
    self.navigationItem.rightBarButtonItems = @[historyItem,codeItem];
}

- (void)codeAction {
    CCReceiveViewController *receiveVC = [[CCReceiveViewController alloc] init];
    receiveVC.asset = self.asset;
    receiveVC.walletData = self.wallet;
    [self.rt_navigationController pushViewController:receiveVC animated:YES complete:nil];
}


- (void)historyAction {
    CCErc721HistoryViewController *historyVC = [[CCErc721HistoryViewController alloc] init];
    historyVC.asset = self.asset;
    historyVC.wallet = self.wallet;
    [self.rt_navigationController pushViewController:historyVC animated:YES complete:nil];
}

#pragma mark - CCErc721ListViewDelegate
- (void)listView:(CCErc721ListView *)listView didSelectedModel:(CCErc721TokenInfoModel *)model {
    CCTransferViewController *transferVC = [[CCTransferViewController alloc] init];
    transferVC.asset = self.asset;
    transferVC.walletData = self.wallet;
    transferVC.tokenModel = model;
    [self.rt_navigationController pushViewController:transferVC animated:YES complete:nil];
}

#pragma mark - get
- (CCErc721ListView *)listView {
    if (!_listView) {
        _listView = [[CCErc721ListView alloc] initWithAsset:self.asset walletData:self.wallet];
        _listView.listDelegate = self;
    }
    return _listView;
}

@end
