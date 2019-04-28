//
//  CCWalletInfoHeadView.m
//  Karathen
//
//  Created by Karathen on 2018/7/18.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCWalletInfoHeadView.h"
#import "TYCyclePagerView.h"
#import "CCCopyAddressView.h"
#import "AttributeMaker.h"
#import "CCEdgeLabel.h"

@interface CCWalletInfoHeadView ()
<
TYCyclePagerViewDelegate,
TYCyclePagerViewDataSource,
CCWalletInfoHeadViewCellDelegate
>

@property (nonatomic, strong) TYCyclePagerView *pageView;
@property (nonatomic, strong) TYCyclePagerViewLayout *pagerLayout;

@end

@implementation CCWalletInfoHeadView

- (instancetype)init {
    if (self = [super init]) {
        [self createView];
    }
    return self;
}

- (void)reloadHeader {
    [self.pageView updateData];
    [self scrollToCurrent];
}

- (void)scrollToCurrent {
    NSArray *array = [CCDataManager dataManager].activeAccount.showCoins;
    CCCoinData *coinData = [CCDataManager dataManager].activeAccount.activeCoin;
    if (coinData) {
        NSInteger index = [array indexOfObject:coinData];
        [self.pageView scrollToItemAtIndex:index animate:NO];
    }
}

- (void)reloadData {
    [self.pageView updateData];
}

#pragma mark - createView
- (void)createView {
    self.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.pageView];
    [self.pageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).insets(UIEdgeInsetsMake(FitScale(10), 0, FitScale(10), 0));
    }];
    
}

#pragma mark - CCWalletInfoHeadViewCellDelegate
- (void)extractGasHeadCell:(CCWalletInfoHeadViewCell *)cell withWallet:(CCWalletData *)walletData {
    if (self.delegate && [self.delegate respondsToSelector:@selector(headView:extractGasWithWallet:)]) {
        [self.delegate headView:self extractGasWithWallet:walletData];
    }
}

#pragma mark - TYCyclePagerViewDelegate
- (NSInteger)numberOfItemsInPagerView:(TYCyclePagerView *)pageView {
    return [CCDataManager dataManager].activeAccount.showCoins.count;
}

- (UICollectionViewCell *)pagerView:(TYCyclePagerView *)pagerView cellForItemAtIndex:(NSInteger)index {
    CCWalletInfoHeadViewCell *cell = [pagerView dequeueReusableCellWithReuseIdentifier:@"CCWalletInfoHeadViewCell" forIndex:index];
    CCCoinData *coinData = [CCDataManager dataManager].activeAccount.showCoins[index];
    CCWalletData *walletData = coinData.activeWallet;
    cell.delegate = self;
    [cell bindCellWithWallet:walletData];
    return cell;
}

- (TYCyclePagerViewLayout *)layoutForPagerView:(TYCyclePagerView *)pageView {
    return self.pagerLayout;
}

- (void)pagerView:(TYCyclePagerView *)pageView didSelectedItemCell:(__kindof UICollectionViewCell *)cell atIndex:(NSInteger)index {
    if (self.delegate && [self.delegate respondsToSelector:@selector(headView:didSelectedAtIndex:)]) {
        [self.delegate headView:self didSelectedAtIndex:index];
    }
}

- (void)pagerView:(TYCyclePagerView *)pageView didScrollFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    if (fromIndex != toIndex) {
        CCAccountData *account = [CCDataManager dataManager].activeAccount;
        CCCoinData *coinData = account.showCoins[toIndex];
        [account changeActiveCoin:coinData];
        if (self.delegate && [self.delegate respondsToSelector:@selector(headView:changeToIndex:)]) {
            [self.delegate headView:self changeToIndex:toIndex];
        }
    }
}

- (void)pagerViewDidEndDecelerating:(TYCyclePagerView *)pageView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(headView:endAtIndex:)]) {
        [self.delegate headView:self endAtIndex:pageView.curIndex];
    }
}

#pragma mark - get
- (TYCyclePagerView *)pageView {
    if (!_pageView) {
        _pageView = [[TYCyclePagerView alloc] init];
        _pageView.isInfiniteLoop = YES;
        _pageView.backgroundColor = [UIColor whiteColor];
        _pageView.autoScrollInterval = 0;
        _pageView.dataSource = self;
        _pageView.delegate = self;
        [_pageView registerClass:[CCWalletInfoHeadViewCell class] forCellWithReuseIdentifier:@"CCWalletInfoHeadViewCell"];
    }
    return _pageView;
}

- (TYCyclePagerViewLayout *)pagerLayout {
    if (!_pagerLayout) {
        _pagerLayout = [[TYCyclePagerViewLayout alloc] init];
        _pagerLayout.layoutType = TYCyclePagerTransformLayoutLinear;
        _pagerLayout.itemSize = CGSizeMake(FitScale(321), FitScale(164));
        _pagerLayout.itemSpacing = FitScale(7);
        _pagerLayout.itemHorizontalCenter = YES;
    }
    return _pagerLayout;
}

@end

@interface CCWalletInfoHeadViewCell ()

@property (nonatomic, strong) UIImageView *addImgView;
@property (nonatomic, strong) UIImageView *backImgView;
@property (nonatomic, strong) UILabel *nameLab;
@property (nonatomic, strong) UILabel *priceLab;
@property (nonatomic, strong) CCEdgeLabel *gasLab;
@property (nonatomic, strong) CCEdgeLabel *offLineLab;

@property (nonatomic, strong) CCCopyAddressView *addressView;
@property (nonatomic, weak) CCWalletData *wallet;

@end

@implementation CCWalletInfoHeadViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self createView];
    }
    return self;
}

- (void)bindCellWithWallet:(CCWalletData *)wallet {
    [self.backImgView setImage:[UIImage imageNamed:@"cc_eth_infoBack"]];
    self.gasLab.hidden = YES;
    self.offLineLab.hidden = GLobalRealReachability.currentReachabilityStatus != RealStatusNotReachable;
    self.offLineLab.text = Localized(@"Off-line");
    if (wallet) {
        self.contentView.hidden = NO;
        self.addImgView.hidden = YES;
        self.wallet = wallet;
        self.nameLab.text = wallet.walletName;
        self.addressView.address = wallet.address;
        NSString *balanceString = wallet.balanceString;
        NSString *unit = [[CCCurrencyUnit currentCurrencyUnit] isEqualToString:CCCurrencyUnitCNY]?@"￥":@"$";
        self.priceLab.attributedText = [AttributeMaker attributeMaker:^(AttributeMaker *maker) {
            NSString *text = [NSString stringWithFormat:@"%@ %@",unit,balanceString];
            maker.text(text)
            .range(NSMakeRange(0, 1))
            .textFont(MediumFont(FitScale(12)));
        }];
        
        if (wallet.type == CCCoinTypeNEO) {
            self.gasLab.hidden = NO;
            NSString *symbol = [wallet claimSymbol];
            self.gasLab.text = [NSString stringWithFormat:Localized(@"Claim Symbol"),symbol];
            [self.backImgView setImage:[UIImage imageNamed:@"cc_neo_infoBack"]];
        } else if (wallet.type == CCCoinTypeONT) {
            self.gasLab.hidden = NO;
            NSString *symbol = [wallet claimSymbol];
            self.gasLab.text = [NSString stringWithFormat:Localized(@"Claim Symbol"),symbol];
            [self.backImgView setImage:[UIImage imageNamed:@"cc_ont_infoBack"]];
        }
    } else {
        self.contentView.hidden = YES;
        self.addImgView.hidden = NO;
    }
    
}

#pragma mark - createView
- (void)createView {
    [self insertSubview:self.backImgView atIndex:0];
    [self.backImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [self addSubview:self.addImgView];
    [self.addImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
    }];
    
    [self.contentView addSubview:self.nameLab];
    [self.nameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(FitScale(21));
        make.top.equalTo(self.contentView.mas_top).offset(FitScale(21));
        make.height.mas_equalTo(FitScale(14));
    }];
    
    [self.contentView addSubview:self.offLineLab];
    [self.offLineLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameLab.mas_right).offset(FitScale(5));
        make.centerY.equalTo(self.nameLab.mas_centerY);
        make.height.mas_equalTo(FitScale(18));
    }];
    
    [self.contentView addSubview:self.addressView];
    [self.addressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView.mas_centerX);
        make.left.greaterThanOrEqualTo(self.mas_left).offset(FitScale(21));
        make.bottom.equalTo(self.contentView.mas_bottom).offset(FitScale(-35));
    }];

    [self.contentView addSubview:self.gasLab];
    [self.gasLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).offset(FitScale(-20));
        make.centerY.equalTo(self.nameLab.mas_centerY);
        make.height.mas_equalTo(FitScale(20));
        make.left.greaterThanOrEqualTo(self.nameLab.mas_right).offset(FitScale(10)).priority(MASLayoutPriorityDefaultHigh);
    }];
    
    [self.contentView addSubview:self.priceLab];
    [self.priceLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView.mas_centerX);
        make.top.equalTo(self.nameLab.mas_bottom);
        make.bottom.equalTo(self.addressView.mas_top);
        make.left.greaterThanOrEqualTo(self.mas_left).offset(FitScale(21));
    }];
    
    @weakify(self)
    [self.addressView.button cc_tapHandle:^{
        @strongify(self)
        if (self.wallet) {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = self.wallet.address;
            [MBProgressHUD showMessage:Localized(@"Copy Success")];
        }
    }];
    
    [self.gasLab cc_tapHandle:^{
        @strongify(self)
        if (self.delegate && [self.delegate respondsToSelector:@selector(extractGasHeadCell:withWallet:)]) {
            [self.delegate extractGasHeadCell:self withWallet:self.wallet];
        }
    }];
    
    [CCNotificationCenter receiveRealReachabilityChangedObserver:self completion:^(ReachabilityStatus status) {
        @strongify(self)
        self.offLineLab.hidden = status != RealStatusNotReachable;
    }];
}


#pragma mark - get
- (UIImageView *)backImgView {
    if (!_backImgView) {
        _backImgView = [[UIImageView alloc] init];
    }
    return _backImgView;
}

- (UIImageView *)addImgView {
    if (!_addImgView) {
        _addImgView = [[UIImageView alloc] init];
        [_addImgView setImage:[UIImage imageNamed:@"cc_add_coin"]];
    }
    return _addImgView;
}

- (UILabel *)nameLab {
    if (!_nameLab) {
        _nameLab = [[UILabel alloc] init];
        _nameLab.textColor = [UIColor whiteColor];
        _nameLab.font = MediumFont(FitScale(14));
    }
    return _nameLab;
}


- (CCEdgeLabel *)offLineLab {
    if (!_offLineLab) {
        _offLineLab = [[CCEdgeLabel alloc] init];
        _offLineLab.textColor = CC_BTN_ENABLE_COLOR;
        _offLineLab.font = MediumFont(FitScale(13));
        _offLineLab.backgroundColor = RGB(0xf1f1f2);
        _offLineLab.layer.cornerRadius = 2;
        _offLineLab.layer.masksToBounds = YES;
        _offLineLab.edgeInsets = UIEdgeInsetsMake(0, FitScale(5), 0, FitScale(5));
    }
    return _offLineLab;
}

- (UILabel *)priceLab {
    if (!_priceLab) {
        _priceLab = [[UILabel alloc] init];
        _priceLab.textColor = [UIColor whiteColor];
        _priceLab.font = BoldFont(FitScale(18));
    }
    return _priceLab;
}

- (CCCopyAddressView *)addressView {
    if (!_addressView) {
        _addressView = [[CCCopyAddressView alloc] init];
        _addressView.label.textColor = [UIColor whiteColor];
    }
    return _addressView;
}

- (CCEdgeLabel *)gasLab {
    if (!_gasLab) {
        _gasLab = [[CCEdgeLabel alloc] init];
        _gasLab.textColor = [UIColor whiteColor];
        _gasLab.font = MediumFont(FitScale(12));
        _gasLab.edgeInsets = UIEdgeInsetsMake(0, FitScale(5), 0, FitScale(5));
        _gasLab.layer.cornerRadius = FitScale(3);
        _gasLab.layer.masksToBounds = YES;
        _gasLab.layer.borderWidth = 1;
        _gasLab.layer.borderColor = [UIColor whiteColor].CGColor;
    }
    return _gasLab;
}

@end
