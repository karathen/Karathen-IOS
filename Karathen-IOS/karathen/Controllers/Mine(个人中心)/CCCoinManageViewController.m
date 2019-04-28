//
//  CCCoinManageViewController.m
//  Karathen
//
//  Created by Karathen on 2018/10/19.
//  Copyright © 2018 raistone. All rights reserved.
//

#import "CCCoinManageViewController.h"
#import "CCCoinManageView.h"

@interface CCCoinManageViewController () <CCCoinManageViewDelegate>

@property (nonatomic, strong) CCCoinManageView *coinView;

@end

@implementation CCCoinManageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = Localized(@"Multi-chain management");

    [self createView];
}

#pragma mark - createView
- (void)createView {
    [self.view addSubview:self.coinView];
    [self.coinView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark - CCCoinManageViewDelegate
- (void)confirmManageView:(CCCoinManageView *)manageView {
    [self.rt_navigationController popViewControllerAnimated:YES complete:nil];
}

#pragma mark - get
- (CCCoinManageView *)coinView {
    if (!_coinView) {
        _coinView = [[CCCoinManageView alloc] initWithAccount:self.account];
        _coinView.manageDelegate = self;
    }
    return _coinView;
}


@end
