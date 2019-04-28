//
//  UITextView+MLMTextView.m
//  Live
//
//  Created by MAC on 2018/5/18.
//  Copyright © 2018年 Zego. All rights reserved.
//

#import "UITextView+MLMTextView.h"
#import <objc/runtime.h>

//占位
static const NSString *MLMPlaceHolderKey = @"MLMPlaceHolderKey";
//字数限制
static const NSString *MLMTextViewLimitLengthKey = @"MLMTextViewLimitLengthKey";
//字数变化
static const NSString *MLMTextLengthChangeKey = @"MLMTextLengthChangeKey";
//文字变化
static const NSString *MLMTextViewTextChange = @"MLMTextViewTextChange";
//达到最大字数继续输入提醒
static const NSString *MLMGreaterThanLimitKey = @"MLMGreaterThanLimitKey";
//高度变化
static const NSString *MLMTextViewMaxHeightKey = @"MLMTextViewMaxHeightKey";
//高度变化
static const NSString *MLMTextViewHeightChangeKey = @"MLMTextViewHeightChangeKey";

//当前高度
static const NSString *MLMTextViewCurrentHeightKey = @"MLMTextViewLastHeightKey";
//是否添加过通知
static const NSString *MLMTextViewHadAddObserver = @"MLMTextViewHadAddObserver";

@interface UITextView ()

@property (nonatomic, strong) NSNumber *currentHeight;
@property (nonatomic, strong) NSNumber *addObserver;

@end

@implementation UITextView (MLMTextView)

+ (void)load {
    Method setText = class_getInstanceMethod([UITextView class], @selector(setText:));
    //获取实例方法
    Method mlm_setText = class_getInstanceMethod([UITextView class], @selector(mlm_setText:));
    method_exchangeImplementations(setText, mlm_setText);
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)mlm_setText:(NSString *)text {
    [self mlm_setText:text];
    [self textViewTextDidChange:self];
}

- (CGFloat)minHeightWithWidth:(CGFloat)width {
    return [self.mlm_placeholderView sizeThatFits:CGSizeMake(width, MAXFLOAT)].height;
}

#pragma mark - textChange
- (void)mlm_textChange {
    if (!self.addObserver.boolValue) {
        self.addObserver = [NSNumber numberWithBool:YES];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mlm_textViewChange:) name:UITextViewTextDidChangeNotification object:self];
    }
}

- (void)mlm_textViewChange:(NSNotification *)notification {
    UITextView *textView = notification.object;
    if (![textView isEqual:self]) {
        return;
    }
    
    [self textViewTextDidChange:textView];
}

- (void)textViewTextDidChange:(UITextView *)textView {
    if ([self placeholderExist]) {
        if (self.text.length > 0) {
            self.mlm_placeholderView.hidden = YES;
        } else {
            self.mlm_placeholderView.hidden = NO;
        }
    }
    //是否限制字数
    if (self.mlm_limitLength) {
        NSInteger kMaxLength = [self.mlm_limitLength integerValue];
        
        UITextRange *selectedRange = [self markedTextRange];
        UITextPosition *position = [self positionFromPosition:selectedRange.start offset:0];
        //无高亮部分才计算
        if (!position) {
            if (self.text.length > kMaxLength) {
                self.text = [self.text substringToIndex:kMaxLength];
                if (self.greaterThanLimit) {
                    self.greaterThanLimit();
                }
            }
            
            if (self.textLengthChange) {
                self.textLengthChange(self.text.length);
            }
        }
    }
    
    //是否计算高度
    if (self.textViewHeightChange) {
        CGFloat currentHeight = ceil([self sizeThatFits:CGSizeMake(self.bounds.size.width, MAXFLOAT)].height);
        if (currentHeight != [self.currentHeight floatValue]) {
            if (self.mlm_maxHeight) {
                self.scrollEnabled = currentHeight >= self.mlm_maxHeight.floatValue;
                currentHeight = MIN(currentHeight, self.mlm_maxHeight.floatValue);
            }
            self.textViewHeightChange(currentHeight);
            self.currentHeight = [NSNumber numberWithFloat:currentHeight];
        }
    }
    
    if (self.textDidChange) {
        self.textDidChange(self.text);
    }
}


#pragma mark - 判断是否有占位符
- (BOOL)placeholderExist {
    UITextView *placeholderView = objc_getAssociatedObject(self, &MLMPlaceHolderKey);
    if (placeholderView) {
        return YES;
    }
    return NO;
}

#pragma mark - 占位符view
- (UITextView *)mlm_placeholderView {
    UITextView *placeholderView = objc_getAssociatedObject(self, &MLMPlaceHolderKey);
    if (!placeholderView) {
        placeholderView = [[UITextView alloc] init];
        objc_setAssociatedObject(self, &MLMPlaceHolderKey, placeholderView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        placeholderView.scrollEnabled = NO;
        placeholderView.userInteractionEnabled = NO;
        placeholderView.backgroundColor = [UIColor clearColor];
        placeholderView.textColor = [UIColor lightGrayColor];
        [self addSubview:placeholderView];
        [placeholderView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return placeholderView;
}


- (void)refreshPlaceholderView {
    UITextView *placeholderView = objc_getAssociatedObject(self, &MLMPlaceHolderKey);
    if (placeholderView) {
        placeholderView.frame = self.bounds;
        placeholderView.font = self.font;
        placeholderView.textAlignment = self.textAlignment;
        placeholderView.textContainerInset = self.textContainerInset;
    }
}

#pragma mark - 占位符文字
- (void)setMlm_placeholder:(NSString *)mlm_placeholder {
    self.mlm_placeholderView.text = mlm_placeholder;
    [self mlm_textChange];
}

- (NSString *)mlm_placeholder {
    if (self.placeholderExist) {
        return self.mlm_placeholderView.text;
    }
    return nil;
}

#pragma mark - 颜色
- (void)setMlm_placeholderColor:(UIColor *)mlm_placeholderColor {
    self.mlm_placeholderView.textColor = mlm_placeholderColor;
}

- (UIColor *)mlm_placeholderColor {
    if (self.placeholderExist) {
        return self.mlm_placeholderView.textColor;
    }
    return nil;
}

#pragma mark - 字数限制
- (void)setMlm_limitLength:(NSNumber *)mlm_limitLength {
    objc_setAssociatedObject(self, &MLMTextViewLimitLengthKey, mlm_limitLength, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self mlm_textChange];
}

- (NSNumber *)mlm_limitLength {
    return objc_getAssociatedObject(self, &MLMTextViewLimitLengthKey);
}

#pragma mark - 长度变化
- (void)setTextLengthChange:(void (^)(NSInteger))textLengthChange {
    objc_setAssociatedObject(self, &MLMTextLengthChangeKey, textLengthChange, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self mlm_textChange];
}

- (void (^)(NSInteger))textLengthChange {
   return objc_getAssociatedObject(self, &MLMTextLengthChangeKey);
}

#pragma mark - 文字变化
- (void)setTextDidChange:(void (^)(NSString *))textDidChange {
    objc_setAssociatedObject(self, &MLMTextViewTextChange, textDidChange, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self mlm_textChange];
}

- (void (^)(NSString *))textDidChange {
    return objc_getAssociatedObject(self, &MLMTextViewTextChange);
}

#pragma mark - 达到最大限制提醒
- (void)setGreaterThanLimit:(void (^)(void))greaterThanLimit {
    objc_setAssociatedObject(self, &MLMGreaterThanLimitKey, greaterThanLimit, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(void))greaterThanLimit {
    return objc_getAssociatedObject(self, &MLMGreaterThanLimitKey);
}

#pragma mark - 高度变化block
- (void)setTextViewHeightChange:(void (^)(CGFloat))textViewHeightChange {
    objc_setAssociatedObject(self, &MLMTextViewHeightChangeKey, textViewHeightChange, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self mlm_textChange];
}

- (void (^)(CGFloat))textViewHeightChange {
    return objc_getAssociatedObject(self, &MLMTextViewHeightChangeKey);
}

#pragma mark - 最大高度
- (void)setMlm_maxHeight:(NSNumber *)mlm_maxHeight {
    objc_setAssociatedObject(self, &MLMTextViewMaxHeightKey, mlm_maxHeight, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self mlm_textChange];
}

- (NSNumber *)mlm_maxHeight {
    return objc_getAssociatedObject(self, &MLMTextViewMaxHeightKey);
}

#pragma mark - 当前高度
- (void)setCurrentHeight:(NSNumber *)currentHeight {
    objc_setAssociatedObject(self, &MLMTextViewCurrentHeightKey, currentHeight, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber *)currentHeight {
    return objc_getAssociatedObject(self, &MLMTextViewCurrentHeightKey);
}

#pragma mark - 是否添加过
- (void)setAddObserver:(NSNumber *)addObserver {
    objc_setAssociatedObject(self, &MLMTextViewHadAddObserver, addObserver, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber *)addObserver {
    return objc_getAssociatedObject(self, &MLMTextViewHadAddObserver);
}

@end
