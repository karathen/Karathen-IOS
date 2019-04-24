//
//  MLMChooseImgCell.m
//  Live
//
//  Created by FTGJ on 2017/7/28.
//  Copyright © 2017年 Zego. All rights reserved.
//

#import "MLMChooseImgCell.h"

@implementation MLMChooseImgCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.imgView.layer.borderWidth = .5;
    self.imgView.layer.borderColor = RGB(0xe9e9e9).CGColor;
    self.imgView.layer.cornerRadius = FitScale(5);
    self.imgView.layer.masksToBounds = YES;
    // Initialization code
}

@end
