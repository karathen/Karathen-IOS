//
//  CCMine_RootViewController.m
//  Karathen
//
//  Created by Karathen on 2018/7/9.
//  Copyright © 2018年 Karathen. All rights reserved.
//

#import "CCMine_RootViewController.h"
#import "CCMineTableViewCell.h"
#import "CCMineDataManager.h"
#import "CCTableView.h"
#import "CCCoinManageViewController.h"
#import "CCLanguageViewController.h"
#import "CCCurrencyUnitViewController.h"
#import "CCResetPasswordViewController.h"
#import "CCBackUpMnemonicViewController.h"
#import "CCContentHintView.h"
#import "CCMineHeadView.h"

@interface CCMine_RootViewController () <UITableViewDelegate, UITableViewDataSource,CCContentHintViewDelegate>

@property (nonatomic, strong) CCTableView *tableView;
@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation CCMine_RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = Localized(@"My Profile");
    self.dataArray = [[CCMineDataManager dataArray] mutableCopy];

    [self createView];
    
}

#pragma mark - super method
- (void)languageChange:(NSString *)language {
    self.navigationItem.title = Localized(@"My Profile");
    self.dataArray = [[CCMineDataManager dataArray] mutableCopy];
    [self.tableView reloadData];
}

#pragma mark - createView
- (void)createView {
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}


#pragma mark - actionWithType
- (void)actionWithModel:(CCMineDataModel *)model {
    switch (model.type) {
        case CCMineDataTypeUnit:
        {
            [self pushUnitSet];
        }
            break;
        case CCMineDataTypeLanguage:
        {
            [self pushLanguageSet];
        }
            break;
        case CCMineDataTypeHelp:
        {
            [self suportCenter];
        }
            break;
        case CCMineDataTypeContactService:
        {
            [self contactService];
        }
            break;
        case CCMineDataTypeAboutUs:
        {
            [self aboutUs];
        }
            break;
        default:
            break;
    }
}


#pragma mark - 帮助中心
- (void)suportCenter {
}

#pragma mark - 技术支持
- (void)contactService {
    UIViewController *usVC = [[NSClassFromString(@"CCContactServiceViewController") alloc] init];
    [self.rt_navigationController pushViewController:usVC animated:YES complete:nil];
}

#pragma mark - 关于我们
- (void)aboutUs {
    UIViewController *usVC = [[NSClassFromString(@"CCAboutUsViewController") alloc] init];
    [self.rt_navigationController pushViewController:usVC animated:YES complete:nil];
}

#pragma mark - 语言设置
- (void)pushLanguageSet {
    CCLanguageViewController *languageVC = [[CCLanguageViewController alloc] init];
    [self.rt_navigationController pushViewController:languageVC animated:YES complete:nil];
}

#pragma mark - 货币单位
- (void)pushUnitSet {
    CCCurrencyUnitViewController *unitVC = [[CCCurrencyUnitViewController alloc] init];
    [self.rt_navigationController pushViewController:unitVC animated:YES complete:nil];
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
    CCMineDataModel *dataModel = self.dataArray[indexPath.row];
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
    CCMineDataModel *dataModel = self.dataArray[indexPath.row];
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


@end
