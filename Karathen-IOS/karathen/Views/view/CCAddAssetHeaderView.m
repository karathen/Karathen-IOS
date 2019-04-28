//
//  CCAddAssetHeaderView.m
//  Karathen
//
//  Created by Karathen on 2018/7/19.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCAddAssetHeaderView.h"
#import "CCAssetSearchView.h"

@interface CCAddAssetHeaderView () <CCAssetSearchViewDelegate>

@property (nonatomic, strong) UILabel *titelLab;
@property (nonatomic, strong) UIButton *addBtn;
@property (nonatomic, strong) CCAssetSearchView *searchView;

@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UIView *cover;

@end


@implementation CCAddAssetHeaderView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        [self createView];
    }
    return self;
}

- (void)reloadHead {
    self.titelLab.text = Localized(@"Asset");
}

#pragma mark - createView
- (void)createView {
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    UIView *moreView = [[UIView alloc] init];
    [self.contentView addSubview:moreView];
    [moreView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(FitScale(13));
        make.top.equalTo(self.contentView);
        make.centerY.equalTo(self.contentView);
    }];
    [moreView addSubview:self.titelLab];
    [self.titelLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.equalTo(moreView);
    }];

    UIImageView *moreImgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cc_more_point"]];
    [moreView addSubview:moreImgV];
    [moreImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.titelLab.mas_centerY);
        make.left.equalTo(self.titelLab.mas_right).offset(FitScale(7));
        make.right.equalTo(moreView.mas_right).offset(FitScale(-10));
    }];
    
    [self.contentView addSubview:self.addBtn];
    [self.addBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(FitScale(-4));
        make.width.mas_equalTo(FitScale(45));
    }];
    
    [self.contentView addSubview:self.searchView];
    [self.searchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.addBtn.mas_left).offset(FitScale(-5));
        make.centerY.equalTo(self.addBtn.mas_centerY);
    }];
    
    [self.titelLab setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [moreImgV setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];

    @weakify(self)
    [self.addBtn cc_tapHandle:^{
        @strongify(self)
        [self.searchView.textField resignFirstResponder];
        if (self.delegate && [self.delegate respondsToSelector:@selector(addAssetHeadView:)]) {
            [self.delegate addAssetHeadView:self];
        }
    }];
    
    [moreView cc_tapHandle:^{
        @strongify(self)
        [self.searchView.textField resignFirstResponder];
        if (self.delegate && [self.delegate respondsToSelector:@selector(moreActionHeadView:showView:)]) {
            [self.delegate moreActionHeadView:self showView:moreImgV];
        }
    }];
}

#pragma mark - CCAssetSearchView
- (void)textFieldBeginEdit:(CCAssetSearchView *)searchView {
    [self.searchView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.addBtn.mas_left).offset(FitScale(-5));
        make.centerY.equalTo(self.addBtn.mas_centerY);
        make.left.equalTo(self.titelLab.superview.mas_right).offset(FitScale(5));
    }];
    
    [UIView animateWithDuration:.3 animations:^{
        [self.contentView layoutIfNeeded];
        self.searchView.layer.borderColor = RGB(0x9f9f9f).CGColor;
    }];
    
    UIView *view = [UIApplication sharedApplication].keyWindow;
    CGRect rect = [self convertRect:self.contentView.frame toView:view];
    self.backView.frame = rect;
    [self.backView addSubview:self.contentView];
    [view addSubview:self.cover];
    [view addSubview:self.backView];
    [self.cover mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(view);
    }];
    @weakify(self)
    [self.cover cc_tapHandle:^{
       @strongify(self)
        [self.searchView.textField resignFirstResponder];
    }];
  
}

- (void)textFieldEndEdit:(CCAssetSearchView *)searchView {
    [self.searchView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.addBtn.mas_left).offset(FitScale(-5));
        make.centerY.equalTo(self.addBtn.mas_centerY);
        make.left.greaterThanOrEqualTo(self.titelLab.superview.mas_right).offset(FitScale(5));
    }];
    
    [UIView animateWithDuration:.3 animations:^{
        [self.contentView layoutIfNeeded];
        self.searchView.layer.borderColor = [UIColor clearColor].CGColor;
    }];
    
    [self.cover removeFromSuperview];
    [self.backView removeFromSuperview];
    [self.contentView removeFromSuperview];
    [self addSubview:self.contentView];
}

- (void)textFieldSearch:(CCAssetSearchView *)searchView keyword:(NSString *)keyword {
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchActionHeadView:keyWord:)]) {
        [self.delegate searchActionHeadView:self keyWord:keyword];
    }
}

#pragma mark - get
- (UILabel *)titelLab {
    if (!_titelLab) {
        _titelLab = [[UILabel alloc] init];
        _titelLab.textColor = CC_BLACK_COLOR;
        _titelLab.font = MediumFont(FitScale(15));
    }
    return _titelLab;
}

- (UIButton *)addBtn {
    if (!_addBtn) {
        _addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addBtn setImage:[UIImage imageNamed:@"cc_circle_assetAdd"] forState:UIControlStateNormal];
    }
    return _addBtn;
}

- (CCAssetSearchView *)searchView {
    if (!_searchView) {
        _searchView = [[CCAssetSearchView alloc] init];
        _searchView.delegate = self;
        _searchView.layer.borderWidth = 1;
        _searchView.layer.borderColor = [UIColor clearColor].CGColor;
        _searchView.layer.cornerRadius = FitScale(3);
    }
    return _searchView;
}

- (UIView *)cover {
    if (!_cover) {
        _cover = [[UIView alloc] init];
        _cover.backgroundColor = [UIColor clearColor];
    }
    return _cover;
}

- (UIView *)backView {
    if (!_backView) {
        _backView = [[UIView alloc] init];
        _backView.backgroundColor = [UIColor clearColor];
    }
    return _backView;
}

@end
