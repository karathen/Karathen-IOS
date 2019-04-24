//
//  CCRefreshNormalHeader.m
//  ccAsset
//
//  Created by SealWallet on 2018/7/25.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCRefreshNormalHeader.h"

@implementation CCRefreshNormalHeader

- (void)prepare {
    [super prepare];
    
    self.lastUpdatedTimeLabel.hidden = YES;
    [self languageChange];
    
    @weakify(self)
    [CCMultiLanguage languageChanged:^(NSString *language) {
        @strongify(self)
        [self languageChange];
    }];
}

- (void)languageChange {
    // 初始化文字
    [self setTitle:Localized(@"MJRefreshHeaderIdleText") forState:MJRefreshStateIdle];
    [self setTitle:Localized(@"MJRefreshHeaderPullingText") forState:MJRefreshStatePulling];
    [self setTitle:Localized(@"MJRefreshHeaderRefreshingText") forState:MJRefreshStateRefreshing];
}

@end
