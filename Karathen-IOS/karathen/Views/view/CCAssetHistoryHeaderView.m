
//
//  KarathenHistoryHeaderView.m
//  Karathen
//
//  Created by Karathen on 2018/7/23.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCAssetHistoryHeaderView.h"

@interface CCAssetHistoryHeaderView ()

@property (nonatomic, strong) UIButton *allBtn;
@property (nonatomic, strong) UIButton *localBtn;

@end

@implementation CCAssetHistoryHeaderView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        [self createView];
    }
    return self;
}

- (void)setType:(CCAssetHistoryType)type {
    _type = type;
    switch (type) {
        case CCAssetHistoryTypeAll:
        {
            self.allBtn.selected = YES;
            self.localBtn.selected = NO;
        }
            break;
        case CCAssetHistoryTypeTransfer:
        {
            self.allBtn.selected = NO;
            self.localBtn.selected = YES;
        }
            break;
        default:
            break;
    }
}

- (void)reloadHead {
    [self.allBtn setTitle:Localized(@"All Records") forState:UIControlStateNormal];
    [self.localBtn setTitle:Localized(@"Transfer Records") forState:UIControlStateNormal];
}

#pragma mark - createView
- (void)createView {
    self.contentView.backgroundColor = [UIColor whiteColor];

    [self.contentView addSubview:self.localBtn];
    [self.localBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(FitScale(15));
        make.centerY.equalTo(self.contentView);
        make.top.equalTo(self.contentView.mas_top);
    }];
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = CC_GRAY_LINECOLOR;
    [self.contentView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.localBtn.mas_right).offset(FitScale(10));
        make.centerY.equalTo(self.localBtn.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(.5, FitScale(15)));
    }];
    
    [self.contentView addSubview:self.allBtn];
    [self.allBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(lineView.mas_right).offset(FitScale(10));
        make.height.equalTo(self.localBtn.mas_height);
        make.centerY.equalTo(self.localBtn.mas_centerY);
    }];
    @weakify(self)
    [self.allBtn cc_tapHandle:^{
        @strongify(self)
        self.type =  CCAssetHistoryTypeAll;
        if (self.delegate && [self.delegate respondsToSelector:@selector(headView:changeType:)]) {
            [self.delegate headView:self changeType:self.type];
        }
    }];
    
    [self.localBtn cc_tapHandle:^{
        @strongify(self)
        self.type =  CCAssetHistoryTypeTransfer;
        if (self.delegate && [self.delegate respondsToSelector:@selector(headView:changeType:)]) {
            [self.delegate headView:self changeType:self.type];
        }
    }];
}

#pragma mark - get
- (UIButton *)allBtn {
    if (!_allBtn) {
        _allBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_allBtn setTitleColor:CC_MAIN_COLOR forState:UIControlStateSelected];
        [_allBtn setTitleColor:CC_BLACK_COLOR forState:UIControlStateNormal];
        _allBtn.titleLabel.font = MediumFont(FitScale(13));
    }
    return _allBtn;
}

- (UIButton *)localBtn {
    if (!_localBtn) {
        _localBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_localBtn setTitleColor:CC_MAIN_COLOR forState:UIControlStateSelected];
        [_localBtn setTitleColor:CC_BLACK_COLOR forState:UIControlStateNormal];
        _localBtn.titleLabel.font = MediumFont(FitScale(13));
    }
    return _localBtn;
}

@end
