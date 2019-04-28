//
//  CCViewController.h
//  Karathen
//
//  Created by Karathen on 2018/7/9.
//  Copyright © 2018年 Karathen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCViewController : UIViewController

//设置背景图
- (void)setBackImage:(UIImage *)image;

//设置title颜色和字体
- (void)setTitleColor:(UIColor *)color font:(UIFont *)font;

//切换语言调用
- (void)languageChange:(NSString *)language;

@end
