//
//  CCTradeConfirmView.m
//  Karathen
//
//  Created by Karathen on 2018/10/17.
//  Copyright © 2018 raistone. All rights reserved.
//

#import "CCTradeConfirmView.h"
#import "CCWalletTextFieldEditView.h"
#import "CCGasCostView.h"
#import "CCButtonView.h"
#import "CCChangeWalletView.h"
#import "CCErc721DetailView.h"
#import "CCErc721TokenInfoModel.h"
#import "AttributeMaker.h"

@interface CCTradeConfirmView () <CCWalletEditViewDelegate>

@property (nonatomic, strong) CCErc721DetailView *erc721View;
@property (nonatomic, strong) UILabel *valueLab;


@property (nonatomic, strong) NSString *toAddress;
@property (nonatomic, strong) NSString *toDapp;
@property (nonatomic, weak) CCAsset *asset;
@property (nonatomic, weak) CCWalletData *walletData;
@property (nonatomic, strong) NSString *value;
@property (nonatomic, strong) NSString *remark;

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) CCWalletEditView *addressView;
@property (nonatomic, strong) CCWalletEditView *fromAddressView;
@property (nonatomic, strong) CCWalletEditView *remarkView;
@property (nonatomic, strong) CCGasCostView *costView;
@property (nonatomic, strong) UIButton *transferBtn;

@property (nonatomic, strong) UILabel *descLab;

//gas
@property (nonatomic, strong) NSString *gasPrice;
@property (nonatomic, strong) NSString *gasLimit;
@property (nonatomic, weak) CCErc721TokenInfoModel *tokenModel;

@end

@implementation CCTradeConfirmView

- (instancetype)initWithWalletData:(CCWalletData *)walletData
                             asset:(CCAsset *)asset
                         toAddress:(NSString *)toAddress
                             value:(NSString *)value
                        tokenModel:(CCErc721TokenInfoModel *)tokenModel
                            remark:(NSString *)remark {
    if (self = [super init]) {
        self.walletData = walletData;
        self.asset = asset;
        self.toAddress = toAddress;
        self.value = value;
        self.remark = remark;
        if (tokenModel) {
            [self.erc721View bindTokenModel:tokenModel withAsset:asset];
        }
        self.addressView.placeholder = self.toAddress;
        
        [self createView];
    }
    return self;
}

- (instancetype)initWithWalletData:(CCWalletData *)walletData
                         toAddress:(NSString *)toAddress
                          gasPrice:(NSString *)gasprice
                          gasLimit:(NSString *)gasLimit
                            toDapp:(NSString *)toDapp
                             value:(NSString *)value
                            remark:(NSString *)remark {
    if (self = [super init]) {
        self.walletData = walletData;
        self.asset = self.walletData.assets.firstObject;
        self.toAddress = toAddress;
        self.toDapp = toDapp;
        self.value = [NSString valueString:value decimal:self.asset.tokenDecimal];
        self.remark = remark;
        self.gasPrice = gasprice;
        self.gasLimit = gasLimit;
        self.addressView.title = @"DAPP";
        self.addressView.placeholder = self.toDapp;
        
        [self createView];
    }
    return self;
}


- (void)bindTokenModel:(CCErc721TokenInfoModel *)tokenModel {
    self.tokenModel = tokenModel;
    [self.erc721View bindTokenModel:tokenModel withAsset:self.asset];
}

#pragma mark - topView
- (UIView *)topView {
    if ([self.asset.tokenType compareWithString:CCAseet_ETH_ERC721]) {
        return self.erc721View;
    } else {
        UIView *view = [[UIView alloc] init];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(SCREEN_WIDTH);
        }];
        view.backgroundColor = [UIColor whiteColor];
        [view addSubview:self.valueLab];
        [self.valueLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.greaterThanOrEqualTo(view.mas_left).offset(FitScale(20));
            make.centerX.equalTo(view.mas_centerX);
            make.top.equalTo(view.mas_top).offset(FitScale(35));
            make.bottom.equalTo(view.mas_bottom).offset(-FitScale(13));
        }];
        
        self.valueLab.attributedText = [AttributeMaker attributeMaker:^(AttributeMaker *maker) {
            NSString *text = [NSString stringWithFormat:@"%@ %@",self.value,self.asset.tokenSynbol.lowercaseString];
            maker.text(text)
            .range(NSMakeRange(self.value.length+1, self.asset.tokenSynbol.length))
            .textFont(MediumFont(FitScale(7)));
        }];
        return view;
    }
}

#pragma mark - initView
- (void)createView {
    self.backgroundColor = [UIColor whiteColor];
    self.bounces = NO;
    self.showsVerticalScrollIndicator = NO;
    
    [self addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
        make.width.mas_equalTo(SCREEN_WIDTH);
    }];
    
    UIView *topView = [self topView];
    [self.contentView addSubview:topView];
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left);
        make.top.equalTo(self.contentView.mas_top).offset(FitScale(6));
        make.centerX.equalTo(self.contentView.mas_centerX);
    }];
    
    [self.contentView addSubview:self.addressView];
    [self.addressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left);
        make.top.equalTo(topView.mas_bottom);
        make.centerX.equalTo(self.contentView.mas_centerX);
    }];
    
    [self.contentView addSubview:self.fromAddressView];
    [self.fromAddressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left);
        make.top.equalTo(self.addressView.mas_bottom);
        make.centerX.equalTo(self.contentView.mas_centerX);
    }];
    
    UIView *lastView = self.fromAddressView;
    if (self.remark && self.remark.length) {
        [self.contentView addSubview:self.remarkView];
        [self.remarkView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView.mas_left);
            make.top.equalTo(self.fromAddressView.mas_bottom);
            make.centerX.equalTo(self.contentView.mas_centerX);
        }];
        self.remarkView.placeholder = self.remark;
        lastView = self.remarkView;
    }
    
    
    if (self.walletData.type == CCCoinTypeETH) {
        if (!self.gasPrice) {
            self.gasPrice = [[CCDataManager dataManager] gasPriceWithType:CCCoinTypeETH];
        }
        [self.contentView addSubview:self.costView];
        [self.costView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView.mas_left);
            make.top.equalTo(lastView.mas_bottom);
            make.centerX.equalTo(self.contentView.mas_centerX);
        }];
        lastView = self.costView;
    }
    
    [self.contentView addSubview:self.transferBtn];
    [self.transferBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(FitScale(40));
        make.centerX.equalTo(self.contentView.mas_centerX);
        make.height.mas_equalTo(FitScale(40));
        make.top.equalTo(lastView.mas_bottom).offset(FitScale(30));
    }];
    
    [self.contentView addSubview:self.descLab];
    [self.descLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.transferBtn);
        make.top.equalTo(self.transferBtn.mas_bottom).offset(FitScale(20));
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-FitScale(20));
    }];
    
    self.fromAddressView.placeholder = self.walletData.address;
    if (self.walletData.type == CCCoinTypeONT) {
        self.descLab.text = Localized(@"ONT Transfer hint");
    }
    
    @weakify(self)
    [self.transferBtn cc_tapHandle:^{
        @strongify(self)
        [self transferAction];
    }];
    
}

#pragma mark - 转账
- (void)transferAction {
    if ([self.confirmDelegate respondsToSelector:@selector(confrimView:gasPrice:gasLimit:)]) {
        [self.confirmDelegate confrimView:self gasPrice:[self.costView currentGasPrice] gasLimit:self.gasLimit];
    }
}


#pragma mark - get
- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor whiteColor];
    }
    return _contentView;
}

- (CCWalletEditView *)addressView {
    if (!_addressView) {
        _addressView = [[CCWalletEditView alloc] init];
        _addressView.title = Localized(@"Recipient Address");
    }
    return _addressView;
}

- (CCWalletEditView *)fromAddressView {
    if (!_fromAddressView) {
        _fromAddressView = [[CCWalletEditView alloc] init];
        _fromAddressView.title = Localized(@"Transfer Address");
    }
    return _fromAddressView;
}

- (CCWalletEditView *)remarkView {
    if (!_remarkView) {
        _remarkView = [[CCWalletEditView alloc] init];
        _remarkView.title = Localized(@"Remark");
    }
    return _remarkView;
}

- (UIButton *)transferBtn {
    if (!_transferBtn) {
        _transferBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _transferBtn.backgroundColor = CC_BTN_ENABLE_COLOR;
        _transferBtn.layer.cornerRadius = FitScale(5);
        _transferBtn.layer.masksToBounds = YES;
        [_transferBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _transferBtn.titleLabel.font = MediumFont(FitScale(14));
        [_transferBtn setTitle:Localized(@"Confirm") forState:UIControlStateNormal];
    }
    return _transferBtn;
}

- (UILabel *)descLab {
    if (!_descLab) {
        _descLab = [[UILabel alloc] init];
        _descLab.textColor = CC_GRAY_TEXTCOLOR;
        _descLab.font = MediumFont(FitScale(12));
        _descLab.numberOfLines = 0;
    }
    return _descLab;
}

- (CCGasCostView *)costView {
    if (!_costView) {
        _costView = [[CCGasCostView alloc] initWithAsset:self.asset gasPrice:self.gasPrice gasLimit:self.gasLimit];
    }
    return _costView;
}

- (CCErc721DetailView *)erc721View {
    if (!_erc721View) {
        _erc721View = [[CCErc721DetailView alloc] init];
    }
    return _erc721View;
}

- (UILabel *)valueLab {
    if (!_valueLab) {
        _valueLab = [[UILabel alloc] init];
        _valueLab.textColor = CC_BLACK_COLOR;
        _valueLab.font = MediumFont(FitScale(18));
    }
    return _valueLab;
}


@end
