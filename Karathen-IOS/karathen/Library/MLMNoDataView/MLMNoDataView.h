//
//  MLMNoDataView.h
//  Yun
//
//  Created by my on 2017/3/31.
//  Copyright © 2017年 lq. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MLMNoDataView;

@interface MLMNoDataView : UIView


/**
 获取缺省试图

 @param superView 父试图
 @return 缺省试图
 */
+ (UIView *)noDataView:(UIView *)superView;


/**
 删除缺省试图

 @param superView 父试图
 */
+ (void)deleteNoDataView:(UIView *)superView;


/**
 自定义缺省试图

 @param customView 自定义view
 @param offsetX 竖直方向偏移
 @param offsetY 水平方向偏移
 @param superView 父试图
 @param hidden 是否隐藏
 @return 缺省试图
 */
+ (UIView *)noDataView:(UIView *)customView
               offsetX:(CGFloat)offsetX
               offsetY:(CGFloat)offsetY
                 addTo:(UIView *)superView
                 hiden:(BOOL)hidden;


/**
 默认文字图片

 @param msg 文字
 @param image 图片
 @param maxWidth 最大宽度
 @param offsetX 竖直方向偏移
 @param offsetY 水平方向偏移
 @param superView 父试图
 @param hidden 是否隐藏
 @return 缺省试图
 */
+ (MLMNoDataView *)noDataMsg:(NSString *)msg
                   withImage:(UIImage *)image
                    maxWidth:(CGFloat)maxWidth
                     offsetX:(CGFloat)offsetX
                     offsetY:(CGFloat)offsetY
                       addTo:(UIView *)superView
                       hiden:(BOOL)hidden;

////默认
+ (MLMNoDataView *)customAddToView:(UIView *)toView
                           offsetY:(CGFloat)offsetY
                            hidden:(BOOL)hidden;

@end
