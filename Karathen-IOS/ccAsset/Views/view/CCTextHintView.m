//
//  CCTextHintView.m
//  ccAsset
//
//  Created by SealWallet on 2018/7/18.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCTextHintView.h"
#import "AttributeMaker.h"

@interface CCTextHintView ()

@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UILabel *detailLab;

@end

@implementation CCTextHintView

- (instancetype)init {
    if (self = [super init]) {
        [self createView];
    }
    return self;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleLab.attributedText = [AttributeMaker attributeMaker:^(AttributeMaker *maker) {
        NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
        paragraph.lineSpacing = FitScale(5);
        maker.text(title)
        .paragraph(paragraph);
    }];
}

- (void)setDetail:(NSString *)detail {
    _detail = detail;
    self.detailLab.attributedText = [AttributeMaker attributeMaker:^(AttributeMaker *maker) {
        NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
        paragraph.lineSpacing = FitScale(5);
        maker.text(detail)
        .paragraph(paragraph);
    }];
}

#pragma mark - createView
- (void)createView {
    [self addSubview:self.titleLab];
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self);
        make.right.lessThanOrEqualTo(self.mas_right);
    }];
    
    [self addSubview:self.detailLab];
    [self.detailLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.equalTo(self);
        make.right.lessThanOrEqualTo(self.mas_right);
        make.top.equalTo(self.titleLab.mas_bottom).offset(FitScale(8));
    }];
}


#pragma mark - get
- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.textColor = CC_BTN_TITLE_COLOR;
        _titleLab.font = MediumFont(FitScale(12));
        _titleLab.numberOfLines = 0;
    }
    return _titleLab;
}

- (UILabel *)detailLab {
    if (!_detailLab) {
        _detailLab = [[UILabel alloc] init];
        _detailLab.textColor = CC_GRAY_TEXTCOLOR;
        _detailLab.font = MediumFont(FitScale(11));
        _detailLab.numberOfLines = 0;
    }
    return _detailLab;
}

@end
