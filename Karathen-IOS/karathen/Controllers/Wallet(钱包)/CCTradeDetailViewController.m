//
//  CCTradeDetailViewController.m
//  Karathen
//
//  Created by Karathen on 2018/8/3.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCTradeDetailViewController.h"
#import "CCTradeRecordModel.h"
#import "CCTradeDetailTableViewCell.h"
#import "CCWalletInfoCell.h"
#import "AttributeMaker.h"
#import "CCWebViewController.h"
#import "CCTableView.h"
#import "CCErc721DetailView.h"
#import "CCErc721TokenInfoModel.h"
#import "CCGetTxRemarkRequest.h"

@interface CCTradeDetailViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) CCErc721DetailView *erc721View;
@property (nonatomic, strong) CCTableView *tableView;
@property (nonatomic, strong) NSArray *dataArray;//数据源
@property (nonatomic, strong) UILabel *valueLab;
@property (nonatomic, strong) CCGetTxRemarkRequest *remarkRequest;

@end

@implementation CCTradeDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = Localized(@"Transaction Details");

    [self dealData];
    [self createView];

    [self requestRemark];
}

- (void)requestRemark {
    if (!self.tradeModel.remark) {
        @weakify(self)
        [self.remarkRequest requestCompletion:^(NSString *remark) {
            @strongify(self)
            if (remark) {
                self.tradeModel.remark = remark;
                [self dealData];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
            }
        }];
    }
}

#pragma mark - 处理数据
- (void)dealData {
    _dataArray = @[
                   @{@"title":Localized(@"Address From"),@"content":self.tradeModel.addressFrom},
                   @{@"title":Localized(@"Address To"),@"content":self.tradeModel.addressTo},
  @{@"title":Localized(@"Remark"),@"content":self.tradeModel.remark.length?[self.tradeModel.remark stringByRemovingPercentEncoding]:Localized(@"None")},
                   @{@"title":Localized(@"TxHash"),@"content":self.tradeModel.txId?:@"",@"image":@"cc_asset_trade_icon",@"color":CC_MAIN_COLOR},
                   @{@"title":Localized(@"Transaction time"),@"content":self.tradeModel.blockTimeString},
                   ];
}

#pragma mark - super method
- (void)languageChange:(NSString *)language {
    self.title = Localized(@"Transaction Details");
    [self dealData];
    [self.tableView reloadData];
}

#pragma mark - createView
- (void)createView {
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    self.tableView.tableHeaderView = [self tableHeadView];
}

- (UIView *)tableHeadView {
    if ([self.asset.tokenType compareWithString:CCAseet_ETH_ERC721]) {
        self.erc721View.frame = CGRectMake(0, 0, SCREEN_WIDTH, FitScale(152));
        NSString *tokenId = self.value;
        [self.erc721View bindUrl:[CCErc721TokenInfoModel tokenIconWithAsset:self.asset tokenId:tokenId] withTokenId:tokenId];
        return self.erc721View;
    } else {
        UIView *view = [[UIView alloc] init];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(SCREEN_WIDTH);
        }];
        view.backgroundColor = [UIColor whiteColor];
        [view addSubview:self.valueLab];
        [self.valueLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.greaterThanOrEqualTo(view.mas_left).offset(FitScale(20));
            make.centerX.equalTo(view.mas_centerX);
            make.top.equalTo(view.mas_top).offset(FitScale(35));
            make.bottom.equalTo(view.mas_bottom).offset(-FitScale(13));
        }];
        
        self.valueLab.attributedText = [AttributeMaker attributeMaker:^(AttributeMaker *maker) {
            NSString *text = [NSString stringWithFormat:@"%@ %@",self.value,self.asset.tokenSynbol.lowercaseString];
            maker.text(text)
            .range(NSMakeRange(self.value.length+1, 3))
            .textFont(MediumFont(FitScale(7)));
        }];
        return view;
    }
}

#pragma mark - 复制
- (void)copyAction {
    UIPasteboard *pasterBoard = [UIPasteboard generalPasteboard];
    pasterBoard.string = self.tradeModel.txId?:@"";
    [MBProgressHUD showMessage:Localized(@"Copy Success")];
}

#pragma mark - tableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 3) {
        CCTradeDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CCTradeDetailTableViewCell"];
        @weakify(self)
        cell.copyTxid = ^{
            @strongify(self)
            [self copyAction];
        };
        [self bindCell:cell withIndexPath:indexPath];
        return cell;
    } else {
        CCWalletInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CCWalletInfoCell"];
        [self bindWalletInfoCell:cell withIndexPath:indexPath];
        return cell;
    }
}

- (void)bindCell:(CCTradeDetailTableViewCell *)cell withIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = _dataArray[indexPath.row];
    [cell bindCellWithTitle:dic[@"title"] content:dic[@"content"] image:dic[@"image"] color:dic[@"color"]];
}

- (void)bindWalletInfoCell:(CCWalletInfoCell *)cell withIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = _dataArray[indexPath.row];
    [cell bindCellTitle:dic[@"title"] withDetail:dic[@"content"]];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    @weakify(self)
    if (indexPath.row == 3) {
        return [tableView fd_heightForCellWithIdentifier:@"CCTradeDetailTableViewCell" configuration:^(CCTradeDetailTableViewCell *cell) {
            @strongify(self)
            [self bindCell:cell withIndexPath:indexPath];
        }];
    } else {
        return [tableView fd_heightForCellWithIdentifier:@"CCWalletInfoCell" configuration:^(CCWalletInfoCell *cell) {
            @strongify(self)
            [self bindWalletInfoCell:cell withIndexPath:indexPath];
        }];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 3) {
        CCWebViewController *webVC = [[CCWebViewController alloc] init];
        webVC.webUrl = [self.walletData tradeDetailUrlWithTxId:self.tradeModel.txId];
        webVC.title = self.title;
        [self.rt_navigationController pushViewController:webVC animated:YES complete:nil];
    }
}

#pragma mark - get
- (CCTableView *)tableView {
    if (!_tableView) {
        _tableView = [[CCTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClassCells:@[[CCTradeDetailTableViewCell class],[CCWalletInfoCell class]]];
    }
    return _tableView;
}

- (UILabel *)valueLab {
    if (!_valueLab) {
        _valueLab = [[UILabel alloc] init];
        _valueLab.textColor = CC_BLACK_COLOR;
        _valueLab.font = MediumFont(FitScale(18));
    }
    return _valueLab;
}

- (CCErc721DetailView *)erc721View {
    if (!_erc721View) {
        _erc721View = [[CCErc721DetailView alloc] init];
    }
    return _erc721View;
}

- (CCGetTxRemarkRequest *)remarkRequest {
    if (!_remarkRequest) {
        _remarkRequest = [[CCGetTxRemarkRequest alloc] init];
        _remarkRequest.txId = self.tradeModel.txId;
    }
    return _remarkRequest;
}

@end
