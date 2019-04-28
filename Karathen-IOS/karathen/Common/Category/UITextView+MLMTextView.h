//
//  UITextView+MLMTextView.h
//  Live
//
//  Created by MAC on 2018/5/18.
//  Copyright © 2018年 Zego. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextView (MLMTextView)

//占位符
@property (nonatomic, strong) NSString *mlm_placeholder;
//占位符颜色
@property (nonatomic, strong) UIColor *mlm_placeholderColor;
///字数限制
@property (nonatomic, strong) NSNumber *mlm_limitLength;
///字数个数变化
@property (nonatomic, copy) void(^textLengthChange)(NSInteger length);
///文字变化
@property (nonatomic, copy) void(^textDidChange)(NSString *text);
//达到最大限制提醒
@property (nonatomic, copy) void(^greaterThanLimit)(void);
//最大高度
@property (nonatomic, strong) NSNumber *mlm_maxHeight;
//高度变化
@property (nonatomic, copy) void(^textViewHeightChange)(CGFloat currentHeight);


//设置属性后调用
- (void)refreshPlaceholderView;

- (CGFloat)minHeightWithWidth:(CGFloat)width;

- (UITextView *)mlm_placeholderView;

@end
