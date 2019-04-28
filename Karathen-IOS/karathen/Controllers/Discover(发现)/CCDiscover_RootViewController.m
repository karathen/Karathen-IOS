//
//  CCDiscover_RootViewController.m
//  Karathen
//
//  Created by Karathen on 2018/8/3.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCDiscover_RootViewController.h"
#import "CCWebViewController.h"
#import "CCDappViewController.h"
#import "CCDiscoverMoreViewController.h"

@interface CCDiscover_RootViewController () <CCWebViewControllerDelegate>

@property (nonatomic, strong) CCWebViewController *webVC;

@property (nonatomic, assign) BOOL needReload;


@end

@implementation CCDiscover_RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self languageChange:[[CCMultiLanguage manager] currentLanguage]];
    [self createView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.needReload) {
        [self.webVC loadWebUrl];
        self.needReload = NO;
    }
}
#pragma mark - super method
- (void)languageChange:(NSString *)language {
    self.navigationItem.title = Localized(@"Discover");
    self.needReload = YES;
    self.webVC.webUrl = [NSString stringWithFormat:@"%@/dapp/?lang=%@",CCAppBase_URL,language];
}

#pragma mark - createView
- (void)createView {
    self.navigationItem.rightBarButtonItem = [self editUrlItem];
    [self.view addSubview:self.webVC.view];
    [self addChildViewController:self.webVC];
    [self.webVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (UIBarButtonItem *)editUrlItem {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.bounds = CGRectMake(0, 0, FitScale(40), NAVIGATION_BAR_HEIGHT);
    [btn setImage:[UIImage imageNamed:@"cc_nav_edit"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(editUrlAction) forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:btn];
}

#pragma mark - action
- (void)editUrlAction {
    UIViewController *inputVC = [[NSClassFromString(@"CCInputUrlViewController") alloc] init];
    [self.rt_navigationController pushViewController:inputVC animated:YES complete:nil];
}

#pragma mark - CCWebViewControllerDelegate
- (void)jsCallOCWebView:(WKWebView *)webView jsBridge:(WebViewJavascriptBridge *)jsBridge {
    @weakify(self)
    [jsBridge registerHandler:@"getDAppName" handler:^(id data, WVJBResponseCallback responseCallback) {
        @strongify(self)
        [self gotoDappWithData:data];
        responseCallback(nil);
    }];
    
    [jsBridge registerHandler:@"getKindAll" handler:^(id data, WVJBResponseCallback responseCallback) {
        @strongify(self)
        [self moreActionWithData:data];
        responseCallback(nil);
    }];
}

#pragma mark - action
- (void)gotoDappWithData:(id)data {
    NSString *link = data[@"dappUrl"];
    if (link) {
        CCDappViewController *dappVC = [[CCDappViewController alloc] init];
        dappVC.url = [NSString getCompleteWebsite:link];
        [self.rt_navigationController pushViewController:dappVC animated:YES complete:nil];
    }
}

- (void)moreActionWithData:(id)data {
    NSString *url = data[@"url"];
    if (url) {
        CCDiscoverMoreViewController *moreVC = [[CCDiscoverMoreViewController alloc] init];
        moreVC.webUrl = [NSString getCompleteWebsite:url];
        [self.rt_navigationController pushViewController:moreVC animated:YES complete:nil];
    }
}


#pragma mark - get
- (CCWebViewController *)webVC {
    if (!_webVC) {
        _webVC = [[CCWebViewController alloc] init];
        _webVC.canHeadReload = YES;
        _webVC.delegate = self;
    }
    return _webVC;
}


@end
