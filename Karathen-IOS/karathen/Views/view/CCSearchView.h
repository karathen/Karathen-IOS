//
//  CCSearchView.h
//  Karathen
//
//  Created by Karathen on 2018/7/26.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CCSearchView;
@protocol CCSearchViewDelegate <NSObject>

@optional
//开始
- (void)beginSearchView:(CCSearchView *)searchView;
//取消
- (void)cancelSearchView:(CCSearchView *)searchView;
//搜索
- (void)searchActionSearchView:(CCSearchView *)searchView;

@end

@interface CCSearchView : UIView

@property (nonatomic, weak) id<CCSearchViewDelegate> delegate;

@property (nonatomic, strong) NSString *placeholder;
@property (nonatomic, strong) NSString *cancleTitle;

- (NSString *)text;
@end
