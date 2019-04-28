//
//  KarathenHistoryHeaderView.h
//  Karathen
//
//  Created by Karathen on 2018/7/23.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CCAssetHistoryType) {
    CCAssetHistoryTypeAll,//全部
    CCAssetHistoryTypeTransfer,//转出
};

@class CCAssetHistoryHeaderView;
@protocol CCAssetHistoryHeaderViewDelegate <NSObject>

@optional
- (void)headView:(CCAssetHistoryHeaderView *)headView changeType:(CCAssetHistoryType)type;

@end

@interface CCAssetHistoryHeaderView : UITableViewHeaderFooterView

@property (nonatomic, assign) CCAssetHistoryType type;
@property (nonatomic, weak) id<CCAssetHistoryHeaderViewDelegate> delegate;
- (void)reloadHead;

@end
