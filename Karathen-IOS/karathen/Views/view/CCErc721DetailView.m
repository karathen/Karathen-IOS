//
//  CCErc721DetailView.m
//  Karathen
//
//  Created by Karathen on 2018/9/14.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCErc721DetailView.h"
#import "CCErc721TokenInfoModel.h"

@interface CCErc721DetailView ()

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIImageView *iconImgView;
@property (nonatomic, strong) UILabel *idLab;

@property (nonatomic, strong) UIImageView *lineView;
@property (nonatomic, strong) UIImageView *geneImgView;
@property (nonatomic, strong) UILabel *geneLab;

@property (nonatomic, strong) UIImageView *speedImgView;
@property (nonatomic, strong) UILabel *speedLab;

@end

@implementation CCErc721DetailView

- (instancetype)init {
    if (self = [super init]) {
        [self createView];
    }
    return self;
}


- (void)bindTokenModel:(CCErc721TokenInfoModel *)tokenModel withAsset:(CCAsset *)asset {
    BOOL isCK = [CCWalletData checkIsCryptoKittiesAsset:asset];
    self.idLab.text = [NSString stringWithFormat:@"# %@",tokenModel.tokenId];
    if (isCK) {
        [self createCKView];
        [self.iconImgView sd_setImageWithURL:[NSURL URLWithString:[tokenModel tokenIconWithAsset:asset]] placeholderImage:[UIImage imageNamed:@"cc_721_placeholder"]];
        self.geneLab.text = [tokenModel ckGeneration];
        self.speedLab.text = [tokenModel ckSpeed];
    } else {
        [self createCustomView];
    }
}

- (void)bindUrl:(NSString *)url withTokenId:(NSString *)tokenId {
    [self createCustomView];
    self.idLab.text = [NSString stringWithFormat:@"# %@",tokenId];
    [self.iconImgView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"cc_721_placeholder"]];
}

- (void)createCKView {
    [self.contentView addSubview:self.lineView];
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconImgView.mas_right).offset(FitScale(20));
        make.right.equalTo(self.contentView.mas_right).offset(-FitScale(20));
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
    
    [self.contentView addSubview:self.idLab];
    [self.idLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.lineView.mas_left);
        make.bottom.equalTo(self.lineView.mas_top).offset(-FitScale(5));
        make.right.lessThanOrEqualTo(self.lineView.mas_right);
    }];
    
    [self.contentView addSubview:self.geneImgView];
    [self.geneImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.lineView.mas_left);
        make.top.equalTo(self.lineView.mas_bottom).offset(FitScale(7));
    }];
    
    [self.contentView addSubview:self.geneLab];
    [self.geneLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.geneImgView.mas_right).offset(FitScale(5));
        make.centerY.equalTo(self.geneImgView.mas_centerY);
    }];
    
    [self.contentView addSubview:self.speedImgView];
    [self.speedImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.geneLab.mas_right).offset(FitScale(8));
        make.centerY.equalTo(self.geneImgView.mas_centerY);
    }];
    
    [self.contentView addSubview:self.speedLab];
    [self.speedLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.speedImgView.mas_right).offset(FitScale(5));
        make.centerY.equalTo(self.geneImgView.mas_centerY);
        make.right.lessThanOrEqualTo(self.lineView.mas_right);
    }];
}

- (void)createCustomView {
    [self.contentView addSubview:self.idLab];
    [self.idLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconImgView.mas_right).offset(FitScale(20));
        make.right.equalTo(self.contentView.mas_right).offset(-FitScale(20));
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.top.greaterThanOrEqualTo(self.contentView.mas_top).offset(FitScale(10));
    }];
}

#pragma mark - createView
- (void)createView {
    [self addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(FitScale(13));
        make.top.equalTo(self.mas_top).offset(FitScale(20));
        make.center.equalTo(self);
    }];
    
    [self.contentView addSubview:self.iconImgView];
    [self.iconImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(self.contentView);
        make.right.equalTo(self.contentView.mas_centerX);
        make.height.mas_equalTo(FitScale(112));
    }];
}

#pragma mark - get
- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor whiteColor];
        
        _contentView.layer.shadowColor = CC_MAIN_COLOR.CGColor;
        _contentView.layer.shadowOffset = CGSizeMake(0, FitScale(1.5));
        _contentView.layer.shadowOpacity = .3;
        _contentView.layer.cornerRadius = FitScale(5);
    }
    return _contentView;
}

- (UIImageView *)iconImgView {
    if (!_iconImgView) {
        _iconImgView = [[UIImageView alloc] init];
        _iconImgView.backgroundColor = RGB(0xf3f9ff);
        _iconImgView.contentMode = UIViewContentModeScaleAspectFit;
        [_iconImgView setImage:[UIImage imageNamed:@"cc_721_placeholder"]];
    }
    return _iconImgView;
}

- (UILabel *)idLab {
    if (!_idLab) {
        _idLab = [[UILabel alloc] init];
        _idLab.textColor = CC_BLACK_COLOR;
        _idLab.font = MediumFont(FitScale(13));
        _idLab.numberOfLines = 0;
        _idLab.lineBreakMode = NSLineBreakByTruncatingMiddle;
    }
    return _idLab;
}

- (UIImageView *)lineView {
    if (!_lineView) {
        _lineView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cc_dash_line"]];
    }
    return _lineView;
}

- (UIImageView *)geneImgView {
    if (!_geneImgView) {
        _geneImgView = [[UIImageView alloc] init];
        [_geneImgView setImage:[UIImage imageNamed:@"cc_ck_gene"]];
    }
    return _geneImgView;
}

- (UILabel *)geneLab {
    if (!_geneLab) {
        _geneLab = [[UILabel alloc] init];
        _geneLab.textColor = CC_GRAY_TEXTCOLOR;
        _geneLab.font = MediumFont(FitScale(12));
    }
    return _geneLab;
}

- (UIImageView *)speedImgView {
    if (!_speedImgView) {
        _speedImgView = [[UIImageView alloc] init];
        [_speedImgView setImage:[UIImage imageNamed:@"cc_ck_speed"]];
    }
    return _speedImgView;
}

- (UILabel *)speedLab {
    if (!_speedLab) {
        _speedLab = [[UILabel alloc] init];
        _speedLab.textColor = CC_GRAY_TEXTCOLOR;
        _speedLab.font = MediumFont(FitScale(12));
    }
    return _speedLab;
}


@end
