//
//  CCLanguageSetCell.m
//  Karathen
//
//  Created by Karathen on 2018/7/11.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCLanguageSetCell.h"

@interface CCLanguageSetCell ()

@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UIImageView *selectImgView;

@end

@implementation CCLanguageSetCell

- (void)bindCellWithLanguage:(NSString *)language {
    self.titleLab.text = Localized(language);
    self.selectImgView.hidden = ![language isEqualToString:[CCMultiLanguage manager].currentLanguage];
}

- (void)bindCellWithUnit:(NSString *)unit {
    self.titleLab.text = unit;
    self.selectImgView.hidden = ![unit isEqualToString:[CCCurrencyUnit currentCurrencyUnit]];
}


#pragma mark - super method
- (void)createView {
    [super createView];
    
    [self.contentView addSubview:self.titleLab];
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(FitScale(17));
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.top.equalTo(self.contentView.mas_top).offset(FitScale(20));
    }];
    
    [self.contentView addSubview:self.selectImgView];
    [self.selectImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).offset(-FitScale(18));
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
}

#pragma mark - get
- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.font = MediumFont(FitScale(13));
        _titleLab.textColor = CC_BLACK_COLOR;
    }
    return _titleLab;
}

- (UIImageView *)selectImgView {
    if (!_selectImgView) {
        _selectImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cc_language_sel"]];
    }
    return _selectImgView;
}


@end
