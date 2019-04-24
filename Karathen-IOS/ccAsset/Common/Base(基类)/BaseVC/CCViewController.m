//
//  CCViewController.m
//  ccAsset
//
//  Created by SealWallet on 2018/7/9.
//  Copyright © 2018年 SealWallet. All rights reserved.
//

#import "CCViewController.h"

@interface CCViewController ()

@end

@implementation CCViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];

    [self customNavBarSet];
    
    @weakify(self)
    [CCMultiLanguage languageChanged:^(NSString *language) {
        @strongify(self)
        [self languageChange:language];
    }];
}


#pragma mark - 导航栏设置
- (void)customNavBarSet {
    self.navigationController.navigationBar.translucent = NO;
    [self setBackImage:[UIImage imageNamed:@"cc_tabbar_backImg"]];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    
    [self setTitleColor:CC_BLACK_COLOR font:BoldFont(16)];
}


- (void)setBackImage:(UIImage *)image {
    [self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
}

- (void)setTitleColor:(UIColor *)color font:(UIFont *)font {
    [self.navigationController.navigationBar setTitleTextAttributes:@{
                                                                      NSForegroundColorAttributeName:color,
                                                                      NSFontAttributeName:font
                                                                      }];
}

- (UIBarButtonItem *)rt_customBackItemWithTarget:(id)target action:(SEL)action {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.bounds = CGRectMake(0, 0, FitScale(60), NAVIGATION_BAR_HEIGHT);
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    btn.imageEdgeInsets = UIEdgeInsetsMake(0, FitScale(10), 0, 0);
    [btn setImage:[UIImage imageNamed:@"cc_nav_back"] forState:UIControlStateNormal];
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:btn];
}

- (void)languageChange:(NSString *)language {
    
}

- (void)dealloc {
    DLog(@"dealloc --- %@",self.description);
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}


// 设备支持方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

// 默认方向
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

// 开启自动转屏
- (BOOL)shouldAutorotate {
    return NO;
}

@end
