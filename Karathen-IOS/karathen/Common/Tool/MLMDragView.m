//
//  MLMDragView.m
//  Live
//
//  Created by MAC on 2018/3/7.
//  Copyright © 2018年 Zego. All rights reserved.
//

#import "MLMDragView.h"

@interface MLMDragView ()
{
    CGPoint _start_Center;
    UITapGestureRecognizer *_tapGes;
    UIPanGestureRecognizer *_panGes;
}
@end

@implementation MLMDragView

- (instancetype)init {
    if (self = [super init]) {
        self.userInteractionEnabled = YES;
        self.canDrag = YES;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = YES;
        self.canDrag = YES;
    }
    return self;
}

#pragma mark - addPan
- (void)addGesture {
    if (!_tapGes) {
        _tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    }
    [self addGestureRecognizer:_tapGes];
    
    if (!_panGes) {
        _panGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveMap:)];
    }
    [self addGestureRecognizer:_panGes];
    
    [_tapGes requireGestureRecognizerToFail:_panGes];
}

- (void)setCanDrag:(BOOL)canDrag {
    if (canDrag != _canDrag) {
        if (canDrag) {
            [self addGesture];
        } else {
            [self removeGestureRecognizer:_panGes];
        }
    }
    _canDrag = canDrag;
}


#pragma mark - 单击
- (void)tapAction:(UITapGestureRecognizer *)tap {
    if (self.tapAction) {
        self.tapAction();
    }
}

- (void)moveMap:(UIPanGestureRecognizer *)pan {
    CGPoint translation = [pan translationInView:self];
    //
    CGFloat x_trans = translation.x;
    CGFloat y_trans = translation.y;
    
    if (pan.state == UIGestureRecognizerStateBegan) {
        _isDrag = YES;
        _start_Center = self.center;
    } else if (pan.state == UIGestureRecognizerStateChanged) {
        CGFloat change_x = _start_Center.x + x_trans;
        CGFloat change_y = _start_Center.y + y_trans;
        self.center = CGPointMake(change_x, change_y);
    } else if (pan.state == UIGestureRecognizerStateEnded){
        CGFloat result_x = MAX(self.min_Center_Point.x, MIN(self.center.x, self.max_Center_Point.x));
        CGFloat result_y = MAX(self.min_Center_Point.y, MIN(self.center.y, self.max_Center_Point.y));
        
        //靠左 还是靠右
        _isLeft = (result_x-self.max_Center_Point.x) < (self.min_Center_Point.x-result_x);
        
        if (_isLeft) {//靠左
            if (_isHalf) {
                result_x = self.min_Center_Point.x-self.frame.size.width/2.0;
            } else {
                result_x = self.min_Center_Point.x;
            }
        } else {
            if (_isHalf) {
                result_x = self.max_Center_Point.x+self.frame.size.width/2.0;
            } else {
                result_x = self.max_Center_Point.x;
            }
        }
        
        [UIView animateWithDuration:.3 animations:^{
            self.center = CGPointMake(result_x, result_y);
        } completion:^(BOOL finished) {
            if (self.gestureEnd) {
                self.gestureEnd();
            }
        }];
        
        _isDrag = NO;
    }
}

@end
