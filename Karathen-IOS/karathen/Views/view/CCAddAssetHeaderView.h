//
//  CCAddAssetHeaderView.h
//  Karathen
//
//  Created by Karathen on 2018/7/19.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CCAddAssetHeaderView;
@protocol CCAddAssetHeaderViewDelegate <NSObject>

@optional
- (void)addAssetHeadView:(CCAddAssetHeaderView *)headView;
- (void)moreActionHeadView:(CCAddAssetHeaderView *)headView showView:(UIView *)showView;
- (void)searchActionHeadView:(CCAddAssetHeaderView *)headView keyWord:(NSString *)keyWord;

@end

@interface CCAddAssetHeaderView : UITableViewHeaderFooterView

@property (nonatomic, weak) id<CCAddAssetHeaderViewDelegate> delegate;
- (void)reloadHead;

@end
