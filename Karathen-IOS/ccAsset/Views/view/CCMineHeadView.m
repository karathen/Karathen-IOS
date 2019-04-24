//
//  CCMineHeadView.m
//  ccAsset
//
//  Created by SealWallet on 2018/9/6.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCMineHeadView.h"

@implementation CCMineHeadView

- (instancetype)init {
    if (self = [super init]) {
        [self addSubview:self.titleLab];
        [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left).offset(FitScale(17));
            make.centerY.equalTo(self.mas_centerY);
        }];
        
        [self addSubview:self.backLab];
        [self.backLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.titleLab.mas_right).offset(FitScale(8));
            make.centerY.equalTo(self.mas_centerY);
            make.height.mas_equalTo(FitScale(20));
        }];
    }
    return self;
}


#pragma mark - get
- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.textColor = CC_BLACK_COLOR;
        _titleLab.font = BoldFont(FitScale(14));
    }
    return _titleLab;
}

- (CCEdgeLabel *)backLab {
    if (!_backLab) {
        _backLab = [[CCEdgeLabel alloc] init];
        _backLab.edgeInsets = UIEdgeInsetsMake(0, FitScale(8), 0, FitScale(8));
        _backLab.textColor = [UIColor whiteColor];
        _backLab.font = MediumFont(FitScale(13));
        _backLab.backgroundColor = CC_BTN_ENABLE_COLOR;
        _backLab.layer.cornerRadius = FitScale(3);
        _backLab.layer.masksToBounds = YES;
    }
    return _backLab;
}

@end
