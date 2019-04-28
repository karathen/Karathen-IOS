//
//  KarathenDetailHeadView.h
//  Karathen
//
//  Created by Karathen on 2018/7/23.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CCAssetDetailHeadView;
@protocol CCAssetDetailHeadViewDelegate <NSObject>

@optional
- (void)transferHeadView:(CCAssetDetailHeadView *)headView;
- (void)receiveHeadView:(CCAssetDetailHeadView *)headView;

@end

@interface CCAssetDetailHeadView : UIView

@property (nonatomic, weak) id<CCAssetDetailHeadViewDelegate> delegate;

- (void)reloadHead;
- (void)reloadDataWithAsset:(CCAsset *)asset;
- (void)changeBackWithOffset:(CGPoint)offset;

@end
