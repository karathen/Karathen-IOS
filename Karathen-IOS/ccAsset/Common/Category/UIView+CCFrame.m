//
//  UIView+CCFrame.m
//  ccAsset
//
//  Created by SealWallet on 2018/7/10.
//  Copyright © 2018年 SealWallet. All rights reserved.
//

#import "UIView+CCFrame.h"

@implementation UIView (CCFrame)

-(CGFloat)cc_x {
    return self.frame.origin.x;
}

-(void)setCc_x:(CGFloat)x {
    CGRect rect = self.frame;
    rect.origin.x = x;
    self.frame = rect;
}

-(CGFloat)cc_y {
    return self.frame.origin.y;
}

-(void)setCc_y:(CGFloat)y {
    CGRect rect = self.frame;
    rect.origin.y = y;
    self.frame = rect;
}

-(CGFloat)cc_width {
    return self.frame.size.width;
}

-(void)setCc_width:(CGFloat)width {
    CGRect rect = self.frame;
    rect.size.width = width;
    self.frame = rect;
}

-(CGFloat)cc_height {
    return self.frame.size.height;
}

-(void)setCc_height:(CGFloat)height {
    CGRect rect = self.frame;
    rect.size.height = height;
    self.frame = rect;
}

-(CGFloat)cc_centerX {
    return self.center.x;
}

-(void)setCc_centerX:(CGFloat)centerX {
    CGPoint center = self.center;
    center.x = centerX;
    self.center = center;
}

-(CGFloat)cc_centerY {
    return self.center.y;
}

-(void)setCc_centerY:(CGFloat)centerY {
    CGPoint center = self.center;
    center.y = centerY;
    self.center = center;
}

- (CGPoint)cc_origin {
    return self.frame.origin;
}

- (void)setCc_origin:(CGPoint)cc_origin {
    CGRect frame = self.frame;
    frame.origin = cc_origin;
    self.frame = frame;
}

- (CGSize)cc_size {
    return self.frame.size;
}

- (void)setCc_size:(CGSize)size {
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (CGFloat)cc_top {
    return self.frame.origin.y;
}

- (void)setCc_top:(CGFloat)t {
    self.frame = CGRectMake(self.cc_left, t, self.cc_width, self.cc_height);
}

- (CGFloat)cc_bottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setCc_bottom:(CGFloat)b {
    self.frame = CGRectMake(self.cc_left, b - self.cc_height, self.cc_width, self.cc_height);
}

- (CGFloat)cc_left {
    return self.frame.origin.x;
}

- (void)setCc_left:(CGFloat)l {
    self.frame = CGRectMake(l, self.cc_top, self.cc_width, self.cc_height);
}

- (CGFloat)cc_right {
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setCc_right:(CGFloat)r {
    self.frame = CGRectMake(r - self.cc_width, self.cc_top, self.cc_width, self.cc_height);
}


@end
