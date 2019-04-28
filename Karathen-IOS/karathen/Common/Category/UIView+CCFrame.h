//
//  UIView+CCFrame.h
//  Karathen
//
//  Created by Karathen on 2018/7/10.
//  Copyright © 2018年 Karathen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (CCFrame)

@property (nonatomic, assign) CGFloat cc_x;
@property (nonatomic, assign) CGFloat cc_y;
@property (nonatomic, assign) CGFloat cc_width;
@property (nonatomic, assign) CGFloat cc_height;
@property (nonatomic, assign) CGFloat cc_centerX;
@property (nonatomic, assign) CGFloat cc_centerY;
@property (nonatomic, assign) CGPoint cc_origin;
@property (nonatomic, assign) CGSize cc_size;
@property (nonatomic, assign) CGFloat cc_top;
@property (nonatomic, assign) CGFloat cc_bottom;
@property (nonatomic, assign) CGFloat cc_left;
@property (nonatomic, assign) CGFloat cc_right;

@end
