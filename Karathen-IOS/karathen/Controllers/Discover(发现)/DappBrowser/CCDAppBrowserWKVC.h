//
//  CCDAppBrowserWKVC.h
//  Karathen
//
//  Created by Karathen on 2018/9/26.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCViewController.h"
#import "WebViewJavascriptBridge.h"

@interface CCDAppBrowserWKVC : CCViewController

@property (nonatomic, strong) NSString *webUrl;

@property (nonatomic, strong, readonly) WKWebView *webView;
@property (nonatomic, weak) CCWalletData *walletData;
@property (nonatomic, strong, readonly) WebViewJavascriptBridge *jsBridge;

- (void)changeWalletData:(CCWalletData *)walletData;

- (void)reloadWeb;

@end
