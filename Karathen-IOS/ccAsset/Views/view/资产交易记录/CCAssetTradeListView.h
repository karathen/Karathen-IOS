//
//  CCAssetTradeListView.h
//  ccAsset
//
//  Created by SealWallet on 2018/9/14.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCTableView.h"

@class CCAssetTradeListView,CCTradeRecordModel;
@protocol CCAssetTradeListViewDelegate <NSObject>

@optional
- (void)tradeListView:(CCAssetTradeListView *)listView tradeDetailModel:(CCTradeRecordModel *)tradeModel value:(NSString *)value;
- (void)tradeListViewDidScroll:(CCAssetTradeListView *)listView;

@end

@interface CCAssetTradeListView : CCTableView

@property (nonatomic, weak) id<CCAssetTradeListViewDelegate> listDelegate;

/**
 头部刷新文字颜色，不设置默认白色
 */
@property (nonatomic, strong) UIColor *headRefreshColor;

- (instancetype)initWithStyle:(UITableViewStyle)style
                        asset:(CCAsset *)asset
                   walletData:(CCWalletData *)walletData;

@end
