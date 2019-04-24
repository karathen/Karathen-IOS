//
//  MLMTextField.m
//  publicWelfare
//
//  Created by my on 16/9/13.
//  Copyright © 2016年 MS. All rights reserved.
//

#import "MLMTextField.h"

@interface MLMTextField ()

@end

@implementation MLMTextField

- (void)awakeFromNib {
    [super awakeFromNib];
    [self addTarget:self action:@selector(change) forControlEvents:UIControlEventEditingChanged];
}


- (void)change {
    if (self.backText) {
        self.backText(self.text);
    }
}

- (void)setPlaceHolderColor:(UIColor *)placeHolderColor {
    _placeHolderColor = placeHolderColor;
    [self setNeedsDisplay];
}

- (void)drawPlaceholderInRect:(CGRect)rect

{
    _placeHolderColor = _placeHolderColor?_placeHolderColor:[UIColor lightGrayColor];
    NSMutableParagraphStyle *ps = [[NSMutableParagraphStyle alloc] init];
    [ps setAlignment:self.textAlignment];
    [self.placeholder drawInRect:CGRectMake(4, (rect.size.height - self.font.lineHeight)/2, rect.size.width-4, self.font.lineHeight) withAttributes:@{
                                                                                                                                                    NSForegroundColorAttributeName : [_placeHolderColor colorWithAlphaComponent:.7],
                                                                                                                                                    NSFontAttributeName : self.font,
                                                                                                                                                    NSParagraphStyleAttributeName:ps                                                    }];
    
}

@end
