//
//  CCRefreshAutoNormalFooter.m
//  ccAsset
//
//  Created by SealWallet on 2018/7/26.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCRefreshAutoNormalFooter.h"

@implementation CCRefreshAutoNormalFooter

- (void)prepare {
    [super prepare];
    
    self.onlyRefreshPerDrag = YES;
    self.triggerAutomaticallyRefreshPercent = -1;
    
    [self languageChange];
    
    @weakify(self)
    [CCMultiLanguage languageChanged:^(NSString *language) {
        @strongify(self)
        [self languageChange];
    }];
}
- (void)placeSubviews {
    self.refreshingTitleHidden = YES;
    [super placeSubviews];
}

- (void)languageChange {
    // 初始化文字
    [self setTitle:Localized(@"MJRefreshAutoFooterNoMoreDataText") forState:MJRefreshStateNoMoreData];
    [self setTitle:Localized(@"MJRefreshAutoFooterIdleText") forState:MJRefreshStateIdle];
}


@end
