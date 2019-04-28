//
//  CCAddAssetViewController.m
//  Karathen
//
//  Created by Karathen on 2018/7/26.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCAddAssetViewController.h"
#import "CCSearchView.h"
#import "CCSearchAssetView.h"

@interface CCAddAssetViewController () <CCSearchViewDelegate>

@property (nonatomic, strong) CCSearchView *searchView;
@property (nonatomic, strong) CCSearchAssetView *resultView;
@end

@implementation CCAddAssetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createView];
    [self languageChange:nil];
}


#pragma mark - super method
- (void)languageChange:(NSString *)language {
    self.title = Localized(@"Add Asset");
    self.searchView.placeholder = Localized(@"Token name or contract address");
    self.searchView.cancleTitle = Localized(@"Cancel");
}

#pragma mark - createView
- (void)createView {
    [self.view addSubview:self.searchView];
    [self.searchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(FitScale(8));
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.view.mas_top).offset(FitScale(14));
        make.height.mas_equalTo(FitScale(30));
    }];
    
    [self.view addSubview:self.resultView];
    [self.resultView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self.view);
        make.top.equalTo(self.searchView.mas_bottom).offset(FitScale(10));
    }];
}

#pragma mark - CCSearchViewDelegate
- (void)beginSearchView:(CCSearchView *)searchView {
    self.resultView.hidden = NO;
}

- (void)cancelSearchView:(CCSearchView *)searchView {
    self.resultView.hidden = YES;
}

- (void)searchActionSearchView:(CCSearchView *)searchView {
    [self.resultView searchAsset:searchView.text];
}

#pragma mark - get
- (CCSearchView *)searchView {
    if (!_searchView) {
        _searchView = [[CCSearchView alloc] init];
        _searchView.delegate = self;
    }
    return _searchView;
}

- (CCSearchAssetView *)resultView {
    if (!_resultView) {
        _resultView = [CCSearchAssetView searchViewWithWallet:self.wallet];
    }
    return _resultView;
}

@end
