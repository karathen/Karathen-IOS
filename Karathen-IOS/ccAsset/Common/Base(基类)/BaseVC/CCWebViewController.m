//
//  CCWebViewController.m
//  ccAsset
//
//  Created by SealWallet on 2018/8/6.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCWebViewController.h"

@interface CCWebViewController ()

@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) WebViewJavascriptBridge *jsBridge;

@end

@implementation CCWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(jsCallOCWebView:jsBridge:)]) {
            [self.delegate jsCallOCWebView:self.webView jsBridge:self.jsBridge];
        }
        if ([self.delegate respondsToSelector:@selector(ocCallJSWebView:jsBridge:)]) {
            [self.delegate ocCallJSWebView:self.webView jsBridge:self.jsBridge];
        }
    }
    
    [self createView];
    
    [self addObserver];
}

- (void)setCanHeadReload:(BOOL)canHeadReload {
    _canHeadReload = canHeadReload;
    @weakify(self)
    self.webView.scrollView.mj_header = [CCRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self)
        [self.webView reload];
        [self.webView.scrollView.mj_header endRefreshing];
    }];
}

#pragma mark - createView
- (void)createView {
    [self.view addSubview:self.webView];
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self loadWebUrl];
    
    
    [self.view addSubview:self.progressView];
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
        make.height.mas_equalTo(FitScale(2));
    }];
}

- (void)loadWebUrl {
    NSString *webUrl = [self.webUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:webUrl]]];
    self.progressView.progress = 0.2;
}


#pragma mark - addObserver
- (void)addObserver {
    [self.webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        [self.progressView setProgress:self.webView.estimatedProgress animated:YES];
        NSLog(@"%@",@(self.webView.estimatedProgress));
        if (self.progressView.progress == 1) {
            self.progressView.hidden =  YES;
            self.progressView.progress = 0.2;
        } else {
            self.progressView.hidden = NO;
        }
    } else if ([keyPath isEqualToString:@"title"]) {
        NSString *title = self.title;
        title = title.length>0 ? title: [_webView title];
        self.title = title;
    }
}

#pragma mark - webView
//页面加载完成之后调用
-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    self.progressView.hidden = YES;
    self.progressView.progress = 0.2;
}

//开始加载
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    self.progressView.hidden = NO;
}

//加载失败
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    self.progressView.hidden = YES;
    self.progressView.progress = 0.2;
}

// 在收到响应后，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    decisionHandler(WKNavigationResponsePolicyAllow);
}
// 在发送请求之前，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    decisionHandler(WKNavigationActionPolicyAllow);
}

#pragma mark - get
- (WKWebView *)webView {
    if (!_webView) {
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        configuration.userContentController = [[WKUserContentController alloc] init];
        
        WKPreferences *preferences = [WKPreferences new];
        preferences.javaScriptCanOpenWindowsAutomatically = YES;
        configuration.preferences = preferences;
        
        _webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
        _webView.allowsBackForwardNavigationGestures = NO;
    }
    return _webView;
}


- (void)dealloc {
    [_webView stopLoading];
    _webView.UIDelegate = nil;
    [_webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [_webView removeObserver:self forKeyPath:@"title"];
}

- (UIProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] init];
        _progressView.progressTintColor = CC_BTN_ENABLE_COLOR;
    }
    return _progressView;
}

- (WebViewJavascriptBridge *)jsBridge {
    if (!_jsBridge) {
        [WebViewJavascriptBridge enableLogging];
        _jsBridge = [WebViewJavascriptBridge bridgeForWebView:self.webView];
        [_jsBridge setWebViewDelegate:self];
    }
    return _jsBridge;
}

@end
