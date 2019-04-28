//
//  CCGasCostView.m
//  Karathen
//
//  Created by Karathen on 2018/8/6.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCGasCostView.h"
#import "CCButtonView.h"

//默认最大最小为1Gwei到100Gwei
@interface CCGasCostView ()

@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) UILabel *leftLab;
@property (nonatomic, strong) UILabel *rightLab;
@property (nonatomic, strong) UILabel *centerLab;
@property (nonatomic, strong) UIImageView *lineView;
@property (nonatomic, strong) CCButtonView *numBtn;

@property (nonatomic, strong) NSDecimalNumber *gasPrice;
@property (nonatomic, strong) NSDecimalNumber *gasLimit;
@property (nonatomic, weak) CCAsset *asset;

@property (nonatomic, assign) BOOL isOpen;

@end

@implementation CCGasCostView

- (instancetype)initWithAsset:(CCAsset *)asset gasPrice:(NSString *)gasPrice {
    return [self initWithAsset:asset gasPrice:gasPrice gasLimit:nil];
}

- (instancetype)initWithAsset:(CCAsset *)asset gasPrice:(NSString *)gasPrice gasLimit:(NSString *)gasLimit {
    if (self = [super init]) {
        self.asset = asset;
        self.clipsToBounds = YES;
        self.gasPrice = [NSDecimalNumber decimalNumberWithMantissa:gasPrice.integerValue exponent:-9 isNegative:NO];
        self.gasLimit = [NSDecimalNumber decimalNumberWithString:gasLimit?:@"60000"];

        [self createView];
        [self bindData];
        [self languageChange];
        
        self.isOpen = NO;
    }
    return self;
}

- (void)changeGasPrice:(NSString *)gasPrice {
    self.gasPrice = [NSDecimalNumber decimalNumberWithMantissa:gasPrice.integerValue exponent:-9 isNegative:NO];
    
    [self bindData];
}

- (void)setIsOpen:(BOOL)isOpen {
    _isOpen = isOpen;
    if (isOpen) {
        [self.lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.titleLab.mas_left);
            make.right.equalTo(self.numBtn.mas_right);
            make.height.mas_equalTo(1);
            make.bottom.equalTo(self.mas_bottom);
            make.top.equalTo(self.leftLab.mas_bottom);
        }];
        [self layoutIfNeeded];
        [UIView animateWithDuration:.3 animations:^{
            self.numBtn.imageView.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(180));
        }];
    } else {
        [self.lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.titleLab.mas_left);
            make.right.equalTo(self.numBtn.mas_right);
            make.height.mas_equalTo(1);
            make.bottom.equalTo(self.mas_bottom);
            make.top.equalTo(self.centerLab.mas_top);
        }];
        [self layoutIfNeeded];
        [UIView animateWithDuration:.3 animations:^{
            self.numBtn.imageView.transform = CGAffineTransformIdentity;
        }];
    }
}

#pragma mark - bindData
- (void)bindData {
    self.slider.minimumValue = 1;
    self.slider.maximumValue = 100;
    self.slider.value = MAX(1, MIN(100, self.gasPrice.integerValue));
    
    [self valueChange:self.slider];
}

#pragma mark - languageChange
- (void)languageChange {
    self.titleLab.text = Localized(@"Mining Fee");
    self.leftLab.text = Localized(@"Slow");
    self.rightLab.text = Localized(@"Fast");
}

#pragma mark - createView
- (void)createView {
    [self addSubview:self.titleLab];
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(FitScale(17));
        make.top.equalTo(self.mas_top).offset(FitScale(19));
    }];
    
    [self addSubview:self.numBtn];
    [self.numBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.titleLab.mas_centerY);
        make.right.equalTo(self.mas_right).offset(-FitScale(10));
    }];
    
    
    [self addSubview:self.centerLab];
    [self.centerLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.greaterThanOrEqualTo(self.titleLab.mas_left).offset(FitScale(10));
        make.centerX.equalTo(self.mas_centerX);
        make.top.equalTo(self.titleLab.mas_bottom).offset(FitScale(15));
    }];
    
    [self addSubview:self.slider];
    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(FitScale(20));
        make.centerX.equalTo(self.mas_centerX);
        make.top.equalTo(self.centerLab.mas_bottom).offset(FitScale(10));
    }];
    
    [self addSubview:self.leftLab];
    [self.leftLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.slider.mas_bottom).offset(FitScale(20));
        make.left.equalTo(self.titleLab.mas_left);
    }];
    
    [self addSubview:self.rightLab];
    [self.rightLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).offset(-FitScale(17));
        make.top.equalTo(self.leftLab.mas_top);
    }];
    
    [self addSubview:self.lineView];
    self.lineView.hidden = YES;

    @weakify(self)
    [self.numBtn cc_tapHandle:^{
       @strongify(self)
        self.isOpen = !self.isOpen;
    }];
}

#pragma mark - valueChange
- (void)valueChange:(UISlider *)sender {
    ////四舍五入取整
    NSDecimalNumber *gweiInteger = [self gweiNum];
    //转换为Wei
    NSDecimalNumber *currentGasPrice = [NSDecimalNumber decimalNumberWithMantissa:gweiInteger.integerValue exponent:9 isNegative:NO];
    
    NSDecimalNumber *scale = [NSDecimalNumber decimalNumberWithMantissa:1 exponent:-18 isNegative:NO];
    NSDecimalNumber *result = [[currentGasPrice decimalNumberByMultiplyingBy:self.gasLimit] decimalNumberByMultiplyingBy:scale];
    self.numBtn.titleLab.text = [NSString stringWithFormat:@"%@ ether",result.stringValue];
    self.centerLab.text = [NSString stringWithFormat:@"%@ gwei",gweiInteger.stringValue];
}

- (NSString *)currentGasPrice {
    return [self gweiNum].stringValue;
}

#pragma mark - 现在选择gasprise GWei为单位
- (NSDecimalNumber *)gweiNum {
    NSNumber *value = [NSNumber numberWithFloat:self.slider.value];
    NSDecimalNumber *valueNum = [[NSDecimalNumber alloc] initWithDecimal:[value decimalValue]];
    //四舍五入取整
    NSDecimalNumber *gweiInteger = [valueNum decimalNumberByRoundingAccordingToBehavior:[NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:0 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:YES]];
    return gweiInteger;
}


#pragma mark - get
- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.font = MediumFont(FitScale(14));
        _titleLab.textColor = CC_BLACK_COLOR;
    }
    return _titleLab;
}

- (UISlider *)slider {
    if (!_slider) {
        _slider = [[UISlider alloc] init];
        _slider.thumbTintColor = CC_BTN_ENABLE_COLOR;
        _slider.maximumTrackTintColor = CC_BTN_DISABLE_COLOR;
        _slider.minimumTrackTintColor = CC_BTN_ENABLE_COLOR;
        _slider.userInteractionEnabled = YES;
        [_slider addTarget:self action:@selector(valueChange:) forControlEvents:UIControlEventValueChanged];
    }
    return _slider;
}

- (UILabel *)leftLab {
    if (!_leftLab) {
        _leftLab = [[UILabel alloc] init];
        _leftLab.font = MediumFont(FitScale(13));
        _leftLab.textColor = RGB(0xc6c5cb);
    }
    return _leftLab;
}
- (UILabel *)rightLab {
    if (!_rightLab) {
        _rightLab = [[UILabel alloc] init];
        _rightLab.font = MediumFont(FitScale(13));
        _rightLab.textColor = RGB(0xc6c5cb);
    }
    return _rightLab;
}
- (UILabel *)centerLab {
    if (!_centerLab) {
        _centerLab = [[UILabel alloc] init];
        _centerLab.font = MediumFont(FitScale(13));
        _centerLab.textColor = RGB(0xc6c5cb);
        _centerLab.numberOfLines = 0;
    }
    return _centerLab;
}


- (CCButtonView *)numBtn {
    if (!_numBtn) {
        _numBtn = [[CCButtonView alloc] init];
        _numBtn.titleLab.textColor = CC_GRAY_TEXTCOLOR;
        _numBtn.titleLab.font = MediumFont(FitScale(14));
        [_numBtn.imageView setImage:[UIImage imageNamed:@"cc_gray_arrow"]];
    }
    return _numBtn;
}

- (UIImageView *)lineView {
    if (!_lineView) {
        _lineView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cc_cell_line"]];
    }
    return _lineView;
}

@end
