//
//  CCAboutUsHeadView.m
//  ccAsset
//
//  Created by SealWallet on 2018/9/12.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCAboutUsHeadView.h"
#import "CCAppInfo.h"
#import "AttributeMaker.h"

@interface CCAboutUsHeadView ()

@property (nonatomic, strong) UIImageView *iconImgView;
@property (nonatomic, strong) UILabel *versionLab;
@property (nonatomic, strong) UILabel *contentLab;
@property (nonatomic, strong) UIImageView *lineImgView;

@end

@implementation CCAboutUsHeadView

- (instancetype)init {
    if (self = [super init]) {
        [self addSubview:self.iconImgView];
        [self.iconImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_top).offset(FitScale(25));
            make.centerX.equalTo(self.mas_centerX);
        }];
        
        [self addSubview:self.versionLab];
        [self.versionLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mas_centerX);
            make.top.equalTo(self.iconImgView.mas_bottom).offset(FitScale(10));
        }];
        
        [self addSubview:self.contentLab];
        [self.contentLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mas_centerX);
            make.top.equalTo(self.versionLab.mas_bottom).offset(FitScale(20));
            make.left.greaterThanOrEqualTo(self.mas_left).offset(FitScale(20));
        }];
        
        [self addSubview:self.lineImgView];
        [self.lineImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentLab.mas_bottom).offset(FitScale(30));
            make.left.equalTo(self.mas_left).offset(FitScale(14));
            make.bottom.equalTo(self.mas_bottom);
            make.right.equalTo(self.mas_right).offset(-FitScale(10));
        }];
        
        [self bindData];
    }
    return self;
}


#pragma mark - bindData
- (void)bindData {
    NSString *currentVersion = [CCAppInfo appVersion];
    self.versionLab.text = [NSString stringWithFormat:@"%@：%@",Localized(@"current verison"),currentVersion];
    self.contentLab.attributedText = [AttributeMaker attributeMaker:^(AttributeMaker *maker) {
        NSString *text = Localized(@"About Us Desc");
        NSMutableParagraphStyle *para = [[NSMutableParagraphStyle alloc] init];
        para.firstLineHeadIndent = FitScale(13)*2;
        maker.text(text)
        .paragraph(para);
    }];
}

#pragma mark - get
- (UIImageView *)iconImgView {
    if (!_iconImgView) {
        _iconImgView = [[UIImageView alloc] init];
        [_iconImgView setImage:[UIImage imageNamed:@"cc_aboutus_head"]];
    }
    return _iconImgView;
}

- (UILabel *)versionLab {
    if (!_versionLab) {
        _versionLab = [[UILabel alloc] init];
        _versionLab.font = MediumFont(FitScale(11));
        _versionLab.textColor = CC_GRAY_TEXTCOLOR;
    }
    return _versionLab;
}

- (UILabel *)contentLab {
    if (!_contentLab) {
        _contentLab = [[UILabel alloc] init];
        _contentLab.font = MediumFont(FitScale(13));
        _contentLab.textColor = CC_GRAY_TEXTCOLOR;
        _contentLab.numberOfLines = 0;
    }
    return _contentLab;
}

- (UIImageView *)lineImgView {
    if (!_lineImgView) {
        _lineImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cc_cell_line"]];
    }
    return _lineImgView;
}

@end
