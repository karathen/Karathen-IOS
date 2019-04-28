//
//  CCWebViewController.h
//  Karathen
//
//  Created by Karathen on 2018/8/6.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCViewController.h"
#import "WebViewJavascriptBridge.h"

@protocol CCWebViewControllerDelegate <NSObject>

@optional
- (void)jsCallOCWebView:(WKWebView *)webView jsBridge:(WebViewJavascriptBridge *)jsBridge;
- (void)ocCallJSWebView:(WKWebView *)webView jsBridge:(WebViewJavascriptBridge *)jsBridge;

@end


@interface CCWebViewController : CCViewController

@property (nonatomic, weak) id<CCWebViewControllerDelegate> delegate;

@property (nonatomic, strong) WKWebView *webView;

@property (nonatomic, strong) NSString *webUrl;

@property (nonatomic, assign) BOOL canHeadReload;

- (void)loadWebUrl;


@end
