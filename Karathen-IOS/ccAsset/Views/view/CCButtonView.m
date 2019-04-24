//
//  CCButtonView.m
//  ccAsset
//
//  Created by SealWallet on 2018/9/12.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCButtonView.h"

@implementation CCButtonView

- (instancetype)init {
    if (self = [super init]) {
        self.clipsToBounds = YES;
        
        [self addSubview:self.titleLab];
        [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.bottom.equalTo(self);
        }];
        
        [self addSubview:self.imageView];
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.titleLab.mas_right).offset(FitScale(6));
            make.right.equalTo(self.mas_right);
            make.centerY.equalTo(self.mas_centerY);
        }];
    }
    return self;
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
    }
    return _titleLab;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        
    }
    return _imageView;
}

@end
