//
//  CCCoinAddressView.m
//  ccAsset
//
//  Created by SealWallet on 2018/8/31.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCCoinAddressView.h"
#import "CCAddressManageView.h"

@interface CCCoinAddressView ()
<
UITableViewDelegate,
UITableViewDataSource,
CCCoinAddressCellDelegate,
CCAddressManageViewDelegate
>
@property (nonatomic, weak) CCCoinData *coinData;
@property (nonatomic, strong) UILabel *descLab;
@property (nonatomic, strong) CCAddressManageView *manageView;

@end

@implementation CCCoinAddressView

- (instancetype)initWithCoinData:(CCCoinData *)coinData {
    if (self = [super initWithFrame:CGRectZero style:UITableViewStylePlain]) {
        self.delegate = self;
        self.dataSource = self;
        [self registerClassCells:@[[CCCoinAddressCell class]]];
        self.coinData = coinData;
        
        self.tableFooterView = [self footView];
    }
    return self;
}

- (UIView *)footView {
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, FitScale(70))];
    
    if (self.coinData.importType == CCImportTypeSeed || self.coinData.importType == CCImportTypeMnemonic) {
        [footView addSubview:self.descLab];
        [self.descLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(footView);
            make.left.greaterThanOrEqualTo(footView.mas_left).offset(FitScale(10));
            make.top.greaterThanOrEqualTo(footView.mas_top).offset(FitScale(10));
        }];
    }

    return footView;
}

#pragma mark - scrollToIndex
- (void)scrollToIndex:(NSInteger)index {
    [self reloadData];
    [self scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

#pragma mark - CCAddressManageViewDelegate
- (void)addressManageWithType:(CCAddressManageType)type walletData:(CCWalletData *)walletData {
    switch (type) {
        case CCAddressManageKeystore:
            if (self.addressDelegate && [self.addressDelegate respondsToSelector:@selector(manageExportKeystore:)]) {
                [self.addressDelegate manageExportKeystore:walletData];
            }
            break;
        case CCAddressManagePrivateKey:
            if (self.addressDelegate && [self.addressDelegate respondsToSelector:@selector(manageExportPrivateKey:)]) {
                [self.addressDelegate manageExportPrivateKey:walletData];
            }
            break;
        case CCAddressManageWIF:
            if (self.addressDelegate && [self.addressDelegate respondsToSelector:@selector(manageExportWIF:)]) {
                [self.addressDelegate manageExportWIF:walletData];
            }
            break;
            break;
        case CCAddressManageInternet:
            if (self.addressDelegate && [self.addressDelegate respondsToSelector:@selector(manageEnterTheExplorer:)]) {
                [self.addressDelegate manageEnterTheExplorer:walletData];
            }
            break;
        case CCAddressManageDelete:
            if (self.addressDelegate && [self.addressDelegate respondsToSelector:@selector(manageDeleteAddress:)]) {
                [self.addressDelegate manageDeleteAddress:walletData];
            }
            break;
        case CCAddressManageName:
            if (self.addressDelegate && [self.addressDelegate respondsToSelector:@selector(manageChangeName:)]) {
                [self.addressDelegate manageChangeName:walletData];
            }
            break;
        case CCAddressManageClaimGas:
            if (self.addressDelegate && [self.addressDelegate respondsToSelector:@selector(manageClaimGas:)]) {
                [self.addressDelegate manageClaimGas:walletData];
            }
            break;
        default:
            break;
    }
}

#pragma mark - CCCoinAddressCellDelegate
- (void)copyAddressCell:(CCCoinAddressCell *)cell walletData:(CCWalletData *)walletData {
    UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
    pasteBoard.string = walletData.address;
    [MBProgressHUD showMessage:Localized(@"Copy Success") inView:cell];
}

- (void)moreAddressCell:(CCCoinAddressCell *)cell walletData:(CCWalletData *)walletData targetView:(UIView *)targetView {
    self.manageView.walletData = walletData;
    [self.manageView showTargetView:targetView];
}

#pragma mark - delegate/datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.coinData.wallets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CCCoinAddressCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CCCoinAddressCell"];
    cell.delegate = self;
    [self bindCell:cell withIndexPath:indexPath];
    return cell;
}

- (void)bindCell:(CCCoinAddressCell *)cell withIndexPath:(NSIndexPath *)indexPath {
    CCWalletData *walletData = self.coinData.wallets[indexPath.row];
    [cell bindCellWithWallet:walletData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    @weakify(self)
    return [tableView fd_heightForCellWithIdentifier:@"CCCoinAddressCell" configuration:^(CCCoinAddressCell *cell) {
        @strongify(self)
        [self bindCell:cell withIndexPath:indexPath];
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CCWalletData *walletData = self.coinData.wallets[indexPath.row];
    [self.coinData changeActiveWallet:walletData];
    [self reloadData];
}

#pragma mark - get
- (UILabel *)descLab {
    if (!_descLab) {
        _descLab = [[UILabel alloc] init];
        _descLab.textColor = CC_GRAY_TEXTCOLOR;
        _descLab.font = MediumFont(FitScale(12));
        _descLab.text = Localized(@"Add available addresses by creating");
        _descLab.textAlignment = NSTextAlignmentCenter;
    }
    return _descLab;
}

- (CCAddressManageView *)manageView {
    if (!_manageView) {
        _manageView = [[CCAddressManageView alloc] init];
        _manageView.manageDelegate = self;
    }
    return _manageView;
}

@end

@interface CCCoinAddressCell ()

@property (nonatomic, strong) UIView *borderView;

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *nameLab;
@property (nonatomic, strong) UILabel *typeLab;
@property (nonatomic, strong) UILabel *addressLab;
@property (nonatomic, strong) UIImageView *selectImg;
@property (nonatomic, strong) UIButton *clipBtn;
@property (nonatomic, strong) UIButton *moreBtn;
@property (nonatomic, weak) CCWalletData *walletData;

@end

@implementation CCCoinAddressCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createView];
    }
    return self;
}

- (void)bindCellWithWallet:(CCWalletData *)walletData {
    self.walletData = walletData;
    self.nameLab.text = walletData.walletName;
    
    if (walletData.importType == CCImportTypeSeed || walletData.importType == CCImportTypeMnemonic) {
        self.typeLab.text = [NSString stringWithFormat:@"HDM44 0/%hd",walletData.wallet.slot];
    } else {
        self.typeLab.text = @"";
    }
    
    NSInteger iconId = walletData.wallet.iconId+self.walletData.type;
    NSString *iconString = [NSString stringWithFormat:@"cc_address_icon_%ld",iconId%25];
    [self.iconView setImage:[UIImage imageNamed:iconString]];
    if (walletData.isSelected) {
        self.nameLab.textColor = self.typeLab.textColor = self.addressLab.textColor = CC_BTN_ENABLE_COLOR;
        self.clipBtn.tintColor = self.moreBtn.tintColor = CC_BTN_ENABLE_COLOR;
        self.selectImg.hidden = NO;
        self.borderView.layer.shadowOpacity = .8;
    } else {
        self.nameLab.textColor = CC_BLACK_COLOR;
        self.typeLab.textColor = self.addressLab.textColor = CC_GRAY_TEXTCOLOR;
        self.clipBtn.tintColor = self.moreBtn.tintColor = CC_GRAY_TEXTCOLOR;
        self.borderView.layer.shadowOpacity = .3;
        self.selectImg.hidden = YES;
    }
    
    self.addressLab.text = walletData.address;
}

#pragma mark - createView
- (void)createView {
    [self.contentView addSubview:self.borderView];
    [self.borderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView).insets(UIEdgeInsetsMake(FitScale(10), FitScale(10), 0, FitScale(10)));
    }];
    
    [self.borderView addSubview:self.iconView];
    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.borderView.mas_left).offset(FitScale(8));
        make.centerY.equalTo(self.borderView.mas_centerY);
    }];
    
    [self.borderView addSubview:self.moreBtn];
    [self.moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.right.equalTo(self.borderView);
        make.width.mas_equalTo(FitScale(30));
    }];
    
    [self.borderView addSubview:self.addressLab];
    [self.addressLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconView.mas_right).offset(FitScale(12));
        make.bottom.equalTo(self.borderView.mas_bottom).offset(-FitScale(18));
        make.width.mas_equalTo(FitScale(150));
    }];
    
    [self.borderView addSubview:self.clipBtn];
    [self.clipBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.addressLab.mas_centerY);
        make.left.equalTo(self.addressLab.mas_right);
        make.size.mas_equalTo(CGSizeMake(FitScale(26), FitScale(26)));
    }];
    
    [self.borderView addSubview:self.nameLab];
    [self.nameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.addressLab.mas_left);
        make.top.equalTo(self.borderView.mas_top).offset(FitScale(15));
        make.right.lessThanOrEqualTo(self.moreBtn.mas_left).offset(-FitScale(10));
        make.bottom.equalTo(self.addressLab.mas_top).offset(FitScale(-6));
    }];
    
    [self.borderView addSubview:self.typeLab];
    [self.typeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameLab.mas_right).offset(FitScale(15));
        make.centerY.equalTo(self.nameLab.mas_centerY);
        make.right.lessThanOrEqualTo(self.clipBtn.mas_right);
    }];
    

    [self.typeLab setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.nameLab setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];

    [self.borderView addSubview:self.selectImg];
    [self.selectImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.borderView.mas_centerY);
        make.centerX.equalTo(self.clipBtn.mas_centerX).offset(FitScale(75));
    }];

    @weakify(self)
    [self.clipBtn cc_tapHandle:^{
        @strongify(self)
        if (self.delegate && [self.delegate respondsToSelector:@selector(copyAddressCell:walletData:)]) {
            [self.delegate copyAddressCell:self walletData:self.walletData];
        }
    }];
    
    [self.moreBtn cc_tapHandle:^{
        @strongify(self)
        if (self.delegate && [self.delegate respondsToSelector:@selector(moreAddressCell:walletData:targetView:)]) {
            [self.delegate moreAddressCell:self walletData:self.walletData targetView:self.moreBtn.imageView];
        }
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

- (UILabel *)typeLab {
    if (!_typeLab) {
        _typeLab = [[UILabel alloc] init];
        _typeLab.textColor = CC_GRAY_TEXTCOLOR;
        _typeLab.font = MediumFont(FitScale(13));
    }
    return _typeLab;
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

- (UIButton *)clipBtn {
    if (!_clipBtn) {
        _clipBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_clipBtn setImage:[UIImage imageNamed:@"cc_black_copy"] forState:UIControlStateNormal];
        _clipBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _clipBtn.imageEdgeInsets = UIEdgeInsetsMake(0, FitScale(5), 0, 0);
    }
    return _clipBtn;
}

- (UIButton *)moreBtn {
    if (!_moreBtn) {
        _moreBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_moreBtn setImage:[UIImage imageNamed:@"cc_more_h_point"] forState:UIControlStateNormal];
        _moreBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        _moreBtn.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
        _moreBtn.imageEdgeInsets = UIEdgeInsetsMake(FitScale(15), 0, 0, FitScale(10));
    }
    return _moreBtn;
}


@end
