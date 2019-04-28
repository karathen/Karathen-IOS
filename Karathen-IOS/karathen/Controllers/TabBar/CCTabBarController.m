//
//  CCTabBarController.m
//  Karathen
//
//  Created by Karathen on 2018/7/9.
//  Copyright © 2018年 Karathen. All rights reserved.
//

#import "CCTabBarController.h"
#import "UIImageTool.h"
#import "CCTabBarManage.h"

@interface CCTabBarController ()

@property (nonatomic, strong) CCTabBarManage *tabbarManage;

@end

@implementation CCTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self addNotify];
    //创建子控制器
    [self buildMainTabBarChildViewController];
    
    //设置tabar
    [self tabbarSet];
    
    @weakify(self)
    [CCMultiLanguage languageChanged:^(NSString *language) {
        @strongify(self)
        [self.tabbarManage languageChange];
    }];
}

#pragma mark - addNotify
- (void)addNotify {
    @weakify(self)
    [CCNotificationCenter receiveActiveAccountChangeObserver:self completion:^{
        @strongify(self)
        dispatch_async(dispatch_get_main_queue(), ^{
            [self buildMainTabBarChildViewController];
        });
    }];
    
}

#pragma mark - 创建子控制器
- (void)buildMainTabBarChildViewController {
    self.viewControllers = [self.tabbarManage currentVCs];
}

#pragma mark - tabbar设置
- (void)tabbarSet {
    [self.tabBar setBackgroundImage:[UIImageTool createImageWithColor:RGB(0xF6F7F8) andSize:CGSizeMake(1, 1)]];
    self.tabBar.tintColor = CC_MAIN_COLOR;
    self.tabBar.backgroundColor = [UIColor clearColor];
    self.tabBar.translucent = NO;
    
    //设置未选中字体颜色
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:CC_GRAY_TEXTCOLOR, NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    //设置选中字体颜色
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:CC_MAIN_COLOR, NSForegroundColorAttributeName, nil] forState:UIControlStateSelected];
}

#pragma mark - get
- (CCTabBarManage *)tabbarManage {
    if (!_tabbarManage) {
        _tabbarManage = [[CCTabBarManage alloc] init];
    }
    return _tabbarManage;
}

- (BOOL)shouldAutorotate {
    return [self.selectedViewController shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [self.selectedViewController supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return [self.selectedViewController preferredInterfaceOrientationForPresentation];
}
@end
