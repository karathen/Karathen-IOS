//
//  CCCurrencyUnitViewController.m
//  Karathen
//
//  Created by Karathen on 2018/8/16.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCCurrencyUnitViewController.h"
#import "CCLanguageSetCell.h"
#import "CCTableView.h"

@interface CCCurrencyUnitViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) CCTableView *tableView;

@end

@implementation CCCurrencyUnitViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = Localized(@"Currency Unit");
    [self createView];
    
    [self addObserver];
}

#pragma mark - addObserver
- (void)addObserver {
    @weakify(self)
    [CCNotificationCenter receiveCurrencyUnitChangeObserver:self completion:^(NSString *currentUnit) {
        @strongify(self)
        [self.tableView reloadData];
    }];
}

#pragma mark - super method
- (void)languageChange:(NSString *)language {
    [self languageSet];
}

#pragma mark - 语言
- (void)languageSet {
    self.title = Localized(@"language");
    [self.tableView reloadData];
}

#pragma mark - createView
- (void)createView {
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark - get
- (CCTableView *)tableView {
    if (!_tableView) {
        _tableView = [[CCTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.bounces = NO;
        [_tableView registerClassCells:@[[CCLanguageSetCell class]]];
    }
    return _tableView;
}

#pragma mark - tableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [CCCurrencyUnit allCurrencyUnit].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CCLanguageSetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CCLanguageSetCell"];
    [self bindCell:cell withIndexPath:indexPath];
    return cell;
}

- (void)bindCell:(CCLanguageSetCell *)cell withIndexPath:(NSIndexPath *)indexPath {
    NSString *unit = [CCCurrencyUnit allCurrencyUnit][indexPath.row];
    [cell bindCellWithUnit:unit];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    @weakify(self)
    return [tableView fd_heightForCellWithIdentifier:@"CCLanguageSetCell" configuration:^(CCLanguageSetCell *cell) {
        @strongify(self)
        [self bindCell:cell withIndexPath:indexPath];
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *unit = [CCCurrencyUnit allCurrencyUnit][indexPath.row];
    [CCCurrencyUnit changeCurrencyUnit:unit];
}

@end
