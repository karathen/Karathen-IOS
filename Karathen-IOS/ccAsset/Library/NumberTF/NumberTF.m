//
//  NumberTF.m
//  Yun
//
//  Created by my on 16/9/6.
//  Copyright © 2016年 lq. All rights reserved.
//

#import "NumberTF.h"

@interface NumberTF () <UITextFieldDelegate>

@end

@implementation NumberTF

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initSet];
        [self addTarget];
    }
    return self;
}


- (instancetype)init {
    if (self = [super init]) {
        [self addTarget];
    }
    return self;
}


- (void)awakeFromNib {
    [super awakeFromNib];
    [self initSet];
    [self addTarget];
}


- (void)initSet {
    //默认设置
    _onlyNum = YES;
    _hasPoint = YES;
    _maxLength = NSIntegerMax;
    _maxNum = MAXFLOAT;
    _spaceString = @" ";
    _afterPoint = 2;
}

- (void)addTarget {
    self.delegate = self;
    [self addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    
    NSString * selectorName = NSStringFromSelector(aSelector);
    
    if ([selectorName isEqualToString:@"attributesForBaiduMobStat"]) {
        return NO;
    }
    return [super respondsToSelector:aSelector];
}


- (void)textFieldDidChange {
    if (!self.onlyNum) {        
        NSString *toBeString = self.text;
        
        NSString *lang = [[UIApplication sharedApplication]textInputMode].primaryLanguage; //ios7之前使用[UITextInputMode currentInputMode].primaryLanguage
        
        if ([lang isEqualToString:@"zh-Hans"]) { //中文输入
            
            UITextRange *selectedRange = [self markedTextRange];
            
            //获取高亮部分
            UITextPosition *position = [self positionFromPosition:selectedRange.start offset:0];
            
            if (!position) {// 没有高亮选择的字，则对已输入的文字进行字数统计和限制
                
                if (toBeString.length > self.maxLength) {
                    self.text = [toBeString substringToIndex:self.maxLength];
                }
                
            }
            else{//有高亮选择的字符串，则暂不对文字进行统计和限制
                
            }
            
        }else{//中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
            if (toBeString.length > self.maxLength) {
                self.text = [toBeString substringToIndex:self.maxLength];
            }
        }
    }

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

#pragma mark - textDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField {
    //有几个分割
    NSInteger num_space = 0;
    if (_isSpace && _spaceNum>0) {
        if (textField.text.length>=_spaceNum) {
            num_space = textField.text.length/_spaceNum-1;
        }
    }
    
    if (textField.text.length > (_maxLength+num_space)) {
        textField.text = [textField.text substringToIndex:_maxLength+num_space];
        if (self.backText) {
            self.backText(self.text);
        }
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (_showBegin) {
        _showBegin();
    }
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if (_showEnd) {
        _showEnd();
    }
    return YES;
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    //文字长度
    NSInteger text_length = textField.text.length;
    //删除
    BOOL delete = [string isEqualToString:@""];

    if (_onlyNum) {
        //有几个分割
        NSInteger num_space = 0;
        //是否可以插入分割
        BOOL isCanSpace = _isSpace && _spaceNum>0 && text_length>=_spaceNum;
        if (isCanSpace) {
            //最大可以添加多少个,刚刚好分割时减1
            BOOL just_fine = self.maxLength%_spaceNum==0;
            NSInteger max_space = self.maxLength/_spaceNum - (just_fine?1:0);
            num_space = (text_length/(_spaceNum+_spaceString.length));
            
            if (delete) {
                //删除将分割符删除
                if (_isSpace) {
                    ///如果有分割，删除的时候将光标移动到最后
                    [self setSelectedRange:NSMakeRange(text_length, 0)];
                    if (text_length - num_space*(_spaceNum+_spaceString.length)==1) {
                        textField.text = [textField.text substringToIndex:text_length-1];
                    }
                }
            } else {
                if (max_space > num_space) {
                    //是否到了添加分割的地方
                    if ((text_length-num_space*(_spaceString.length+_spaceNum)==_spaceNum)) {
                        textField.text = [NSString stringWithFormat:@"%@%@",textField.text,_spaceString];
                    }
                }
            }
        }
        
        //超过最大长度
        if (text_length >= (_maxLength + num_space) && range.location >= (_maxLength + num_space) && !delete) {
            if (self.backText) {
                self.backText(textField.text);
            }
            return NO;
        }
        
        if (_hasPoint) {
            NSInteger pointIndex = [self indexWithChar:@"." atString:textField.text];
            if (pointIndex >= 0) {
                if ((text_length) > (pointIndex+_afterPoint) && range.location >= text_length) {
                    if (self.backText) {
                        self.backText(textField.text);
                    }
                    return NO;
                }
                
                if (text_length == (pointIndex+_afterPoint) && range.location == (pointIndex+_afterPoint)) {
                    if ([[NSString stringWithFormat:@"%@%@",textField.text,string] doubleValue] < _minNum) {
                        textField.text = [NSString stringWithFormat:@"%.2f",_minNum];
                        if (self.backText) {
                            self.backText(textField.text);
                        }
                        return NO;
                    }
                }
            }
        }
        
        if ([[NSString stringWithFormat:@"%@%@",textField.text,string] floatValue] > _maxNum) {
            if (_hasPoint) {
                textField.text = [NSString stringWithFormat:@"%.2f",_maxNum];
            } else {
                textField.text = [NSString stringWithFormat:@"%.f",_maxNum];
            }
            if (self.backText) {
                self.backText(textField.text);
            }
            return NO;
        }
        
        
        BOOL isNum = [self onlyNumWithPoint:_hasPoint with:string];
        if (!isNum) {
            if (self.backText) {
                self.backText(textField.text);
            }
            return NO;
        }
        
        //如果输入小数点,则进行判断
        if ([string isEqualToString:@"."]) {
            if (text_length == 0) {//第一次输入
                if (self.backText) {
                    self.backText(textField.text);
                }
                return NO;
            } else {
                if ([self ishasPoint]) {
                    if (self.backText) {
                        self.backText(textField.text);
                    }
                    return NO;
                }
            }
        }
    }

    return YES;
}


#pragma mark - UIKeyInput
- (void)deleteBackward {
    //一些第三方键盘不能在代理中识别删除
    [self textField:self shouldChangeCharactersInRange:NSMakeRange(self.text.length-1, 1) replacementString:@""];
    [super deleteBackward];
}

#pragma mark - 字符在字符串中的位置
- (NSInteger)indexWithChar:(NSString *)charStr atString:(NSString *)str {
    for (NSInteger i = 0; i < str.length; i ++) {
        NSString  *obj = [str substringWithRange:NSMakeRange(i, 1)];
        if ([obj isEqualToString:charStr]) {
            return i;
        }
    }
    return -1;
}

#pragma mark 只能输入数字
- (BOOL)onlyNumWithPoint:(BOOL)hasPoint with:(NSString *)string{
    
    NSCharacterSet *cs;
    NSString *strNum;
    
    if (hasPoint) {
        strNum = @"1234567890.";
    } else {
        strNum = @"1234567890";
    }
    cs = [[NSCharacterSet characterSetWithCharactersInString:strNum] invertedSet];
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    BOOL basic = [string isEqualToString:filtered];
    
    return  basic;
}


//已经有小数点
- (BOOL)ishasPoint {
    NSArray *arr = [self.text componentsSeparatedByString:@"."];
    if (arr.count > 1) {
        return YES;
    } else {
        return NO;
    }
}

- (void)dealloc {
    self.delegate = nil;
    [self removeTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
}


- (NSRange) selectedRange
{
    UITextPosition* beginning = self.beginningOfDocument;
    
    UITextRange* selectedRange = self.selectedTextRange;
    UITextPosition* selectionStart = selectedRange.start;
    UITextPosition* selectionEnd = selectedRange.end;
    
    const NSInteger location = [self offsetFromPosition:beginning toPosition:selectionStart];
    const NSInteger length = [self offsetFromPosition:selectionStart toPosition:selectionEnd];
    
    return NSMakeRange(location, length);
}

- (void)setSelectedRange:(NSRange) range  // 备注：UITextField必须为第一响应者才有效
{
    UITextPosition* beginning = self.beginningOfDocument;
    
    UITextPosition* startPosition = [self positionFromPosition:beginning offset:range.location];
    UITextPosition* endPosition = [self positionFromPosition:beginning offset:range.location + range.length];
    UITextRange* selectionRange = [self textRangeFromPosition:startPosition toPosition:endPosition];
    
    [self setSelectedTextRange:selectionRange];
}


#pragma mark -
+ (NSString *)dealBank:(NSString *)bank space:(NSInteger)space {
    NSInteger length = bank.length;
    
    NSString *result = @"";
    
    NSInteger count = length/space + (length%space?1:0);
    for (NSInteger i = 0; i < count; i ++) {
        NSString *subStr;
        if (i == count-1) {
            subStr = [bank substringWithRange:NSMakeRange(i*space, length-i*space)];
        } else {
            subStr = [bank substringWithRange:NSMakeRange(i*space, space)];
        }
        result = [result stringByAppendingString:[NSString stringWithFormat:@" %@",subStr]];
    }
    return result;
}





@end
