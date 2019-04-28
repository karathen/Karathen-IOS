//
//  CCGuideView.h
//  Karathen
//
//  Created by Karathen on 2018/9/11.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CCGuideViewDelegate <NSObject>

@optional
- (void)scrollToIndex:(NSInteger)index;
- (void)scrollScale:(CGFloat)scale;

@end


@interface CCGuideView : UIView

@property (nonatomic, assign) NSInteger page;
@property (nonatomic, weak) id<CCGuideViewDelegate> delegate;

- (instancetype)initWithIcons:(NSArray *)icons contents:(NSArray *)contents;

- (void)scrollToIndex:(NSInteger)index animation:(BOOL)animation;

@end


@interface CCGuideSingleView : UIView

- (instancetype)initWithContent:(NSString *)content image:(NSString *)image;

@end
