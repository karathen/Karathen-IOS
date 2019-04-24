//
//  UIButton+Category.m
//  ccAsset
//
//  Created by SealWallet on 2018/9/6.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "UIButton+Category.h"

@implementation UIButton (Category)

- (void)titleLeftAndimageRightWithSpace:(CGFloat)space {
    [self setTitleEdgeInsets:UIEdgeInsetsMake(0, -self.imageView.cc_width-space/2.0, 0, self.imageView.cc_width)];
    [self setImageEdgeInsets:UIEdgeInsetsMake(0, self.titleLabel.cc_width, 0, -self.titleLabel.cc_width-space/2.0)];
}

@end
