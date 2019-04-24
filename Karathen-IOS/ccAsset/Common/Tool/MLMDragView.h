//
//  MLMDragView.h
//  Live
//
//  Created by MAC on 2018/3/7.
//  Copyright © 2018年 Zego. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MLMDragView : UIView

/**
 点击事件
 */
@property (nonatomic, copy) void(^tapAction)(void);

/**
 拖拽结束
 */
@property (nonatomic, copy) void(^gestureEnd)(void);

/**
 是否吸入边界
 */
@property (nonatomic, assign) BOOL isHalf;

/**
 是否可以拖动
 */
@property (nonatomic, assign) BOOL canDrag;


//可以拖动的区域，左上角和右下角
/**
 左上角
 */
@property (nonatomic) CGPoint min_Center_Point;
/**
 右下角
 */
@property (nonatomic) CGPoint max_Center_Point;


/**
 是否在拖动中
 */
@property (nonatomic, readonly) BOOL isDrag;
/**
 停留在左边界还是右边界
 */
@property (nonatomic, readonly) BOOL isLeft;

@end
