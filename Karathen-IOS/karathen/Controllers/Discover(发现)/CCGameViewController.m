//
//  CCGameViewController.m
//  Karathen
//
//  Created by Karathen on 2018/8/8.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCGameViewController.h"
#import "CCWebViewController.h"
#import "MLMDragView.h"

@interface CCGameViewController () <WKUIDelegate>

@property (nonatomic, strong) CCWebViewController *webVC;
@property (nonatomic, strong) MLMDragView *dragView;

@end

@implementation CCGameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBarHidden = YES;
    self.rt_disableInteractivePop = NO;
    
    [self createView];
    
    [self addObserver];
    
    [self updateDragViewOrientation];
}

#pragma mark - addObserver
- (void)addObserver {
    @weakify(self)
    [CCNotificationCenter receiveStatusBarOrientationDidChangeObserver:self completion:^{
        @strongify(self)
        [self updateDragViewOrientation];
    }];
}

- (void)updateDragViewOrientation {
    CGFloat btn_width = 40;
    CGFloat space = 30;
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    switch (interfaceOrientation) {
        case UIInterfaceOrientationUnknown:
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
        {
            self.dragView.min_Center_Point = CGPointMake(btn_width/2.0 + space, STATUS_BAR_HEIGHT + space);
            self.dragView.max_Center_Point = CGPointMake(SCREEN_WIDTH-btn_width/2.0 - space, SCREEN_HEIGHT-STATUS_BAR_HEIGHT - space);
            [self.dragView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.view.mas_top).offset(STATUS_BAR_HEIGHT + 10);
                make.left.equalTo(self.view.mas_left).offset(space);
            }];
        }
            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
        {
            self.dragView.min_Center_Point = CGPointMake(STATUS_BAR_HEIGHT + space, btn_width/2.0 + space);
            self.dragView.max_Center_Point = CGPointMake(SCREEN_WIDTH-STATUS_BAR_HEIGHT - space, SCREEN_HEIGHT-btn_width/2.0 - space);
            [self.dragView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.view.mas_top).offset(space);
                make.left.equalTo(self.view.mas_left).offset(STATUS_BAR_HEIGHT + 10);
            }];
        }
            break;
        default:
            break;
    }
    
    
}

#pragma mark - createView
- (void)createView {
    [self.view addSubview:self.webVC.view];
    [self addChildViewController:self.webVC];
    [self.webVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.view addSubview:self.dragView];
    [self dragBackView];
    
    @weakify(self)
    [self.dragView setTapAction:^{
        @strongify(self)
        [self.rt_navigationController popViewControllerAnimated:YES complete:nil];
    }];
}

#pragma mark -
- (void)dragBackView {
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [backBtn setTintColor:CC_MAIN_COLOR];
    [backBtn setImage:[UIImage imageNamed:@"cc_nav_back"] forState:UIControlStateNormal];
    [backBtn setBackgroundColor:CC_GRAY_BACKCOLOR];
    backBtn.userInteractionEnabled = NO;
    
    
    [self.dragView addSubview:backBtn];
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.dragView);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    backBtn.layer.cornerRadius = 20;
    backBtn.layer.masksToBounds = YES;
}


#pragma mark - get
- (CCWebViewController *)webVC {
    if (!_webVC) {
        _webVC = [[CCWebViewController alloc] init];
        _webVC.webUrl = self.gameUrl;
    }
    return _webVC;
}

- (MLMDragView *)dragView {
    if (!_dragView) {
        _dragView = [[MLMDragView alloc] init];
        _dragView.isHalf = NO;
    }
    return _dragView;
}



#pragma mark - 旋转屏幕
// 设备支持方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

// 默认方向
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

// 开启自动转屏
- (BOOL)shouldAutorotate {
    return YES;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
