//
//  CCAboutUsViewController.m
//  ccAsset
//
//  Created by SealWallet on 2018/9/12.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCAboutUsViewController.h"
#import "CCAboutUsManager.h"
#import "CCTableView.h"
#import "CCMineTableViewCell.h"
#import "CCAboutUsHeadView.h"
#import "CCWebViewController.h"

@interface CCAboutUsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) CCTableView *tableView;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) CCAboutUsHeadView *headView;
@property (nonatomic, strong) UILabel *urlLab;

@end

@implementation CCAboutUsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = Localized(@"About");
    self.dataArray = [[CCAboutUsManager dataArray] mutableCopy];
    
    [self createView];

}

#pragma mark - createView
- (void)createView {
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.headView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(SCREEN_WIDTH);
    }];
    
    self.tableView.tableHeaderView = self.headView;
    self.tableView.tableFooterView = [self footView];
}

#pragma mark - footView
- (UIView *)footView {
    UIView *footView = [[UIView alloc] init];
    footView.frame = CGRectMake(0, 0, SCREEN_WIDTH, FitScale(130));
    
    [footView addSubview:self.urlLab];
    [self.urlLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(footView.mas_left).offset(FitScale(40));
        make.height.mas_equalTo(FitScale(40));
        make.center.equalTo(footView);
    }];
    
    @weakify(self)
    [self.urlLab cc_tapHandle:^{
        @strongify(self)
        [self urlActionWithUrl:self.urlLab.text];
    }];
    
    return footView;
}

#pragma mark - urlAction
- (void)urlActionWithUrl:(NSString *)url {
    CCWebViewController *webVC = [[CCWebViewController alloc] init];
    webVC.title = Localized(@"Seal Wallet");
    webVC.webUrl = url;
    [self.rt_navigationController pushViewController:webVC animated:YES complete:nil];
}

#pragma mark - action
- (void)actionWithModel:(CCAboutUsModel *)model {
    switch (model.type) {
        case CCAboutUsTypeService:
        {
            [self serviceAction];
        }
            break;
        case CCAboutUsTypePrivacy:
        {
            [self privacyAction];
        }
            break;
        case CCAboutUsTypeUpdate:
        {
            [self updateAction];
        }
            break;
        case CCAboutUsTypeContact:
        {
            [self contentUs];
        }
            break;
        default:
            break;
    }
}

#pragma mark - 服务协议
- (void)serviceAction {
}


#pragma mark - 隐私政策
- (void)privacyAction {
}

#pragma mark - 检查更新
- (void)updateAction {
    [self messageAlertMessage:Localized(@"No update available") sureTitle:Localized(@"OK") destructive:NO sureAction:nil];
}

#pragma mark - 联系我们
- (void)contentUs {
    NSString *gmail = SealWallet_EMail;
    [self messageAlertMessage:gmail sureTitle:Localized(@"Copy") destructive:NO sureAction:^{
        UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
        pasteBoard.string = gmail;
        [MBProgressHUD showMessage:Localized(@"Copy Success")];
    }];
}


#pragma mark - tableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CCMineTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CCMineTableViewCell"];
    [self bindCell:cell withIndexPath:indexPath];
    return cell;
}

- (void)bindCell:(CCMineTableViewCell *)cell withIndexPath:(NSIndexPath *)indexPath {
    CCAboutUsModel *dataModel = self.dataArray[indexPath.row];
    [cell bindCellWithTitle:dataModel.title icon:dataModel.icon];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    @weakify(self)
    return [tableView fd_heightForCellWithIdentifier:@"CCMineTableViewCell" configuration:^(CCMineTableViewCell *cell) {
        @strongify(self)
        [self bindCell:cell withIndexPath:indexPath];
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CCAboutUsModel *dataModel = self.dataArray[indexPath.row];
    [self actionWithModel:dataModel];
}

#pragma mark - get
- (CCTableView *)tableView {
    if (!_tableView) {
        _tableView = [[CCTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.bounces = NO;
        [_tableView registerClassCells:@[[CCMineTableViewCell class]]];
    }
    return _tableView;
}

- (CCAboutUsHeadView *)headView {
    if (!_headView) {
        _headView = [[CCAboutUsHeadView alloc] init];
    }
    return _headView;
}

- (UILabel *)urlLab {
    if (!_urlLab) {
        _urlLab = [[UILabel alloc] init];
        _urlLab.text = SealWallet_URL;
        _urlLab.textColor = CC_BTN_ENABLE_COLOR;
        _urlLab.textAlignment = NSTextAlignmentCenter;
        _urlLab.font = MediumFont(FitScale(12));
    }
    return _urlLab;
}

@end
