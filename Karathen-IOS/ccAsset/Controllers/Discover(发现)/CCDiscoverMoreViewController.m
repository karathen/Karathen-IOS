//
//  CCDiscoverMoreViewController.m
//  ccAsset
//
//  Created by SealWallet on 2018/10/25.
//  Copyright © 2018 raistone. All rights reserved.
//

#import "CCDiscoverMoreViewController.h"
#import "CCWebViewController.h"
#import "CCDappViewController.h"

@interface CCDiscoverMoreViewController () <CCWebViewControllerDelegate>

@property (nonatomic, strong) CCWebViewController *webVC;

@end

@implementation CCDiscoverMoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = Localized(@"Discover");
    [self createView];
}

#pragma mark - createView
- (void)createView {
    [self.view addSubview:self.webVC.view];
    [self addChildViewController:self.webVC];
    [self.webVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
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
        _webVC.delegate = self;
        _webVC.webUrl = self.webUrl;
        _webVC.canHeadReload = YES;
    }
    return _webVC;
}

@end
