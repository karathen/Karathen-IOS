//
//  AppDelegate+RootViewController.m
//  Karathen
//
//  Created by Karathen on 2018/7/10.
//  Copyright © 2018年 Karathen. All rights reserved.
//

#import "AppDelegate+RootViewController.h"

#import "CCTabBarController.h"
#import "CCHomeWalletViewController.h"

@implementation AppDelegate (RootViewController)

//window实例
- (void)setAppWindows {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
}

#pragma mark - 设置根试图
- (void)setRootViewController {
    //此处判断
    if ([CCDataManager dataManager].hadAccount) {
        [self setTabbarContoller];
    } else {
        [self setHomeWalletVC];
    }
}

#pragma mark - 创建/导入钱包页
- (void)setHomeWalletVC {
    CCHomeWalletViewController *walletVC = [[CCHomeWalletViewController alloc] init];

    CCNavigationController *homeNav = [[CCNavigationController alloc] initWithRootViewController:walletVC];
    [self restoreRootViewController:homeNav];
}

#pragma mark - tabbar
- (void)setTabbarContoller {
    CCTabBarController *tabVC = [[CCTabBarController alloc] init];
    [self restoreRootViewController:tabVC];
}

#pragma mark - 设置引导页
- (void)setLoadingVC {
    
}


#pragma mark - 渐变切换跟视图
-(void)restoreRootViewController:(UIViewController *)rootViewController
{
    typedef void (^Animation)(void);
    UIWindow* window = self.window;
    
    rootViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    Animation animation = ^{
        BOOL oldState = [UIView areAnimationsEnabled];
        [UIView setAnimationsEnabled:NO];
        window.rootViewController = rootViewController;
        [UIView setAnimationsEnabled:oldState];
    };
    
    [UIView transitionWithView:window
                      duration:0.5f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:animation
                    completion:nil];
    [self.window makeKeyAndVisible];
}

@end
