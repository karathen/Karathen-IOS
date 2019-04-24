//
//  MLMOptionSelectView.m
//  MLMOptionSelectView
//
//  Created by my on 16/10/12.
//  Copyright © 2016年 MS. All rights reserved.
//

#import "MLMOptionSelectView.h"


static NSInteger maxOption = 5;//默认最大5行

static CGFloat arrow_H = 8;//箭头高
static CGFloat arrow_W = 15;//箭头宽

@interface MLMOptionSelectView () <UITableViewDelegate,UITableViewDataSource>
{
    ///向下或者向上展开超出屏幕时偏移的距离
    CGFloat _start_offSetY;
    CGFloat _start_offSetX;
    
    
    //箭头的三个顶点坐标
    CGPoint arrow1;
    CGPoint arrow2;
    CGPoint arrow3;
    
    CAShapeLayer *arrow_layer;
    //弹出动画点
    CGPoint point;
    //弹出之后的宽高
    CGFloat viewHeight;
    CGFloat viewWidth;
    //弹出之后的起点
    CGPoint startPoint;
    //箭头高
    CGFloat arrowHeight;
    //显示时的行数
    CGFloat end_Line;
    
    //是否有参照view
    UIView *_targetView;
    //targetRect
    CGRect _targetRect;
    //弹出点在对应方向上的比例
    CGFloat _target_scale;
    //是否翻转
    BOOL overturn;
    //锚点
    CGPoint anchorPoint;
}
///弹出朝向
@property (nonatomic, assign) MLMOptionSelectViewDirection diretionType;
///view
@property (nonatomic, strong) UIView *showView;
///背景层
@property (nonatomic, strong) UIView *cover;
///箭头顶点的位置和动画开始位置
@property (nonatomic, assign) CGFloat arrow_offset;//(0 - 1之间)
//
@property (nonatomic, assign) CGFloat space;

@end

@implementation MLMOptionSelectView

#pragma mark - 初始化
- (instancetype)initOptionView {
    if (self = [super initWithFrame:CGRectZero style:UITableViewStylePlain]) {
        self.delegate = self;
        self.dataSource = self;
        self.layer.cornerRadius = 5;
        self.layer.masksToBounds = YES;
        self.showsVerticalScrollIndicator = NO;
        self.bounces = NO;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self initSetting];
    }
    return self;
}

#pragma mark - 默认设置
- (void)initSetting {
    _maxLine = maxOption;
    _cornerRadius = 5;
    self.backColor = [UIColor whiteColor];
    _coverColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.4];
    _edgeInsets = UIEdgeInsetsZero;
}


- (void)setBackColor:(UIColor *)backColor {
    _backColor = backColor;
    self.backgroundColor = _backColor;
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    self.layer.cornerRadius = cornerRadius;
}

#pragma mark - 计算弹出位置
+ (CGRect)targetView:(UIView *)targetView {
    CGRect rect = [KEYWINDOW convertRect:targetView.frame fromView:targetView.superview];
    return rect;
}

#pragma mark - 显示多少行
- (CGFloat)showLine {
    NSInteger row = _rowNumber?_rowNumber():0;
    NSInteger line = MIN(row, _maxLine);
    return line;
}


#pragma mark - 弹出之前计算行数、高度等
- (void)beforeShowWidth:(CGFloat)width
        targetView:(UIView *)targetView {
    
    //显示行数
    end_Line = [self showLine];
    if (end_Line == 0) {
        return;
    }
    [self reloadData];
    _targetView = targetView;

    //箭头高度
    if (_optionType == MLMOptionSelectViewTypeArrow) {
        arrowHeight = arrow_H;
    } else {
        arrowHeight = 0;
    }
    
    CGFloat showHeight = 0;
    for (NSInteger i = 0; i < end_Line; i ++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        showHeight += _optionCellHeight(indexPath);
    }
    
    //宽高
    viewWidth = MIN(width,SCREEN_WIDTH - _edgeInsets.left - _edgeInsets.right);
    viewHeight = showHeight;


    //添加视图
    [KEYWINDOW addSubview:self.cover];
    [self.showView addSubview:self];
    [self addConstraintToCover];
}


#pragma mark - 弹出的方法
- (void)showTapPoint:(CGPoint)tapPoint
           viewWidth:(CGFloat)width
           direction:(MLMOptionSelectViewDirection)directionType {
    //优先弹出方向
    _diretionType = directionType;
    [self beforeShowWidth:width targetView:nil];
    point = tapPoint;
    //调节显示
    [self showByDiretionType];
    
    [self showAndDraw];
}

#pragma mark - 弹出的方法
- (void)showOffSetScale:(CGFloat)offset_Scale
                  space:(CGFloat)space
              viewWidth:(CGFloat)width
             targetView:(UIView *)targetView
              direction:(MLMOptionSelectViewDirection)directionType {
    self.space = space;
    //优先弹出方向
    _diretionType = directionType;
    [self beforeShowWidth:width targetView:targetView];
    _targetRect = [MLMOptionSelectView targetView:targetView];
    switch (_diretionType) {
        case MLMOptionSelectViewTop:
        case MLMOptionSelectViewBottom:
        {
            if (_cornerRadius < _targetRect.size.width) {
                CGFloat edgeScale = _cornerRadius/_targetRect.size.width;
                _target_scale = MIN(1 - edgeScale, MAX(edgeScale, offset_Scale));
            } else {
                _target_scale = offset_Scale;
            }
            point = CGPointMake(_targetRect.origin.x + _targetRect.size.width * _target_scale, _targetRect.origin.y + (directionType == MLMOptionSelectViewTop?(0-space):(_targetRect.size.height + space)));
        }
            break;
        case MLMOptionSelectViewLeft:
        case MLMOptionSelectViewRight:
        {
            if (_cornerRadius < _targetRect.size.height) {
                CGFloat edgeScale = _cornerRadius/_targetRect.size.height;
                _target_scale = MIN(1 - edgeScale, MAX(edgeScale, offset_Scale));
            } else {
                _target_scale = offset_Scale;
            }
            point = CGPointMake(_targetRect.origin.x + (directionType == MLMOptionSelectViewLeft?(0-space):(_targetRect.size.width + space)), _targetRect.origin.y + _targetRect.size.height * _target_scale);
        }
            break;
        default:
            break;
    }

    //调节显示
    [self showByDiretionType];
    
    [self showAndDraw];
}

#pragma mark - 弹出的方法
- (void)showViewCenter:(CGPoint)viewCenter
             viewWidth:(CGFloat)width {
    _optionType = MLMOptionSelectViewTypeCustom;
    [self beforeShowWidth:width targetView:nil];
    anchorPoint = CGPointMake(.5,.5);
    point = viewCenter;
    viewWidth = MIN(viewWidth, MIN(viewCenter.x - _edgeInsets.left, SCREEN_WIDTH - viewCenter.x - _edgeInsets.right)*2);
    viewHeight = MIN(viewHeight, MIN(viewCenter.y - _edgeInsets.top, SCREEN_HEIGHT - viewCenter.y - _edgeInsets.bottom)*2);
    [self showAndDraw];
}

#pragma mark - 改变弹出方向
- (void)showByDiretionType {
    _start_offSetY = (_targetView?_targetView.cc_height:0) + 2*self.space;
    _start_offSetX = _targetView?_targetView.cc_width:0;
    switch (_diretionType) {
        case MLMOptionSelectViewBottom:
        {
            if ((SCREEN_HEIGHT - point.y - arrowHeight - _edgeInsets.bottom) > viewHeight ||(point.y - _edgeInsets.top - _start_offSetY) < (SCREEN_HEIGHT - _edgeInsets.top - _edgeInsets.bottom - _start_offSetY)/2 ) {
                self.diretionType = MLMOptionSelectViewBottom;
            } else {
                point.y -= _start_offSetY;
                self.diretionType = MLMOptionSelectViewTop;
            }
        }
            break;
        case MLMOptionSelectViewTop:
        {
            if ((point.y - arrowHeight - _edgeInsets.top) > viewHeight || (point.y - _edgeInsets.top) > (SCREEN_HEIGHT - _edgeInsets.top - _edgeInsets.bottom - _start_offSetY)/2) {
                self.diretionType = MLMOptionSelectViewTop;
            } else {
                point.y += _start_offSetY;
                self.diretionType = MLMOptionSelectViewBottom;
            }
        }
            break;
        case MLMOptionSelectViewLeft:
        {
            if ((point.x- arrowHeight - _edgeInsets.left) >viewWidth || (point.x - _edgeInsets.left) > (SCREEN_WIDTH - _edgeInsets.left - _edgeInsets.right- _start_offSetX)/2) {//左
                self.diretionType = MLMOptionSelectViewLeft;
            } else {
                point.x += _start_offSetX;
                self.diretionType = MLMOptionSelectViewRight;
            }
        }
            break;
        case MLMOptionSelectViewRight:
        {
            if ((SCREEN_WIDTH-point.x-arrowHeight - _edgeInsets.right)>viewWidth || (point.x - _edgeInsets.left - _start_offSetX) < (SCREEN_WIDTH - _edgeInsets.left - _edgeInsets.right - _start_offSetX)/2 ) {
                self.diretionType = MLMOptionSelectViewRight;
            } else {
                point.x -= _start_offSetX;
                self.diretionType = MLMOptionSelectViewLeft;
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - 计算后的展示方向
- (void)setDiretionType:(MLMOptionSelectViewDirection)diretionType {
    _diretionType = diretionType;
    switch (diretionType) {
        case MLMOptionSelectViewBottom:
        case MLMOptionSelectViewTop:
        {
            if (point.x <= (viewWidth/2 + _edgeInsets.left)) {
                _arrow_offset = (point.x - _edgeInsets.left)/ viewWidth;
            } else if (point.x > (viewWidth/2 + _edgeInsets.left)&& point.x <= (SCREEN_WIDTH - viewWidth/2  - _edgeInsets.right)) {
                _arrow_offset = .5;
            } else {
                _arrow_offset = (1 - (SCREEN_WIDTH - point.x - _edgeInsets.right) / viewWidth);
            }
            CGFloat edgeScale = _cornerRadius/viewWidth;
            _arrow_offset = MIN(1 - edgeScale, MAX(edgeScale, _arrow_offset));
            if (_diretionType == MLMOptionSelectViewTop) {
                anchorPoint = CGPointMake(_arrow_offset, 1);
            } else {
                anchorPoint = CGPointMake(_arrow_offset,0);
            }
        }
            break;
        case MLMOptionSelectViewLeft:
        case MLMOptionSelectViewRight:
        {
            if (point.y <= (viewHeight/2 + _edgeInsets.top)) {
                _arrow_offset = (point.y - _edgeInsets.top)/ viewHeight;
            } else if (point.y > (viewHeight/2 + _edgeInsets.top)&& point.y <= (SCREEN_HEIGHT - viewHeight/2 - _edgeInsets.bottom)) {
                _arrow_offset = .5;
            } else {
                _arrow_offset = (1 - (SCREEN_HEIGHT - point.y - _edgeInsets.bottom) / viewHeight);
            }
            CGFloat edgeScale = _cornerRadius/viewWidth;
            _arrow_offset = MIN(1 - edgeScale, MAX(edgeScale, _arrow_offset));
            if (_diretionType == MLMOptionSelectViewLeft) {
                viewWidth = MIN(viewWidth, point.x - arrowHeight - _edgeInsets.left);
                anchorPoint = CGPointMake(1, _arrow_offset);
            } else {
                viewWidth = MIN(viewWidth, SCREEN_WIDTH - point.x-arrowHeight-_edgeInsets.right);
                anchorPoint = CGPointMake(0, _arrow_offset);
            }
        }
            break;
        default:
            break;
    }

}


#pragma mark - showAndDraw
- (void)showAndDraw {
    self.showView.layer.anchorPoint = anchorPoint;
    self.cc_size = CGSizeMake(viewWidth, viewHeight);
    //startPoint计算是以self为准，此处变换为backView
    CGRect showFrame;
    switch (_diretionType) {
        case MLMOptionSelectViewTop:
        case MLMOptionSelectViewBottom:
        {
            viewHeight = viewHeight + arrowHeight;
            self.cc_origin = CGPointMake(0, arrowHeight * (1 - anchorPoint.y));
        }
            break;
        case MLMOptionSelectViewLeft:
        case MLMOptionSelectViewRight:
        {
            viewWidth = viewWidth + arrowHeight;
            self.cc_origin = CGPointMake(arrowHeight * (1 - anchorPoint.x), 0);
        }
            break;
        default:
            break;
    }
    startPoint = CGPointMake(MIN(SCREEN_WIDTH - _edgeInsets.right - viewWidth, MAX(_edgeInsets.left, point.x - viewWidth * anchorPoint.x)), MIN(SCREEN_HEIGHT - _edgeInsets.bottom - viewHeight, MAX(_edgeInsets.top, point.y - viewHeight* anchorPoint.y)));
    showFrame = CGRectMake(startPoint.x, startPoint.y, viewWidth, viewHeight);
    self.showView.frame = showFrame;
    [KEYWINDOW addSubview:self.showView];

    if (_optionType == MLMOptionSelectViewTypeArrow) {
        [self drowArrow];
    } else {
        if (arrow_layer) {
            [arrow_layer removeFromSuperlayer];
            arrow_layer = nil;
        }
    }
    [self animation_show];
}



#pragma mark - showView
- (UIView *)showView {
    if (!_showView) {
        _showView = [[UIView alloc] init];
        _showView.backgroundColor = [UIColor clearColor];
    }
    return _showView;
}
#pragma mark - 画箭头
- (void)drowArrow {
    //根据锚点的位置画箭头
    arrow1 = CGPointMake(viewWidth * anchorPoint.x , viewHeight * anchorPoint.y);
    switch (_diretionType) {
        case MLMOptionSelectViewBottom:
        case MLMOptionSelectViewTop:
        {
            CGFloat bottomY = anchorPoint.y==0?(arrowHeight):(viewHeight - arrowHeight);
            arrow2 = CGPointMake(arrow1.x + (arrow_W/2 >= viewWidth*(1-anchorPoint.x)?0:arrow_W/2),bottomY);
            arrow3 = CGPointMake(arrow1.x - (arrow_W/2 >= viewWidth*anchorPoint.x?0:arrow_W/2), bottomY);
        }
            break;
        case MLMOptionSelectViewRight:
        case MLMOptionSelectViewLeft:
        {
            CGFloat bottomX = anchorPoint.x==0?(arrowHeight):(viewWidth - arrowHeight);
            arrow2 = CGPointMake(bottomX, arrow1.y + (arrow_W/2 >= viewHeight*(1-anchorPoint.y)?0:arrow_W/2));
            arrow3 = CGPointMake(bottomX, arrow1.y - (arrow_W/2 >= viewHeight*anchorPoint.y?0:arrow_W/2));
        }
            break;
        default:
            break;
    }
    if (!arrow_layer) {
        arrow_layer = [[CAShapeLayer alloc] init];
        arrow_layer.fillColor = _backColor.CGColor;
        [self.showView.layer addSublayer:arrow_layer];
    }
    UIBezierPath *arrowPath = [UIBezierPath bezierPath];
    [arrowPath moveToPoint:arrow1];
    [arrowPath addLineToPoint:arrow2];
    [arrowPath addLineToPoint:arrow3];
    [arrowPath closePath];
    arrow_layer.path = arrowPath.CGPath;
}


#pragma mark - 动画
- (void)animation_show {
    [self zoomOrOn];
    [UIView animateWithDuration:.3 animations:^{
        self.cover.alpha = 1;
        self.showView.transform = CGAffineTransformMakeScale(1, 1);
    }];
}

- (void)dismiss {
    [UIView animateWithDuration:.3 animations:^{
        [self zoomOrOn];
        self.cover.alpha = 0;
    } completion:^(BOOL finished) {
        self.showView.transform= CGAffineTransformIdentity;
        [self.showView removeFromSuperview];
        [self.cover removeFromSuperview];
    }];
}

#pragma mark - 是缩放或者展开
- (void)zoomOrOn {
    if (_vhShow) {
        if (_diretionType==MLMOptionSelectViewBottom || _diretionType==MLMOptionSelectViewTop) {
            self.showView.transform = CGAffineTransformMakeScale(1, 0.001);
        } else {
            self.showView.transform = CGAffineTransformMakeScale(0.001, 1);
        }
    } else {
        self.showView.transform = CGAffineTransformMakeScale(0.001, 0.001);
    }
}

#pragma mark - table
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _rowNumber?_rowNumber():0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_cell) {
        UITableViewCell *cell = _cell(indexPath);
        cell.contentView.backgroundColor = _backColor;
        cell.backgroundColor = _backColor;
        cell.selectionStyle = 0;
        return cell;
    } else {
        return nil;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return _optionCellHeight(indexPath);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.selectedOption) {
        self.selectedOption(indexPath);
    }
    if (!_multiSelect) {
        [self dismiss];
    }
}

#pragma mark - table_edit
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return _canEdit;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    @weakify(self)
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        @strongify(self)
        if (self.removeOption) {
            self.removeOption(indexPath);
        }
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self changgeFrameDeleteIndexPath:indexPath];
    }];
    deleteAction.backgroundColor = [UIColor redColor];
    return @[deleteAction];
}


#pragma mark - 删除之后改变frame
- (void)changgeFrameDeleteIndexPath:(NSIndexPath *)indexPath {
    if ([self showLine] == 0) {
        [self dismiss];
    }
    if (end_Line <= [self showLine]) {
        return;
    }
    CGFloat less = MIN(1, end_Line - [self showLine]) * _optionCellHeight(indexPath);
    viewHeight -= less;
    self.cc_height -= less;
    self.showView.cc_height = viewHeight;
    if (_optionType == MLMOptionSelectViewTypeArrow) {
        [self drowArrow];
    }
    CGFloat change = less * anchorPoint.y;
    [UIView animateWithDuration:.3 animations:^{
        self.showView.cc_y += change;
    }];
}

#pragma mark - cover
- (void)setCoverColor:(UIColor *)coverColor {
    _coverColor = coverColor;
    self.cover.backgroundColor = _coverColor;
}

- (void)addConstraintToCover {
    NSLayoutConstraint* leftConstraint = [NSLayoutConstraint constraintWithItem:_cover attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:KEYWINDOW attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0.0f];
    NSLayoutConstraint* rightConstraint = [NSLayoutConstraint constraintWithItem:_cover attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:KEYWINDOW attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:0.0f];
    NSLayoutConstraint* topConstraint = [NSLayoutConstraint constraintWithItem:_cover attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:KEYWINDOW attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.0f];
    NSLayoutConstraint* bottomConstraint = [NSLayoutConstraint constraintWithItem:_cover attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:KEYWINDOW attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0.0f];
    [KEYWINDOW addConstraints:@[leftConstraint, rightConstraint, topConstraint, bottomConstraint]];
}

- (UIView *)cover {
    if (!_cover) {
        _cover = [[UIView alloc] initWithFrame:KEYWINDOW.bounds];
        _cover.backgroundColor = _coverColor;
        _cover.alpha = 0;
        _cover.translatesAutoresizingMaskIntoConstraints = NO;
        @weakify(self)
        [_cover cc_tapHandle:^{
            @strongify(self)
            [self dismiss];
        }];
    }
    return _cover;
}

@end
