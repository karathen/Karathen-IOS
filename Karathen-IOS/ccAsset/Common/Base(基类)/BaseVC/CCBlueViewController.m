//
//  CCBlueViewController.m
//  ccAsset
//
//  Created by SealWallet on 2018/7/27.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCBlueViewController.h"
#import "UIImageTool.h"

@interface CCBlueViewController ()

@end

@implementation CCBlueViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initNav];
}


#pragma mark - initNAv
- (void)initNav {
    [self setBackImage:[UIImageTool createImageWithColor:CC_BTN_ENABLE_COLOR andSize:CGSizeMake(1, 1)]];
    [self setTitleColor:[UIColor whiteColor] font:BoldFont(FitScale(15))];
}

- (UIBarButtonItem *)rt_customBackItemWithTarget:(id)target action:(SEL)action {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.tintColor = [UIColor whiteColor];
    btn.bounds = CGRectMake(0, 0, FitScale(60), NAVIGATION_BAR_HEIGHT);
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    btn.imageEdgeInsets = UIEdgeInsetsMake(0, FitScale(10), 0, 0);
    [btn setImage:[UIImage imageNamed:@"cc_nav_back"] forState:UIControlStateNormal];
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:btn];
}

#pragma mark - 导航栏颜色
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
