//
//  MLMTextField.h
//  publicWelfare
//
//  Created by my on 16/9/13.
//  Copyright © 2016年 MS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MLMTextField : UITextField

@property (nonatomic, strong) UIColor *placeHolderColor;
@property (nonatomic, copy) void(^backText)(NSString *);

@end
