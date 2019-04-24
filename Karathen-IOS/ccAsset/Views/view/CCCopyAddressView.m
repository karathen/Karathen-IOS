//
//  CCCopyAddressView.m
//  ccAsset
//
//  Created by SealWallet on 2018/8/31.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCCopyAddressView.h"

@interface CCCopyAddressView ()

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIButton *button;

@end

@implementation CCCopyAddressView

- (instancetype)init {
    if (self = [super init]) {
        [self createView];
    }
    return self;
}

- (void)setAddress:(NSString *)address {
    _address = address;
    self.label.text = address;
}

#pragma mark - createView
- (void)createView {
    [self addSubview:self.label];
    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(self);
    }];
    
    [self addSubview:self.button];
    [self.button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.label.mas_right);
        make.size.mas_equalTo(CGSizeMake(FitScale(30), FitScale(30)));
        make.top.bottom.right.equalTo(self);
    }];
}

#pragma mark - get
- (UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc] init];
        _label.font = MediumFont(FitScale(12));
        _label.lineBreakMode = NSLineBreakByTruncatingMiddle;
    }
    return _label;
}

- (UIButton *)button {
    if (!_button) {
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        [_button setImage:[UIImage imageNamed:@"cc_copy_address"] forState:UIControlStateNormal];
    }
    return _button;
}

@end
