//
//  CCScrollContentView.m
//  Karathen
//
//  Created by Karathen on 2018/11/27.
//  Copyright © 2018 raistone. All rights reserved.
//

#import "CCScrollContentView.h"

@interface CCScrollContentView ()

@property (nonatomic, strong) UIView *contentView;

@end

@implementation CCScrollContentView

- (instancetype)init {
    if (self = [super init]) {
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.bounces = YES;
        [self addSubview:self.contentView];
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
            make.width.mas_equalTo(SCREEN_WIDTH);
        }];
    }
    return self;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
    }
    return _contentView;
}

- (void)dealloc {
    DLog(@"dealloc --- %@",NSStringFromClass([self class]));
}

@end
