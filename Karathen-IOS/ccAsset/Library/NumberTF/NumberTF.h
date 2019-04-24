//
//  NumberTF.h
//  Yun
//
//  Created by my on 16/9/6.
//  Copyright © 2016年 lq. All rights reserved.
//

#import "MLMTextField.h"

@interface NumberTF : UITextField

//最大长度
@property (nonatomic, assign) NSInteger maxLength;

//小数点后
@property (nonatomic, assign) NSInteger afterPoint;
//最小数字
@property (nonatomic, assign) CGFloat minNum;
//最大数字
@property (nonatomic, assign) CGFloat maxNum;


//只能数字
@property (nonatomic, assign) BOOL onlyNum;
//有无小数点
@property (nonatomic, assign) BOOL hasPoint;

@property (nonatomic, strong) UIColor *placeHolderColor;
@property (nonatomic, copy) void(^backText)(NSString *text);

@property (nonatomic, copy) void(^showBegin)(void);
@property (nonatomic, copy) void(^showEnd)(void);

//拆分
@property (nonatomic, assign) BOOL isSpace;
@property (nonatomic, assign) NSInteger spaceNum;
@property (nonatomic, strong) NSString *spaceString;

@end
