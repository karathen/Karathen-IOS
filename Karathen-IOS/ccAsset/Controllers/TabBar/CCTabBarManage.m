//
//  CCTabBarManage.m
//  ccAsset
//
//  Created by SealWallet on 2018/11/30.
//  Copyright © 2018 raistone. All rights reserved.
//

#import "CCTabBarManage.h"
#import "CCWallet_RootViewController.h"
#import "CCDiscover_RootViewController.h"
#import "CCMine_RootViewController.h"

@interface CCTabBarManage ()

@property (nonatomic, strong) NSMutableDictionary *tabBarModels;

@end

@implementation CCTabBarManage

- (void)languageChange {
    NSArray *types = [self currentItemsTypes];
    for (NSNumber *typeNum in types) {
        CCTabBarManageType type = typeNum.integerValue;
        UIViewController *vc = [self tabVCWithType:type];
        vc.tabBarItem.title = [self titleWithType:type];
    }
}

- (NSArray *)currentVCs {
    NSArray *types = [self currentItemsTypes];
    NSMutableArray *vcs = [NSMutableArray array];
    for (NSNumber *type in types) {
        [vcs addObject:[self tabVCWithType:type.integerValue]];
    }
    return vcs;
}

- (NSArray *)currentItemsTypes {
    NSMutableArray *items = [@[
                              @(CCTabBarManageWallet),
                              @(CCTabBarManageDApp),
                              @(CCTabBarManageProfile)
                              ] mutableCopy];
    CCAccountData *account = [CCDataManager dataManager].activeAccount;
    switch (account.account.walletType) {
        case CCWalletTypeHardware:
        {
            [items removeObject:@(CCTabBarManageDApp)];
        }
            break;
        case CCWalletTypePhone:
        {
            if ([account coinDataWithCoinType:CCCoinTypeETH]) {
                if (![account coinDataWithCoinType:CCCoinTypeNEO]) {
                }
            } else {
                [items removeObject:@(CCTabBarManageDApp)];
            }
        }
            break;
        default:
            break;
    }

    return items;
}

- (NSString *)keyWithType:(CCTabBarManageType)type {
    return [NSString stringWithFormat:@"tabbar-type-%@",@(type)];
}

- (NSString *)titleWithType:(CCTabBarManageType)type {
    NSDictionary *dic = [self itemsDicWithType:type];
    return dic[@"title"];
}

- (UIViewController *)tabVCWithType:(CCTabBarManageType)type {
    NSString *key = [self keyWithType:type];
    UIViewController *itemVC = [self.tabBarModels objectForKey:key];
    if (itemVC == nil) {
        NSDictionary *itemsDic = [self itemsDicWithType:type];
        UIViewController *childVC = [self childVCWithType:type];
        UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:itemsDic[@"title"] image:[UIImage imageNamed:itemsDic[@"image"]] selectedImage:[UIImage imageNamed:itemsDic[@"selectedImage"]]];
        CCNavigationController *nav = [[CCNavigationController alloc] initWithRootViewController:childVC];
        nav.navigationBarHidden = YES;
        childVC.tabBarItem = item;
        [self.tabBarModels setObject:nav forKey:key];
        itemVC = nav;
    }
    return itemVC;
}

- (UIViewController *)childVCWithType:(CCTabBarManageType)type {
    switch (type) {
        case CCTabBarManageWallet:
            return [[CCWallet_RootViewController alloc] init];
            break;
        case CCTabBarManageDApp:
            return [[CCDiscover_RootViewController alloc] init];
            break;
        case CCTabBarManageProfile:
            return [[CCMine_RootViewController alloc] init];
            break;
        default:
            break;
    }
    return nil;
}

- (NSDictionary *)itemsDicWithType:(CCTabBarManageType)type {
    switch (type) {
        case CCTabBarManageWallet:
        {
            return @{
                     @"title":Localized(@"Wallets"),
                     @"image":@"cc_tab_wallet_deSel",
                     @"selectedImage":@"cc_tab_wallet_sel"
                     };
        }
            break;
        case CCTabBarManageDApp:
        {
            return @{
                     @"title":Localized(@"Discover"),
                     @"image":@"cc_tab_discover_deSel",
                     @"selectedImage":@"cc_tab_discover_sel"
                     };
        }
            break;
        case CCTabBarManageProfile:
        {
            return @{
                     @"title":Localized(@"My Profile"),
                     @"image":@"cc_tab_mine_deSel",
                     @"selectedImage":@"cc_tab_mine_sel"
                     };
        }
            break;
        default:
            break;
    }
    return nil;
}

#pragma mark - get
- (NSMutableDictionary *)tabBarModels {
    if (!_tabBarModels) {
        _tabBarModels = [NSMutableDictionary dictionary];
    }
    return _tabBarModels;
}


@end
