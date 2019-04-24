//
//  CCWalletOptionView.m
//  ccAsset
//
//  Created by SealWallet on 2018/10/25.
//  Copyright © 2018 raistone. All rights reserved.
//

#import "CCWalletOptionView.h"

@interface CCWalletOptionView ()

@property (nonatomic, weak) CCCoinData *coinData;
@property (nonatomic, weak) CCWalletData *walletData;

@end

@implementation CCWalletOptionView

- (instancetype)initWithCoinType:(CCCoinType)coinType walletData:(CCWalletData *)walletData {
    if (self = [self initOptionView]) {
        self.coinData = [CCDataManager dataManager].activeAccount.activeCoin;
        self.walletData = walletData;
        [self customSet];
    }
    return self;
}

- (void)showTargetView:(UIView *)view space:(CGFloat)space {
    self.edgeInsets = UIEdgeInsetsZero;
    [self showOffSetScale:.5 space:space viewWidth:SCREEN_WIDTH targetView:view direction:MLMOptionSelectViewBottom];
}


#pragma mark - 设置
- (void)customSet {
    self.canEdit = NO;
    self.vhShow = YES;
    self.multiSelect = NO;
    self.maxLine = 6;
    self.cornerRadius = 0;
    self.coverColor = [UIColor clearColor];
    self.optionType = MLMOptionSelectViewTypeCustom;
    
    [self registerClass:[CCWalletOptionCell class] forCellReuseIdentifier:@"CCWalletOptionCell"];
    
    @weakify(self)
    self.cell = ^UITableViewCell *(NSIndexPath *indexPath) {
        @strongify(self)
        CCWalletData *walletData = self.coinData.wallets[indexPath.row];
        CCWalletOptionCell *cell = [self dequeueReusableCellWithIdentifier:@"CCWalletOptionCell"];
        [cell bindCellWithWallet:walletData withSelected:[walletData isEqual:self.walletData]];
        return cell;
    };
    
    self.optionCellHeight = ^float(NSIndexPath *indexPath) {
        return FitScale(80);
    };
    
    self.selectedOption = ^(NSIndexPath *indexPath) {
        @strongify(self)
        CCWalletData *walletData = self.coinData.wallets[indexPath.row];
        self.walletData = walletData;
        if (self.chooseWallet) {
            self.chooseWallet(walletData);
        }
    };
    
    self.rowNumber = ^NSInteger{
        @strongify(self)
        return self.coinData.wallets.count;
    };
}

@end

@interface CCWalletOptionCell ()

@property (nonatomic, strong) UIView *borderView;

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *nameLab;
@property (nonatomic, strong) UILabel *addressLab;
@property (nonatomic, strong) UIImageView *selectImg;
@property (nonatomic, strong) UILabel *balanceLab;
@property (nonatomic, strong) UILabel *typeLab;

@end

@implementation CCWalletOptionCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createView];
    }
    return self;
}

- (void)bindCellWithWallet:(CCWalletData *)walletData withSelected:(BOOL)isSelected {
    self.nameLab.text = walletData.walletName;
    NSInteger iconId = walletData.wallet.iconId+walletData.type;
    NSString *iconString = [NSString stringWithFormat:@"cc_address_icon_%ld",iconId%25];
    [self.iconView setImage:[UIImage imageNamed:iconString]];
    if (isSelected) {
        self.balanceLab.textColor = self.typeLab.textColor = self.nameLab.textColor = self.addressLab.textColor = CC_BTN_ENABLE_COLOR;
        self.selectImg.hidden = NO;
        self.borderView.layer.shadowOpacity = .8;
    } else {
        self.balanceLab.textColor = self.typeLab.textColor = self.nameLab.textColor = CC_BLACK_COLOR;
        self.addressLab.textColor = CC_GRAY_TEXTCOLOR;
        self.borderView.layer.shadowOpacity = .3;
        self.selectImg.hidden = YES;
    }
    CCAsset *asset = walletData.assets.firstObject;
    self.balanceLab.text = asset.balance;
    self.typeLab.text = asset.tokenSynbol.uppercaseString;    
    self.addressLab.text = walletData.address;
}


#pragma mark - createView
- (void)createView {
    [self.contentView addSubview:self.borderView];
    [self.borderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView).insets(UIEdgeInsetsMake(FitScale(5), FitScale(10), FitScale(5), FitScale(10)));
    }];
    
    [self.borderView addSubview:self.iconView];
    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.borderView.mas_left).offset(FitScale(8));
        make.centerY.equalTo(self.borderView.mas_centerY);
    }];
    
    [self.borderView addSubview:self.addressLab];
    [self.addressLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconView.mas_right).offset(FitScale(12));
        make.bottom.equalTo(self.borderView.mas_bottom).offset(-FitScale(18));
        make.width.mas_equalTo(FitScale(130));
    }];
    
    [self.borderView addSubview:self.nameLab];
    [self.nameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.addressLab.mas_left);
        make.top.equalTo(self.borderView.mas_top).offset(FitScale(15));
        make.right.lessThanOrEqualTo(self.addressLab.mas_right);
        make.bottom.equalTo(self.addressLab.mas_top).offset(FitScale(-6));
    }];

    [self.borderView addSubview:self.selectImg];
    [self.selectImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.borderView.mas_centerY);
        make.centerX.equalTo(self.addressLab.mas_right).offset(FitScale(35));
    }];
    
    [self.borderView addSubview:self.typeLab];
    [self.typeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.borderView.mas_right).offset(FitScale(-8));
        make.centerY.equalTo(self.borderView.mas_centerY);
    }];
    
    [self.borderView addSubview:self.balanceLab];
    [self.balanceLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.typeLab.mas_left);
        make.centerY.equalTo(self.borderView.mas_centerY);
        make.left.greaterThanOrEqualTo(self.selectImg.mas_right).offset(FitScale(5));
    }];
    
}

#pragma mark - get
- (UIView *)borderView {
    if (!_borderView) {
        _borderView = [[UIView alloc] init];
        _borderView.backgroundColor = [UIColor whiteColor];
        _borderView.layer.shadowColor = CC_BTN_ENABLE_COLOR.CGColor;
        _borderView.layer.shadowOffset = CGSizeMake(0, FitScale(1.5));
        _borderView.layer.shadowOpacity = .3;
        _borderView.layer.cornerRadius = FitScale(5);
    }
    return _borderView;
}

- (UIImageView *)iconView {
    if (!_iconView) {
        _iconView = [[UIImageView alloc] init];
    }
    return _iconView;
}

- (UILabel *)nameLab {
    if (!_nameLab) {
        _nameLab = [[UILabel alloc] init];
        _nameLab.textColor = CC_BLACK_COLOR;
        _nameLab.font = MediumFont(FitScale(14));
    }
    return _nameLab;
}

- (UILabel *)addressLab {
    if (!_addressLab) {
        _addressLab = [[UILabel alloc] init];
        _addressLab.textColor = CC_GRAY_TEXTCOLOR;
        _addressLab.font = MediumFont(FitScale(12));
        _addressLab.lineBreakMode = NSLineBreakByTruncatingMiddle;
    }
    return _addressLab;
}

- (UIImageView *)selectImg {
    if (!_selectImg) {
        _selectImg = [[UIImageView alloc] init];
        [_selectImg setImage:[UIImage imageNamed:@"cc_address_selected"]];
    }
    return _selectImg;
}

- (UILabel *)balanceLab {
    if (!_balanceLab) {
        _balanceLab = [[UILabel alloc] init];
        _balanceLab.font = MediumFont(FitScale(13));
    }
    return _balanceLab;
}

- (UILabel *)typeLab {
    if (!_typeLab) {
        _typeLab = [[UILabel alloc] init];
        _typeLab.font = MediumFont(FitScale(13));
    }
    return _typeLab;
}

@end
