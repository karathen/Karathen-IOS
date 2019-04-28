//
//  MLMNoDataView.m
//  Yun
//
//  Created by my on 2017/3/31.
//  Copyright © 2017年 lq. All rights reserved.
//

#import "MLMNoDataView.h"
#import "UIImage+GIF.h"

static char nodataview;

@implementation MLMNoDataView

#pragma mark - 获取缺省试图
+ (UIView *)noDataView:(UIView *)superView {
    return objc_getAssociatedObject(superView, &nodataview);
}

#pragma mark - 删除缺省试图
+ (void)deleteNoDataView:(UIView *)superView {
    UIView *view = [MLMNoDataView noDataView:superView];
    view.hidden = YES;
    [view removeFromSuperview];
    objc_setAssociatedObject(superView, &nodataview, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    view = nil;
}

#pragma mark - 自定义缺省试图
+ (UIView *)noDataView:(UIView *)customView
               offsetX:(CGFloat)offsetX
               offsetY:(CGFloat)offsetY
                 addTo:(UIView *)superView
                 hiden:(BOOL)hidden {
    UIView *view = objc_getAssociatedObject(superView, &nodataview);
    if (!view) {
        [superView insertSubview:customView atIndex:0];
        
        [customView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(superView.mas_centerX).offset(offsetX);
            make.centerY.equalTo(superView.mas_centerY).offset(offsetY);
        }];
        
        objc_setAssociatedObject(superView, &nodataview, customView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    view.hidden = hidden;
    return view;
}

#pragma mark - 默认文字图片
+ (MLMNoDataView *)noDataMsg:(NSString *)msg
                   withImage:(UIImage *)image
                    maxWidth:(CGFloat)maxWidth
                     offsetX:(CGFloat)offsetX
                     offsetY:(CGFloat)offsetY
                       addTo:(UIView *)superView
                       hiden:(BOOL)hidden {
    MLMNoDataView *msgV = objc_getAssociatedObject(superView, &nodataview);
    if (![msgV isKindOfClass:[MLMNoDataView class]] && msgV) {
        [MLMNoDataView deleteNoDataView:superView];
        msgV = nil;
    }
    if (!msgV) {
        msgV = [MLMNoDataView new];
        
        UIImageView *imageV = [UIImageView new];
        [imageV setImage:image];
        [msgV addSubview:imageV];
        
        [imageV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(msgV.mas_top);
            make.centerX.equalTo(msgV.mas_centerX);
            if (maxWidth != 0) {
                make.width.mas_equalTo(maxWidth);
            }
            make.left.equalTo(msgV.mas_left);
        }];
        
        //处理label
        UILabel *msgLab = [UILabel new];
        msgLab.text = msg;
        msgLab.textColor = [UIColor grayColor];
        msgLab.textAlignment = NSTextAlignmentCenter;
        msgLab.font = [UIFont systemFontOfSize:FitScale(14)];
        msgLab.numberOfLines = 0;
        [msgV addSubview:msgLab];

        [msgLab mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(imageV.mas_bottom).offset(FitScale(5));
            make.centerX.equalTo(imageV.mas_centerX);
            make.left.greaterThanOrEqualTo(msgV.mas_left).offset(FitScale(5));
            make.bottom.equalTo(msgV.mas_bottom).offset(FitScale(-5));
        }];

        [superView insertSubview:msgV atIndex:0];
        
        [msgV mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(superView.mas_centerX).offset(offsetX);
            make.centerY.equalTo(superView.mas_centerY).offset(offsetY);
        }];
        
        objc_setAssociatedObject(superView, &nodataview, msgV, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    msgV.hidden = hidden;
    
    return msgV;
}

#pragma mark - 默认
+ (MLMNoDataView *)customAddToView:(UIView *)toView
                           offsetY:(CGFloat)offsetY
                            hidden:(BOOL)hidden {
    return [MLMNoDataView noDataMsg:Localized(@"Data Empty")
                          withImage:[UIImage imageNamed:@"cc_notData_back"]
                           maxWidth:0
                            offsetX:0
                            offsetY:offsetY
                              addTo:toView
                              hiden:hidden];
}

@end
